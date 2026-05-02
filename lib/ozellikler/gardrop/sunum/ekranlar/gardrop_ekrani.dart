import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/widgets/bos_durum.dart';
import 'package:combin_app/cekirdek/widgets/hata_durumu.dart';
import 'package:combin_app/cekirdek/widgets/yukleniyor.dart';
import '../../alan/modeller/kiyafet_modeli.dart';
import '../bloc/gardrop_bloc.dart';
import '../bloc/gardrop_olay.dart';
import '../bloc/gardrop_durum.dart';
import 'package:combin_app/cekirdek/widgets/cam_app_bar.dart';
import 'package:combin_app/cekirdek/widgets/cam_snack_bar.dart';

/// Gardırop ana ekranı — grid/liste görünüm, filtreler, arama, FAB.
class GardropEkraniTam extends StatefulWidget {
  /// Kıyafet ekleme sayfasına yönlendirme callback'i
  final VoidCallback? kiyafetEkleBasildi;

  /// Kıyafet detay sayfasına yönlendirme callback'i
  final void Function(KiyafetModeli)? kiyafetSecildi;

  const GardropEkraniTam({
    super.key,
    this.kiyafetEkleBasildi,
    this.kiyafetSecildi,
  });

  @override
  State<GardropEkraniTam> createState() => _GardropEkraniTamState();
}

