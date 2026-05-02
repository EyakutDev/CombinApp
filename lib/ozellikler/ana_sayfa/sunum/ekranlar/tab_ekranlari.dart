import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/ekranlar/gardrop_ekrani.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/ekranlar/kiyafet_ekle_ekrani.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/ekranlar/kiyafet_detay_ekrani.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/bloc/gardrop_bloc.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/bloc/gardrop_olay.dart';
import 'package:combin_app/ozellikler/kombin/sunum/ekranlar/kombin_ekrani.dart';
import 'package:combin_app/ozellikler/hava_durumu/sunum/bloc/hava_durumu_bloc.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_bloc.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_durum.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_olay.dart';
import 'package:combin_app/ozellikler/plan/sunum/ekranlar/plan_ekrani.dart';


/// Placeholder ekranlar — navigasyon kurulana kadar kullanılır.
/// İleride gerçek içerikle değiştirilecek.

class AnaSayfaEkrani extends StatefulWidget {
  const AnaSayfaEkrani({super.key});

  @override
  State<AnaSayfaEkrani> createState() => _AnaSayfaEkraniState();
}

class _AnaSayfaEkraniState extends State<AnaSayfaEkrani> {
  @override
  void initState() {
    super.initState();
    // Hava durumunu yükle — kullanıcı şehrinden
    final kimlikDurumu = context.read<KimlikBloc>().state;
    final sehir = kimlikDurumu.kullanici?.sehir ?? 'İstanbul';
    context.read<HavaDurumuBloc>().add(HavaDurumuYukle(sehir: sehir));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: AppBoyutlar.boslukNormal,
            bottom: 120,
            left: AppBoyutlar.boslukBuyuk,
            right: AppBoyutlar.boslukBuyuk,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Karşılama
              BlocBuilder<KimlikBloc, KimlikDurum>(
                builder: (context, kimlikDurumu) {
                  final isim = kimlikDurumu.kullanici?.isim ?? 'Merhaba';
                  final selamBaslik = _selamBasligi(isim);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _camHapMetin(selamBaslik, AppMetinStilleri.baslikOrta),
                      const SizedBox(height: AppBoyutlar.boslukKucuk),
                      _camHapMetin(
                        'Bugün harika bir kombin seni bekliyor.',
                        AppMetinStilleri.govdeKucuk,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppBoyutlar.boslukBuyuk),

              // Hava durumu kartı
              _havaDurumuKarti(),

              const SizedBox(height: AppBoyutlar.boslukBuyuk),

              // Bugünün kombini kartı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _camHapMetin('Bugün için önerilen', AppMetinStilleri.govdeKalin),
                  GestureDetector(
                    onTap: () {},
                    child: _camHapMetin(
                      'Tümünü Gör →',
                      AppMetinStilleri.etiket.copyWith(color: AppRenkler.anaVurgu, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppBoyutlar.boslukKucuk),
              _bugunKombiniKarti(context),

              const SizedBox(height: AppBoyutlar.boslukBuyuk),

              // Gardırop Özeti (Temsili)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _camHapMetin('Gardırop özeti', AppMetinStilleri.govdeKalin),
                  GestureDetector(
                    onTap: () {},
                    child: _camHapMetin(
                      'Detaylara Git →',
                      AppMetinStilleri.etiket.copyWith(color: AppRenkler.anaVurgu, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppBoyutlar.boslukKucuk),
              _gardropOzetiKarti(),
            ],
          ),
        ),
      ),
      // Kıyafet Ekle FAB — Her zaman erişilebilir, cam stili
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100), // Navbar üstünde kalması için
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
            boxShadow: [
              BoxShadow(
                color: AppRenkler.anaVurgu.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => context.push('/kiyafet-ekle'),
            backgroundColor: AppRenkler.anaVurgu,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Kıyafet Ekle', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  /// Liquid Glass metin hapı
  Widget _camHapMetin(String metin, TextStyle stil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppRenkler.camGolge,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(metin, style: stil),
    );
  }

  /// Gardırop özeti kartı (Görseldeki alt bölüm)
  Widget _gardropOzetiKarti() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppBoyutlar.boslukBuyuk, horizontal: AppBoyutlar.boslukNormal),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan,
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
        boxShadow: [
          BoxShadow(
            color: AppRenkler.camGolge,
            blurRadius: 24.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ozetSutun(Icons.checkroom_rounded, '126', 'Parça'),
          _ozetSutun(Icons.dry_cleaning_rounded, '32', 'Üst'),
          _ozetSutun(Icons.airline_seat_legroom_normal_rounded, '28', 'Alt'),
          _ozetSutun(Icons.snowshoeing_rounded, '16', 'Ayakkabı'),
          _ozetSutun(Icons.watch_rounded, '12', 'Aksesuar'),
        ],
      ),
    );
  }

