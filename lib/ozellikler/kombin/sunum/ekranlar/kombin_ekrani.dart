import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/widgets/birincil_buton.dart';
import 'package:combin_app/cekirdek/widgets/bos_durum.dart';
import 'package:combin_app/cekirdek/widgets/hata_durumu.dart';
import 'package:combin_app/cekirdek/widgets/yukleniyor.dart';
import 'package:combin_app/ozellikler/gardrop/alan/modeller/kiyafet_modeli.dart';
import 'package:combin_app/ozellikler/hava_durumu/sunum/bloc/hava_durumu_bloc.dart';
import '../bloc/kombin_bloc.dart';
import 'package:combin_app/cekirdek/widgets/cam_app_bar.dart';
import 'package:combin_app/cekirdek/widgets/cam_snack_bar.dart';

/// Kombin ekranı — hava durumuna göre kombin önerisi, parça değiştirme, etkinlik filtresi.
class KombinEkraniTam extends StatelessWidget {
  const KombinEkraniTam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CamAppBar(
        title: const Text('Kombin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded),
            tooltip: 'Kayıtlı Kombinler',
            onPressed: () {
              // go_router ile geçiş
              context.push('/kayitli-kombinler');
            },
          ),
        ],
      ),
      body: BlocConsumer<KombinBloc, KombinDurum>(
        listenWhen: (onceki, simdiki) =>
            onceki.basariMesaji != simdiki.basariMesaji ||
            onceki.hataMesaji != simdiki.hataMesaji,
        listener: (context, durum) {
          if (durum.basariMesaji != null) {
            CamSnackBar.basari(context, durum.basariMesaji!);
          } else if (durum.hataMesaji != null &&
              durum.tip == KombinDurumTipi.hazir) {
            CamSnackBar.hata(context, durum.hataMesaji!);
          }
        },
        builder: (context, durum) {
          switch (durum.tip) {
            case KombinDurumTipi.baslangic:
              return _baslangicDurumu(context);
            case KombinDurumTipi.yukleniyor:
              return const Yukleniyor();
            case KombinDurumTipi.bos:
              return _bosDurumu(context, durum);
            case KombinDurumTipi.hata:
              return HataDurumu(
                mesaj: durum.hataMesaji ?? 'Bir hata oluştu',
                tekrarDene: () => _kombinOner(context),
              );
            case KombinDurumTipi.hazir:
              return _kombinHazir(context, durum);
          }
        },
      ),
    );
  }

  /// Başlangıç — kombin al butonu
  Widget _baslangicDurumu(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppBoyutlar.boslukCokBuyuk),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 72,
              color: AppRenkler.anaVurgu.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppBoyutlar.boslukBuyuk),
            _camHap(
              'Bugün ne giymeli?',
              AppMetinStilleri.baslikBuyuk,
            ),
            const SizedBox(height: AppBoyutlar.boslukOrta),
            _camHap(
              'Hava durumu ve dolabına göre\nbir kombin önerelim.',
              AppMetinStilleri.govdeNormal.copyWith(color: AppRenkler.metinIkincil),
            ),
            const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

            // Etkinlik seçimi
            _etkinlikSecici(context),

            const SizedBox(height: AppBoyutlar.boslukBuyuk),

            BirincilButon(
              metin: 'Kombin Öner',
              ikon: Icons.auto_awesome_outlined,
              tiklandiginda: () => _kombinOner(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Boş durum — dolap boş veya uygun kombin yok
  Widget _bosDurumu(BuildContext context, KombinDurum durum) {
    return BosDurum(
      ikon: Icons.checkroom_rounded,
      baslik: 'Uygun kombin bulunamadı',
      aciklama: durum.hataMesaji ??
          'Dolabına daha fazla kıyafet ekleyerek\nkombin çeşitliliğini artır.',
      butonMetni: 'Tekrar Dene',
      butonTiklandiginda: () => _kombinOner(context),
    );
  }

  /// Kombin hazır — parçaları göster
  Widget _kombinHazir(BuildContext context, KombinDurum durum) {
    final kombin = durum.kombin!;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: kToolbarHeight + 60,
        bottom: 120, // Navbar boşluğu
        left: AppBoyutlar.boslukBuyuk,
        right: AppBoyutlar.boslukBuyuk,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Etkinlik seçici
          _etkinlikSecici(context),

          const SizedBox(height: AppBoyutlar.boslukBuyuk),

          // Kombin parçaları
          if (kombin.ustGiyim != null)
            _parcaKarti(context, kombin.ustGiyim!, 'Üst Giyim',
                KiyafetKategorisi.ustGiyim),
          if (kombin.altGiyim != null)
            _parcaKarti(context, kombin.altGiyim!, 'Alt Giyim',
                KiyafetKategorisi.altGiyim),
          if (kombin.disGiyim != null)
            _parcaKarti(context, kombin.disGiyim!, 'Dış Giyim',
                KiyafetKategorisi.disGiyim),
          if (kombin.ayakkabi != null)
            _parcaKarti(context, kombin.ayakkabi!, 'Ayakkabı',
                KiyafetKategorisi.ayakkabi),
          if (kombin.aksesuar != null)
            _parcaKarti(context, kombin.aksesuar!, 'Aksesuar',
                KiyafetKategorisi.aksesuar),

          const SizedBox(height: AppBoyutlar.boslukBuyuk),

          // Kaydet butonu
          BirincilButon(
            metin: 'Kombini Kaydet',
            ikon: Icons.bookmark_border_rounded,
            tiklandiginda: () {
              context.read<KombinBloc>().add(const KombinKaydet());
            },
          ),

          const SizedBox(height: AppBoyutlar.boslukOrta),

          // Yenile butonu
          OutlinedButton.icon(
            onPressed: () => _kombinYenile(context),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Farklı Kombin Öner'),
          ),

          const SizedBox(height: AppBoyutlar.boslukBuyuk),
        ],
      ),
    );
  }

  /// Tek parça kartı
  Widget _parcaKarti(
    BuildContext context,
    KiyafetModeli kiyafet,
    String baslik,
    KiyafetKategorisi kategori,
  ) {
    final renkBilgisi = kiyafet.renkBilgisi;

    return Container(
      margin: const EdgeInsets.only(bottom: AppBoyutlar.boslukOrta),
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
      child: Row(
        children: [
          // Fotoğraf
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppBoyutlar.radiusBuyuk),
            ),
            child: SizedBox(
              width: 90,
              height: 90,
              child: CachedNetworkImage(
                imageUrl: kiyafet.kucukGorselUrl ?? kiyafet.gorselUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppRenkler.ikincilArkaPlan,
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppRenkler.ikincilArkaPlan,
                  child: const Icon(Icons.checkroom_rounded,
                      color: AppRenkler.deaktif),
                ),
              ),
            ),
          ),

          // Bilgi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppBoyutlar.boslukNormal,
                vertical: AppBoyutlar.boslukOrta,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: AppMetinStilleri.etiket.copyWith(
                      color: AppRenkler.metinUcuncul,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (renkBilgisi != null) ...[
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: Color(renkBilgisi.renkKodu),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppRenkler.ayirici, width: 0.5),
                          ),
                        ),
                        Text(
                          renkBilgisi.isim,
                          style: AppMetinStilleri.govdeNormal.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kiyafet.kalinlik.etiket,
                    style: AppMetinStilleri.govdeKucuk,
                  ),
                ],
              ),
            ),
          ),

          // Değiştir butonu
          IconButton(
            onPressed: () {
              final havaDurumu =
                  context.read<HavaDurumuBloc>().state.havaDurumu;
              context.read<KombinBloc>().add(
                    ParcaDegistirOlay(
                      kategori: kategori,
                      havaDurumu: havaDurumu,
                    ),
                  );
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 22),
            tooltip: 'Değiştir',
          ),
        ],
      ),
    );
  }

  /// Etkinlik tipi seçici
  Widget _etkinlikSecici(BuildContext context) {
    const etkinlikler = [
      {'id': 'gunluk', 'etiket': '☕ Günlük', 'ikon': Icons.coffee_rounded},
      {'id': 'is', 'etiket': '💼 İş', 'ikon': Icons.work_outline_rounded},
      {'id': 'ozel_davet', 'etiket': '🎉 Davet', 'ikon': Icons.celebration_rounded},
      {'id': 'spor', 'etiket': '🏃 Spor', 'ikon': Icons.fitness_center_rounded},
    ];

    return BlocBuilder<KombinBloc, KombinDurum>(
      builder: (context, durum) {
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: etkinlikler.map((etkinlik) {
              final secili = durum.seciliEtkinlik == etkinlik['id'];
              return Padding(
                padding: const EdgeInsets.only(right: AppBoyutlar.boslukKucuk),
                child: GestureDetector(
                  onTap: () {
                    context.read<KombinBloc>().add(
                          EtkinlikTipiDegistir(
                            etkinlikTipi: etkinlik['id'] as String,
                          ),
                        );
                  },
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
                      boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Text(
                      etkinlik['etiket'] as String,
                      style: AppMetinStilleri.etiket.copyWith(
                        color: secili ? AppRenkler.anaVurgu : AppRenkler.metinBirincil,
                        fontWeight: secili ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Kombin öner
  void _kombinOner(BuildContext context) {
    final havaDurumu = context.read<HavaDurumuBloc>().state.havaDurumu;
    context.read<KombinBloc>().add(KombinOner(havaDurumu: havaDurumu));
  }

  /// Yenile
  void _kombinYenile(BuildContext context) {
    final havaDurumu = context.read<HavaDurumuBloc>().state.havaDurumu;
    context.read<KombinBloc>().add(KombinYenile(havaDurumu: havaDurumu));
  }

  Widget _camHap(String metin, TextStyle stil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Text(metin, style: stil, textAlign: TextAlign.center),
    );
  }
}