class _GardropEkraniTamState extends State<GardropEkraniTam> {
  final _aramaController = TextEditingController();
  bool _aramaAcik = false;

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CamAppBar + SafeArea üst padding doğru hesap
    final ustBosluk = MediaQuery.of(context).padding.top + kToolbarHeight + 34;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CamAppBar(
        title: _aramaAcik
            ? _aramaAlani()
            : const Text('Gardırop'),
        actions: [
          // Arama toggle
          IconButton(
            icon: Icon(_aramaAcik ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _aramaAcik = !_aramaAcik;
                if (!_aramaAcik) {
                  _aramaController.clear();
                  context.read<GardropBloc>().add(const KiyafetleriYukle());
                }
              });
            },
          ),
          // Grid/Liste toggle
          BlocBuilder<GardropBloc, GardropDurum>(
            builder: (context, durum) {
              return IconButton(
                icon: Icon(
                  durum.gridGorunumu
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                ),
                onPressed: () {
                  context.read<GardropBloc>().add(const GorunumModuDegistir());
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // CamAppBar altında doğru boşluk
          SizedBox(height: ustBosluk),

          // Kategori filtre çubuğu
          _kategoriFiltreCubugu(),

          // Kıyafet listesi
          Expanded(child: _kiyafetListesi()),
        ],
      ),
      // FAB — Cam Stili
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppRenkler.anaVurgu.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: widget.kiyafetEkleBasildi,
          backgroundColor: AppRenkler.anaVurgu,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  /// Arama text field
  Widget _aramaAlani() {
    return TextField(
      controller: _aramaController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Kıyafet ara...',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        fillColor: Colors.transparent,
        filled: true,
      ),
      onChanged: (sorgu) {
        context.read<GardropBloc>().add(KiyafetAra(sorgu: sorgu));
      },
    );
  }

  /// Yatay kaydırılan kategori chip'leri — Liquid Glass Stili
  Widget _kategoriFiltreCubugu() {
    return BlocBuilder<GardropBloc, GardropDurum>(
      builder: (context, durum) {
        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppBoyutlar.boslukNormal,
              vertical: AppBoyutlar.boslukKucuk,
            ),
            children: [
              // "Tümü" chip
              Padding(
                padding: const EdgeInsets.only(right: AppBoyutlar.boslukKucuk),
                child: _camChip(
                  etiket: 'Tümü (${durum.toplamSayi})',
                  secili: durum.seciliKategori == null,
                  onTap: () => context.read<GardropBloc>().add(const KategoriyeGoreFiltrele(kategori: null)),
                ),
              ),
              // Kategori chip'leri
              ...KiyafetKategorisi.values.map((kategori) {
                final sayi = durum.kategoriSayilari[kategori] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(right: AppBoyutlar.boslukKucuk),
                  child: _camChip(
                    etiket: '${kategori.etiket} ($sayi)',
                    secili: durum.seciliKategori == kategori,
                    onTap: () => context.read<GardropBloc>().add(KategoriyeGoreFiltrele(kategori: kategori)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Liquid Glass Chip
  Widget _camChip({required String etiket, required bool secili, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: secili
              ? AppRenkler.anaVurgu.withValues(alpha: 0.15)
              : AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          border: Border.all(
            color: secili
                ? AppRenkler.anaVurgu.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppRenkler.camGolge,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          etiket,
          style: AppMetinStilleri.etiket.copyWith(
            color: secili ? AppRenkler.anaVurgu : AppRenkler.metinBirincil,
            fontWeight: secili ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Kıyafet grid/liste
  Widget _kiyafetListesi() {
    return BlocConsumer<GardropBloc, GardropDurum>(
      listener: (context, durum) {
        if (durum.basariMesaji != null) {
          CamSnackBar.basari(context, durum.basariMesaji!);
        }
        if (durum.hataMesaji != null && durum.tip == GardropDurumTipi.hata) {
          CamSnackBar.hata(context, durum.hataMesaji!);
        }
      },
      builder: (context, durum) {
        // Yükleniyor
        if (durum.tip == GardropDurumTipi.yukleniyor && durum.kiyafetler.isEmpty) {
          return const Yukleniyor();
        }

        // Hata
        if (durum.tip == GardropDurumTipi.hata && durum.kiyafetler.isEmpty) {
          return HataDurumu(
            mesaj: durum.hataMesaji ?? 'Bir hata oluştu',
            tekrarDene: () {
              context.read<GardropBloc>().add(const KiyafetleriYukle());
            },
          );
        }

        final kiyafetler = durum.filtrelenmisKiyafetler;

        // Boş
        if (kiyafetler.isEmpty) {
          if (durum.aramaSorgusu.isNotEmpty) {
            return const BosDurum(
              ikon: Icons.search_off_rounded,
              baslik: 'Sonuç bulunamadı',
              aciklama: 'Farklı bir arama terimi dene.',
            );
          }
          return BosDurum(
            ikon: Icons.checkroom_rounded,
            baslik: 'Dolabın henüz boş',
            aciklama: 'İlk kıyafetini ekleyerek başla.',
            butonMetni: 'Kıyafet Ekle',
            butonTiklandiginda: widget.kiyafetEkleBasildi,
          );
        }

        // Grid görünüm
        if (durum.gridGorunumu) {
          return GridView.builder(
            padding: const EdgeInsets.only(
              left: AppBoyutlar.boslukNormal,
              right: AppBoyutlar.boslukNormal,
              top: AppBoyutlar.boslukNormal,
              bottom: 120, // Navbar
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppBoyutlar.gardropSutunSayisi,
              crossAxisSpacing: AppBoyutlar.gridAraligi,
              mainAxisSpacing: AppBoyutlar.gridAraligi,
              childAspectRatio: AppBoyutlar.gardropKartOrani,
            ),
            itemCount: kiyafetler.length,
            itemBuilder: (context, indeks) {
              return _kiyafetKartGrid(kiyafetler[indeks]);
            },
          );
        }

        // Liste görünüm
        return ListView.separated(
          padding: const EdgeInsets.only(
            left: AppBoyutlar.boslukNormal,
            right: AppBoyutlar.boslukNormal,
            top: AppBoyutlar.boslukNormal,
            bottom: 120, // Navbar
          ),
          itemCount: kiyafetler.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppBoyutlar.boslukKucuk),
          itemBuilder: (context, indeks) {
            return _kiyafetKartListe(kiyafetler[indeks]);
          },
        );
      },
    );
  }

  /// Grid kıyafet kartı
  Widget _kiyafetKartGrid(KiyafetModeli kiyafet) {
    final renkBilgisi = kiyafet.renkBilgisi;

    return GestureDetector(
      onTap: () => widget.kiyafetSecildi?.call(kiyafet),
      child: Container(
        decoration: BoxDecoration(
          color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppRenkler.camGolge,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fotoğraf
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppBoyutlar.radiusBuyuk),
                    ),
                    child: _kiyafetGorseli(kiyafet),
                  ),
                  // Favori butonu
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _favoriButonu(kiyafet),
                  ),
                ],
              ),
            ),
            // Alt bilgi
            Padding(
              padding: const EdgeInsets.all(AppBoyutlar.boslukKucuk),
              child: Row(
                children: [
                  // Renk noktası
                  if (renkBilgisi != null)
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: Color(renkBilgisi.renkKodu),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppRenkler.ayirici,
                          width: 0.5,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      kiyafet.kategori.etiket,
                      style: AppMetinStilleri.govdeKucuk,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Liste kıyafet kartı
  Widget _kiyafetKartListe(KiyafetModeli kiyafet) {
    final renkBilgisi = kiyafet.renkBilgisi;

    return GestureDetector(
      onTap: () => widget.kiyafetSecildi?.call(kiyafet),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppRenkler.camGolge,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Fotoğraf
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppBoyutlar.radiusBuyuk),
              ),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _kiyafetGorseli(kiyafet),
              ),
            ),
            const SizedBox(width: AppBoyutlar.boslukOrta),
            // Bilgi
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kiyafet.kategori.etiket,
                    style: AppMetinStilleri.govdeBuyuk.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (renkBilgisi != null) ...[
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Color(renkBilgisi.renkKodu),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          renkBilgisi.isim,
                          style: AppMetinStilleri.govdeKucuk,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        kiyafet.kalinlik.etiket,
                        style: AppMetinStilleri.govdeKucuk,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Favori butonu
            _favoriButonu(kiyafet),
            const SizedBox(width: AppBoyutlar.boslukKucuk),
          ],
        ),
      ),
    );
  }

  /// Kıyafet görseli (CachedNetworkImage)
  Widget _kiyafetGorseli(KiyafetModeli kiyafet) {
    final gorselUrl = kiyafet.kucukGorselUrl ?? kiyafet.gorselUrl;

    return CachedNetworkImage(
      imageUrl: gorselUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: AppRenkler.ikincilArkaPlan,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppRenkler.ikincilArkaPlan,
        child: const Icon(
          Icons.checkroom_rounded,
          color: AppRenkler.deaktif,
          size: 32,
        ),
      ),
    );
  }

  /// Favori kalp butonu
  Widget _favoriButonu(KiyafetModeli kiyafet) {
    return GestureDetector(
      onTap: () {
        context.read<GardropBloc>().add(
              FavoriDegistir(
                kiyafetId: kiyafet.id,
                favori: !kiyafet.favori,
              ),
            );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppRenkler.camGolge,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          kiyafet.favori ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: kiyafet.favori ? AppRenkler.favoriKalp : AppRenkler.metinUcuncul,
        ),
      ),
    );
  }
}