  Widget _ozetSutun(IconData ikon, String sayi, String etiket) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, color: AppRenkler.metinIkincil, size: 24),
        const SizedBox(height: AppBoyutlar.boslukKucuk),
        Text(sayi, style: AppMetinStilleri.govdeKalin),
        Text(etiket, style: AppMetinStilleri.etiket),
      ],
    );
  }

  /// Saate göre selam başlığı
  String _selamBasligi(String isim) {
    final saat = DateTime.now().hour;
    if (saat < 6) return 'İyi geceler, $isim ✨';
    if (saat < 12) return 'Günaydın, $isim ✨';
    if (saat < 18) return 'İyi günler, $isim ✨';
    return 'İyi akşamlar, $isim ✨';
  }

  /// Hava durumu kartı
  Widget _havaDurumuKarti() {
    return BlocBuilder<HavaDurumuBloc, HavaDurumuDurum>(
      builder: (context, durum) {
        if (durum.tip == HavaDurumuDurumTipi.yukleniyor) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
            decoration: BoxDecoration(
              color: AppRenkler.kartArkaPlan,
              borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
              boxShadow: [
                BoxShadow(
                  color: AppRenkler.camGolge,
                  blurRadius: 24.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (durum.tip == HavaDurumuDurumTipi.yuklendi && durum.havaDurumu != null) {
          final hava = durum.havaDurumu!;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppBoyutlar.boslukNormal, horizontal: AppBoyutlar.boslukNormal),
            decoration: BoxDecoration(
              color: AppRenkler.kartArkaPlan.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppRenkler.camGolge,
                  blurRadius: 16.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol: Emoji (Daha küçük)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppRenkler.arkaPlan,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    hava.havaDurumuEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: AppBoyutlar.boslukOrta),
                
                // Orta: Ana Bilgi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${hava.sicaklik.round()}°',
                            style: AppMetinStilleri.baslikOrta.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hava.havaDurumuAciklamasi,
                            style: AppMetinStilleri.govdeKalin,
                          ),
                        ],
                      ),
                      Text(
                        durum.sehir ?? "Şehir",
                        style: AppMetinStilleri.govdeKucuk.copyWith(color: AppRenkler.metinIkincil),
                      ),
                    ],
                  ),
                ),

                // Sağ: Şemsiye uyarısı veya nem
                if (hava.semsiyeGerekli)
                  _camHapMetin('☂️ Şemsiye!', AppMetinStilleri.etiket.copyWith(color: AppRenkler.anaVurgu, fontWeight: FontWeight.bold))
                else
                  _camHapMetin('Hissedilen ${hava.hissedilenSicaklik.round()}°', AppMetinStilleri.etiket),
              ],
            ),
          );
        }

        // Hata veya başlangıç
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
          decoration: BoxDecoration(
            color: AppRenkler.kartArkaPlan,
            borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
            boxShadow: [
              BoxShadow(
                color: AppRenkler.camGolge,
                blurRadius: 24.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppRenkler.uyari,
                size: 36,
              ),
              const SizedBox(width: AppBoyutlar.boslukOrta),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hava durumu yükleniyor...',
                    style: AppMetinStilleri.baslikKucuk,
                  ),
                  Text(
                    'Bağlantı kontrol ediliyor',
                    style: AppMetinStilleri.govdeKucuk,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bugünkü kombin önerileri (Örnek Kartlar)
  Widget _bugunKombiniKarti(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _ornekKombinKarti(
            baslik: 'Hafta Sonu Rahatlığı',
            altBaslik: 'Günlük',
            ikon: Icons.favorite_border_rounded,
            gorseller: [
              'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&q=80', // Kaban/Ceket
              'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400&q=80', // Pantolon
            ],
          ),
          const SizedBox(width: AppBoyutlar.boslukBuyuk),
          _ornekKombinKarti(
            baslik: 'Akşam Yemeği',
            altBaslik: 'Özel Davet',
            ikon: Icons.favorite_rounded,
            ikonRengi: AppRenkler.anaVurgu,
            gorseller: [
              'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80', // Elbise
              'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&q=80', // Çanta
            ],
          ),
        ],
      ),
    );
  }

  Widget _ornekKombinKarti({
    required String baslik,
    required String altBaslik,
    required IconData ikon,
    Color ikonRengi = AppRenkler.metinIkincil,
    required List<String> gorseller,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppBoyutlar.boslukNormal),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan,
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
        boxShadow: [
          BoxShadow(
            color: AppRenkler.camGolge,
            blurRadius: 24.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görseller Alanı
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppBoyutlar.radiusNormal),
                    child: Image.network(
                      gorseller[0],
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(width: AppBoyutlar.boslukKucuk),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppBoyutlar.radiusNormal),
                    child: Image.network(
                      gorseller[1],
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppBoyutlar.boslukOrta),
          
          // Etiket ve Kalp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: AppMetinStilleri.govdeKalin.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          altBaslik == 'Günlük' ? Icons.wb_sunny_outlined : Icons.star_border_rounded,
                          size: 14,
                          color: AppRenkler.metinIkincil,
                        ),
                        const SizedBox(width: 4),
                        Text(altBaslik, style: AppMetinStilleri.etiket),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppRenkler.ikincilArkaPlan,
                  shape: BoxShape.circle,
                ),
                child: Icon(ikon, size: 18, color: ikonRengi),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GardropEkrani extends StatefulWidget {
  const GardropEkrani({super.key});

  @override
  State<GardropEkrani> createState() => _GardropEkraniState();
}

