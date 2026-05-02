import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/widgets/birincil_buton.dart';
import 'package:combin_app/cekirdek/utils/gorsel_yardimcilari.dart';
import '../../alan/modeller/kiyafet_modeli.dart';
import '../bloc/gardrop_bloc.dart';
import '../bloc/gardrop_olay.dart';
import 'dart:io';
import 'package:combin_app/cekirdek/widgets/cam_snack_bar.dart';

/// Kıyafet ekleme / düzenleme ekranı.
/// Fotoğraf seç → kırp → sıkıştır → etiketle → kaydet.
class KiyafetEkleEkrani extends StatefulWidget {
  /// Düzenleme modunda mevcut kıyafet (null = yeni ekleme)
  final KiyafetModeli? mevcutKiyafet;

  const KiyafetEkleEkrani({super.key, this.mevcutKiyafet});

  @override
  State<KiyafetEkleEkrani> createState() => _KiyafetEkleEkraniState();
}

class _KiyafetEkleEkraniState extends State<KiyafetEkleEkrani> {
  // Form durumu
  String? _gorselYolu; // cihaz tarafındaki sıkıştırılmış görsel
  String? _thumbnailYolu;
  KiyafetKategorisi _seciliKategori = KiyafetKategorisi.ustGiyim;
  String _seciliRenk = 'siyah';
  final Set<Mevsim> _seciliMevsimler = {Mevsim.tumMevsim};
  KiyafetKalinligi _seciliKalinlik = KiyafetKalinligi.orta;
  final TextEditingController _isimKontrolcusu = TextEditingController();

  bool _yukleniyor = false;
  bool get _duzenlemeModunda => widget.mevcutKiyafet != null;

  @override
  void initState() {
    super.initState();
    // Düzenleme modunda mevcut değerleri yükle
    if (_duzenlemeModunda) {
      final kiyafet = widget.mevcutKiyafet!;
      _seciliKategori = kiyafet.kategori;
      _seciliRenk = kiyafet.renk;
      _seciliMevsimler.clear();
      _seciliMevsimler.addAll(kiyafet.mevsimler);
      _seciliKalinlik = kiyafet.kalinlik;
      if (kiyafet.isim != null) {
        _isimKontrolcusu.text = kiyafet.isim!;
      }
    }
  }

  @override
  void dispose() {
    _isimKontrolcusu.dispose();
    super.dispose();
  }

  /// Fotoğraf seçme akışı
  Future<void> _fotografSec(ImageSource kaynak) async {
    setState(() => _yukleniyor = true);

    try {
      final sonuc = await GorselYardimcilari.tamPipeline(kaynak: kaynak);
      if (sonuc != null) {
        setState(() {
          _gorselYolu = sonuc['orijinal'];
          _thumbnailYolu = sonuc['thumbnail'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        CamSnackBar.hata(context, 'Fotoğraf işlenirken hata oluştu');
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  /// Kaydet
  Future<void> _kaydet() async {
    // Yeni ekleme: görsel zorunlu
    if (!_duzenlemeModunda && _gorselYolu == null) {
      CamSnackBar.uyari(context, 'Lütfen bir fotoğraf seç');
      return;
    }

    // Mevsim zorunlu
    if (_seciliMevsimler.isEmpty) {
      CamSnackBar.uyari(context, 'En az bir mevsim seç');
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      final kullaniciId = Supabase.instance.client.auth.currentUser?.id;
      if (kullaniciId == null) throw Exception('Oturum bulunamadı');

      String gorselUrl;
      String? kucukGorselUrl;

      if (_gorselYolu != null) {
        // Yeni görsel yüklendi — Supabase'e yükle
        final dosyaAdi = GorselYardimcilari.benzersizDosyaAdi();

        // Orijinal yükle
        gorselUrl = await _gorselYukle(kullaniciId, _gorselYolu!, dosyaAdi);

        // Thumbnail yükle
        if (_thumbnailYolu != null) {
          kucukGorselUrl =
              await _thumbnailYukle(kullaniciId, _thumbnailYolu!, dosyaAdi);
        }
      } else {
        // Düzenleme modu — mevcut URL'leri kullan
        gorselUrl = widget.mevcutKiyafet!.gorselUrl;
        kucukGorselUrl = widget.mevcutKiyafet!.kucukGorselUrl;
      }

      final kiyafet = KiyafetModeli(
        id: _duzenlemeModunda ? widget.mevcutKiyafet!.id : '',
        kullaniciId: kullaniciId,
        isim: _isimKontrolcusu.text.trim().isEmpty ? null : _isimKontrolcusu.text.trim(),
        kategori: _seciliKategori,
        renk: _seciliRenk,
        mevsimler: _seciliMevsimler.toList(),
        kalinlik: _seciliKalinlik,
        gorselUrl: gorselUrl,
        kucukGorselUrl: kucukGorselUrl,
        favori: _duzenlemeModunda ? widget.mevcutKiyafet!.favori : false,
        olusturulmaTarihi: _duzenlemeModunda
            ? widget.mevcutKiyafet!.olusturulmaTarihi
            : DateTime.now(),
        guncellemeTarihi: DateTime.now(),
      );

      if (!mounted) return;

      if (_duzenlemeModunda) {
        context.read<GardropBloc>().add(KiyafetGuncelle(kiyafet: kiyafet));
      } else {
        context.read<GardropBloc>().add(KiyafetEkle(kiyafet: kiyafet));
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        CamSnackBar.hata(context, 'Hata: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  /// Supabase'e görsel yükle
  Future<String> _gorselYukle(
    String kullaniciId,
    String dosyaYolu,
    String dosyaAdi,
  ) async {
    final storagePath = '$kullaniciId/$dosyaAdi';
    await Supabase.instance.client.storage
        .from('kiyafetler')
        .upload(storagePath, File(dosyaYolu));
    return Supabase.instance.client.storage
        .from('kiyafetler')
        .getPublicUrl(storagePath);
  }

  /// Supabase'e thumbnail yükle
  Future<String> _thumbnailYukle(
    String kullaniciId,
    String dosyaYolu,
    String dosyaAdi,
  ) async {
    final storagePath = '$kullaniciId/kucuk_$dosyaAdi';
    await Supabase.instance.client.storage
        .from('kiyafetler')
        .upload(storagePath, File(dosyaYolu));
    return Supabase.instance.client.storage
        .from('kiyafetler')
        .getPublicUrl(storagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppRenkler.arkaPlan,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === Fotoğraf Alanı (Hero) ===
                _heroFotografAlani(),

                Padding(
                  padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // === İsim (Opsiyonel) ===
                      Text('Kıyafet İsmi (İsteğe Bağlı)', style: AppMetinStilleri.baslikKucuk),
                      const SizedBox(height: AppBoyutlar.boslukOrta),
                      TextFormField(
                        controller: _isimKontrolcusu,
                        decoration: InputDecoration(
                          hintText: 'Örn: Pudra Elbise',
                          prefixIcon: const Icon(Icons.checkroom_rounded),
                          filled: true,
                          fillColor: AppRenkler.kartArkaPlan,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppBoyutlar.boslukBuyuk, vertical: AppBoyutlar.boslukOrta),
                        ),
                        style: AppMetinStilleri.govdeNormal,
                      ),
                      
                      const SizedBox(height: AppBoyutlar.boslukBuyuk),

                      // === Kategori ===
                      Text('Kategori', style: AppMetinStilleri.baslikKucuk),
                      const SizedBox(height: AppBoyutlar.boslukOrta),
                      _kategoriSecici(),

                      const SizedBox(height: AppBoyutlar.boslukBuyuk),

                      // === Renk ===
                      Text('Renk', style: AppMetinStilleri.baslikKucuk),
                      const SizedBox(height: AppBoyutlar.boslukOrta),
                      _renkSecici(),

                      const SizedBox(height: AppBoyutlar.boslukBuyuk),

                      // === Mevsim ===
                      Text('Mevsim', style: AppMetinStilleri.baslikKucuk),
                      const SizedBox(height: AppBoyutlar.boslukKucuk),
                      _mevsimSecici(),

                      const SizedBox(height: AppBoyutlar.boslukBuyuk),

                      // === Kalınlık ===
                      Text('Kalınlık', style: AppMetinStilleri.baslikKucuk),
                      const SizedBox(height: AppBoyutlar.boslukOrta),
                      _kalinlikSecici(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sabit Alt Bar (Kaydet Butonu)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
              decoration: BoxDecoration(
                color: AppRenkler.arkaPlan.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: AppRenkler.camGolge,
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: BirincilButon(
                  metin: _duzenlemeModunda ? 'Güncelle' : 'Kaydet',
                  yukleniyor: _yukleniyor,
                  tiklandiginda: _kaydet,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yeni tasarımda üstte duran Hero Fotoğraf Alanı
  Widget _heroFotografAlani() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppRenkler.ikincilArkaPlan,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppRenkler.camGolge,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Görsel veya Boş Durum
          if (_gorselYolu != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Image.file(
                File(_gorselYolu!),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else if (_duzenlemeModunda)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Image.network(
                widget.mevcutKiyafet!.gorselUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 64,
                    color: AppRenkler.anaVurgu.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppBoyutlar.boslukOrta),
                  Text(
                    'Kıyafet Görseli',
                    style: AppMetinStilleri.baslikKucuk.copyWith(
                      color: AppRenkler.metinIkincil,
                    ),
                  ),
                ],
              ),
            ),

          // Üst Kısım: Geri Butonu ve İşlem Butonu
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppBoyutlar.boslukNormal, vertical: AppBoyutlar.boslukKucuk),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Geri
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppRenkler.metinBirincil, size: 20),
                    ),
                  ),
                  
                  // Görseli Değiştir veya Ekle
                  GestureDetector(
                    onTap: () => _fotografKaynakSecDialog(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (_gorselYolu != null || _duzenlemeModunda) ? Icons.edit_rounded : Icons.add_a_photo_rounded,
                            size: 18,
                            color: AppRenkler.anaVurgu,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (_gorselYolu != null || _duzenlemeModunda) ? 'Değiştir' : 'Görsel Ekle',
                            style: AppMetinStilleri.govdeKalin.copyWith(color: AppRenkler.anaVurgu, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// Kaynak seçme dialog'u
  void _fotografKaynakSecDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppRenkler.anaVurgu),
                title: const Text('Kamera ile Çek'),
                onTap: () {
                  Navigator.pop(context);
                  _fotografSec(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppRenkler.anaVurgu),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _fotografSec(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kategori seçici — özel tasarım haplar
  Widget _kategoriSecici() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: KiyafetKategorisi.values.map((kategori) {
          final secili = _seciliKategori == kategori;
          return GestureDetector(
            onTap: () => setState(() => _seciliKategori = kategori),
            child: Container(
              margin: const EdgeInsets.only(right: AppBoyutlar.boslukOrta),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: secili ? AppRenkler.anaVurgu.withValues(alpha: 0.1) : AppRenkler.kartArkaPlan,
                borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                border: Border.all(
                  color: secili ? AppRenkler.anaVurgu : AppRenkler.ayirici,
                  width: secili ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _kategoriIkonu(kategori),
                    size: 20,
                    color: secili ? AppRenkler.anaVurgu : AppRenkler.metinIkincil,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    kategori.etiket,
                    style: AppMetinStilleri.govdeKalin.copyWith(
                      color: secili ? AppRenkler.anaVurgu : AppRenkler.metinIkincil,
                    ),
                  ),
                  if (secili) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_rounded, color: AppRenkler.anaVurgu, size: 16),
                  ]
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _kategoriIkonu(KiyafetKategorisi kategori) {
    switch (kategori) {
      case KiyafetKategorisi.ustGiyim: return Icons.checkroom_rounded;
      case KiyafetKategorisi.altGiyim: return Icons.airline_seat_legroom_normal_rounded;
      case KiyafetKategorisi.disGiyim: return Icons.accessibility_new_rounded;
      case KiyafetKategorisi.ayakkabi: return Icons.snowshoeing_rounded;
      case KiyafetKategorisi.aksesuar: return Icons.watch_rounded;
      case KiyafetKategorisi.canta: return Icons.shopping_bag_rounded;
    }
  }

  /// Renk seçici — renk daireleri
  Widget _renkSecici() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: KiyafetRengi.tumRenkler.map((renk) {
        final secili = _seciliRenk == renk.id;
        return GestureDetector(
          onTap: () {
            setState(() => _seciliRenk = renk.id);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(renk.renkKodu),
              shape: BoxShape.circle,
              border: Border.all(
                color: secili ? AppRenkler.anaVurgu : AppRenkler.ayirici,
                width: secili ? 3 : 1,
              ),
              boxShadow: secili
                  ? [
                      BoxShadow(
                        color: AppRenkler.anaVurgu.withValues(alpha: 0.3),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
            child: secili
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: renk.renkKodu == 0xFFF5F5F5 ||
                            renk.renkKodu == 0xFFD4C5A9 ||
                            renk.renkKodu == 0xFFF2C94C
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  /// Mevsim seçici — özel tasarım chip'ler
  Widget _mevsimSecici() {
    return Wrap(
      spacing: AppBoyutlar.boslukKucuk,
      runSpacing: AppBoyutlar.boslukKucuk,
      children: Mevsim.values.map((mevsim) {
        final secili = _seciliMevsimler.contains(mevsim);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (mevsim == Mevsim.tumMevsim) {
                _seciliMevsimler.clear();
                _seciliMevsimler.add(Mevsim.tumMevsim);
              } else {
                _seciliMevsimler.remove(Mevsim.tumMevsim);
                if (secili) {
                  _seciliMevsimler.remove(mevsim);
                } else {
                  _seciliMevsimler.add(mevsim);
                }
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: secili ? AppRenkler.anaVurgu.withValues(alpha: 0.1) : AppRenkler.kartArkaPlan,
              borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
              border: Border.all(
                color: secili ? AppRenkler.anaVurgu : AppRenkler.ayirici,
                width: secili ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _mevsimIkon(mevsim),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  mevsim.etiket,
                  style: AppMetinStilleri.govdeKalin.copyWith(
                    color: secili ? AppRenkler.anaVurgu : AppRenkler.metinIkincil,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _mevsimIkon(Mevsim mevsim) {
    switch (mevsim) {
      case Mevsim.ilkbahar: return '🌸';
      case Mevsim.yaz: return '☀️';
      case Mevsim.sonbahar: return '🍂';
      case Mevsim.kis: return '❄️';
      case Mevsim.tumMevsim: return '🌍';
    }
  }

  /// Kalınlık seçici
  Widget _kalinlikSecici() {
    return Wrap(
      spacing: AppBoyutlar.boslukKucuk,
      children: KiyafetKalinligi.values.map((kalinlik) {
        final secili = _seciliKalinlik == kalinlik;
        return GestureDetector(
          onTap: () => setState(() => _seciliKalinlik = kalinlik),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: secili ? AppRenkler.anaVurgu.withValues(alpha: 0.1) : AppRenkler.kartArkaPlan,
              borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
              border: Border.all(
                color: secili ? AppRenkler.anaVurgu : AppRenkler.ayirici,
                width: secili ? 1.5 : 1,
              ),
            ),
            child: Text(
              kalinlik.etiket,
              style: AppMetinStilleri.govdeKalin.copyWith(
                color: secili ? AppRenkler.anaVurgu : AppRenkler.metinIkincil,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