class _GardropEkraniState extends State<GardropEkrani> {
  @override
  void initState() {
    super.initState();
    // Gardırop tab açıldığında kıyafetleri yükle
    context.read<GardropBloc>().add(const KiyafetleriYukle());
  }

  @override
  Widget build(BuildContext context) {
    return GardropEkraniTam(
      kiyafetEkleBasildi: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<GardropBloc>(),
              child: const KiyafetEkleEkrani(),
            ),
          ),
        );
      },
      kiyafetSecildi: (kiyafet) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<GardropBloc>(),
              child: KiyafetDetayEkrani(
                kiyafet: kiyafet,
                duzenleBasildi: (k) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<GardropBloc>(),
                        child: KiyafetEkleEkrani(mevcutKiyafet: k),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class KombinEkrani extends StatelessWidget {
  const KombinEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return const KombinEkraniTam();
  }
}

class PlanEkrani extends StatelessWidget {
  const PlanEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlanEkraniTam();
  }
}

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<KimlikBloc, KimlikDurum>(
          builder: (context, kimlikDurumu) {
            final kullanici = kimlikDurumu.kullanici;
            final isim = kullanici?.isim ?? 'Kullanıcı';
            final sehir = kullanici?.sehir ?? 'Şehir Belirtilmemiş';
            final basHarf = isim.isNotEmpty ? isim[0].toUpperCase() : 'K';

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppBoyutlar.boslukNormal,
                bottom: 120,
                left: AppBoyutlar.boslukBuyuk,
                right: AppBoyutlar.boslukBuyuk,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sayfa Başlığı — Cam Hap
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _camHap('Profil', AppMetinStilleri.baslikBuyuk),
                      _camHap('✏️', AppMetinStilleri.baslikOrta),
                    ],
                  ),
                  const SizedBox(height: AppBoyutlar.boslukBuyuk),

                  // Profil Bilgi Kartı — Cam Hap
                  Container(
                    padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
                    decoration: BoxDecoration(
                      color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppBoyutlar.radiusCokBuyuk),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: AppRenkler.camGolge,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppRenkler.anaVurgu.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              basHarf,
                              style: AppMetinStilleri.baslikBuyuk.copyWith(
                                color: AppRenkler.anaVurgu,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppBoyutlar.boslukOrta),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _camHap(isim, AppMetinStilleri.baslikKucuk),
                              const SizedBox(height: 6),
                              _camHap('📍 $sehir', AppMetinStilleri.govdeKucuk.copyWith(color: AppRenkler.metinIkincil)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukBuyuk),

                  // İstatistikler Row — Cam Haplar
                  Row(
                    children: [
                      Expanded(child: _istatistikKarti(ikon: Icons.favorite_border_rounded, deger: '24', etiket: 'Favori Kombin')),
                      const SizedBox(width: AppBoyutlar.boslukOrta),
                      Expanded(child: _istatistikKarti(ikon: Icons.checkroom_outlined, deger: '128', etiket: 'Parça')),
                    ],
                  ),

                  const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

                  // Menü Listesi — Cam Hap Satırları
                  _profilMenuItem(ikon: Icons.settings_outlined, baslik: 'Tercihlerim', altBaslik: 'Beden, stil ve öneri tercihlerini yönet'),
                  _profilMenuItem(ikon: Icons.notifications_none_rounded, baslik: 'Bildirimler', altBaslik: 'Bildirim tercihlerini düzenle'),
                  _profilMenuItem(ikon: Icons.favorite_border_rounded, baslik: 'Favori Kombinler', altBaslik: 'Kaydettiğin kombinleri görüntüle'),
                  _profilMenuItem(ikon: Icons.shield_outlined, baslik: 'Gizlilik', altBaslik: 'Hesap ve gizlilik ayarlarını yönet'),
                  
                  const SizedBox(height: AppBoyutlar.boslukBuyuk),
                  
                  // Çıkış Yap — Kırmızı Cam Hap
                  GestureDetector(
                    onTap: () => context.read<KimlikBloc>().add(const CikisYapIstendi()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppRenkler.hata.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                        border: Border.all(color: AppRenkler.hata.withValues(alpha: 0.2)),
                        boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppRenkler.hata.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.logout_rounded, color: AppRenkler.hata, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Çıkış Yap', style: AppMetinStilleri.govdeKalin.copyWith(color: AppRenkler.hata)),
                                Text('Hesabından çıkış yap', style: AppMetinStilleri.govdeKucuk),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppRenkler.hata),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _camHap(String metin, TextStyle stil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Text(metin, style: stil),
    );
  }

  Widget _istatistikKarti({required IconData ikon, required String deger, required String etiket}) {
    return Container(
      padding: const EdgeInsets.all(AppBoyutlar.boslukOrta),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusCokBuyuk),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(ikon, color: AppRenkler.anaVurgu, size: 26),
            const SizedBox(width: 8),
            Text(deger, style: AppMetinStilleri.baslikBuyuk),
          ]),
          const SizedBox(height: 6),
          Text(etiket, style: AppMetinStilleri.etiket),
        ],
      ),
    );
  }

  Widget _profilMenuItem({required IconData ikon, required String baslik, required String altBaslik}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppBoyutlar.boslukNormal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppRenkler.anaVurgu.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(ikon, size: 22, color: AppRenkler.anaVurgu),
            ),
            const SizedBox(width: AppBoyutlar.boslukOrta),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: AppMetinStilleri.govdeKalin),
                  const SizedBox(height: 2),
                  Text(altBaslik, style: AppMetinStilleri.govdeKucuk.copyWith(color: AppRenkler.metinIkincil)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: AppRenkler.metinUcuncul),
          ],
        ),
      ),
    );
  }
}
