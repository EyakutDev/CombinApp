import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/widgets/bos_durum.dart';
import 'package:combin_app/cekirdek/widgets/yukleniyor.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/plan_bloc.dart';
import '../widgetlar/kombin_secici_modal.dart';
import 'package:combin_app/cekirdek/widgets/cam_app_bar.dart';

/// Haftalık plan ekranı — 7 günlük takvim, güne kombin ata.
class PlanEkraniTam extends StatefulWidget {
  const PlanEkraniTam({super.key});

  @override
  State<PlanEkraniTam> createState() => _PlanEkraniTamState();
}

class _PlanEkraniTamState extends State<PlanEkraniTam> {
  @override
  void initState() {
    super.initState();
    // Bu haftayı yükle
    final pazartesi = PlanBloc.buHaftaninPazartesisi();
    context.read<PlanBloc>().add(HaftaPlanYukle(haftaninIlkGunu: pazartesi));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CamAppBar(
        title: const Text('Haftalık Plan'),
        arkaPlanRengi: Colors.white.withValues(alpha: 0.6),
        bulaniklik: 20.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: BlocBuilder<PlanBloc, PlanDurum>(
            builder: (context, durum) {
              if (durum.hafta == null) return const SizedBox.shrink();
              return _haftaNavigasyonu(context, durum);
            },
          ),
        ),
      ),
      body: BlocBuilder<PlanBloc, PlanDurum>(
        builder: (context, durum) {
          if (durum.tip == PlanDurumTipi.yukleniyor) {
            return const Yukleniyor();
          }

          if (durum.hafta == null) {
            return const BosDurum(
              ikon: Icons.calendar_today_outlined,
              baslik: 'Plan yüklenemedi',
              aciklama: 'Tekrar dene.',
            );
          }

          return _anaIcerik(context, durum);
        },
      ),
    );
  }

  Widget _anaIcerik(BuildContext context, PlanDurum durum) {
    final hafta = durum.hafta!;
    final bugun = DateTime.now();
    final bugunNormal = DateTime(bugun.year, bugun.month, bugun.day);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: kToolbarHeight + 160,
        bottom: 140,
        left: AppBoyutlar.boslukBuyuk,
        right: AppBoyutlar.boslukBuyuk,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bugünün Planı
          _camHap('Bugünün Planı', AppMetinStilleri.baslikKucuk),
          const SizedBox(height: AppBoyutlar.boslukOrta),
          _bugununPlaniKarti(context, bugun, hafta.gunPlan(bugun)),

          const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

          // Bu Hafta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _camHap('Bu Hafta', AppMetinStilleri.baslikKucuk),
              GestureDetector(
                onTap: () {},
                child: _camHap(
                  'Tümünü Gör →',
                  AppMetinStilleri.etiket.copyWith(color: AppRenkler.anaVurgu, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppBoyutlar.boslukOrta),
          
          // Diğer Günler
          ...hafta.haftaGunleri.where((g) => DateTime(g.year, g.month, g.day) != bugunNormal).map((gun) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppBoyutlar.boslukOrta),
              child: _gunKarti(context, gun, hafta.gunPlan(gun)),
            );
          }),
        ],
      ),
    );
  }

  /// Hafta navigasyonu — yatay takvim tasarımı
  Widget _haftaNavigasyonu(BuildContext context, PlanDurum durum) {
    final hafta = durum.hafta!;
    final bugun = DateTime.now();
    final bugunNormal = DateTime(bugun.year, bugun.month, bugun.day);

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(
        horizontal: AppBoyutlar.boslukNormal,
        vertical: AppBoyutlar.boslukKucuk,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: hafta.haftaGunleri.map((gun) {
          final gunNormal = DateTime(gun.year, gun.month, gun.day);
          final bugunMu = gunNormal == bugunNormal;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _gunKisaltma(gun.weekday),
                style: AppMetinStilleri.etiket.copyWith(
                  color: bugunMu ? AppRenkler.anaVurgu : AppRenkler.metinIkincil,
                  fontWeight: bugunMu ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 48,
                decoration: BoxDecoration(
                  color: bugunMu ? AppRenkler.anaVurgu : AppRenkler.kartArkaPlan.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: bugunMu ? AppRenkler.anaVurgu : Colors.white.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppRenkler.camGolge,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${gun.day}',
                  style: AppMetinStilleri.baslikKucuk.copyWith(
                    color: bugunMu ? Colors.white : AppRenkler.metinBirincil,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Bugünün planı dev kartı
  Widget _bugununPlaniKarti(BuildContext context, DateTime gun, dynamic plan) {
    return Container(
      width: double.infinity,
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
      child: plan != null && plan.kombin != null && plan.kombin.tumParcalar.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Etiketler
                Padding(
                  padding: const EdgeInsets.all(AppBoyutlar.boslukNormal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppRenkler.anaVurgu.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_border_rounded, color: AppRenkler.anaVurgu, size: 16),
                            const SizedBox(width: 4),
                            Text('Ofis', style: AppMetinStilleri.etiket.copyWith(color: AppRenkler.anaVurgu, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<PlanBloc>().add(PlanKaldir(tarih: gun));
                        },
                        icon: const Icon(Icons.close_rounded, color: AppRenkler.metinUcuncul, size: 20),
                      ),
                    ],
                  ),
                ),
                // Görsel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppBoyutlar.boslukNormal),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
                    child: CachedNetworkImage(
                      imageUrl: plan.kombin.tumParcalar.first.gorselUrl,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppRenkler.ikincilArkaPlan, height: 250),
                      errorWidget: (context, url, error) => Container(color: AppRenkler.ikincilArkaPlan, height: 250, child: const Icon(Icons.error_outline)),
                    ),
                  ),
                ),
                // Hava Durumu ve Güvenle etiketi
                Padding(
                  padding: const EdgeInsets.all(AppBoyutlar.boslukNormal),
                  child: Row(
                    children: [
                      const Text('⛅', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('24°', style: AppMetinStilleri.baslikKucuk),
                          Text('Parçalı Bulutlu', style: AppMetinStilleri.etiket),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.check_circle_rounded, color: AppRenkler.basari),
                      const SizedBox(width: 4),
                      Text('Güvenle', style: AppMetinStilleri.govdeKucuk.copyWith(color: AppRenkler.basari, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: () => _kombinAtaDialog(context, gun),
              child: Padding(
                padding: const EdgeInsets.all(AppBoyutlar.boslukCokBuyuk),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppRenkler.ikincilArkaPlan,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppRenkler.ayirici),
                      ),
                      child: const Icon(Icons.add_rounded, color: AppRenkler.deaktif, size: 32),
                    ),
                    const SizedBox(height: AppBoyutlar.boslukOrta),
                    Text('Bugün için kombin ata', style: AppMetinStilleri.govdeNormal),
                  ],
                ),
              ),
            ),
    );
  }

  /// Standart gün listesi kartı (Bu Hafta bölümü için)
  Widget _gunKarti(
    BuildContext context,
    DateTime gun,
    dynamic plan,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusCokBuyuk),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppRenkler.camGolge,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppBoyutlar.boslukNormal),
        child: Row(
          children: [
            // Tarih Sütunu
            Column(
              children: [
                Text(
                  _gunAdi(gun.weekday),
                  style: AppMetinStilleri.govdeKalin.copyWith(color: AppRenkler.metinBirincil),
                ),
                Text(
                  '${gun.day} ${_ayAdi(gun.month)}',
                  style: AppMetinStilleri.etiket,
                ),
              ],
            ),

            const SizedBox(width: AppBoyutlar.boslukBuyuk),

            // Plan içeriği
            Expanded(
              child: plan != null && plan.kombin != null && plan.kombin.tumParcalar.isNotEmpty
                  ? Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppBoyutlar.radiusNormal),
                          child: CachedNetworkImage(
                            imageUrl: plan.kombin.tumParcalar.first.kucukGorselUrl ?? plan.kombin.tumParcalar.first.gorselUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: AppBoyutlar.boslukOrta),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ofis Şıklığı', // Temsili
                                style: AppMetinStilleri.govdeNormal.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppRenkler.metinUcuncul),
                          onPressed: () {
                            context.read<PlanBloc>().add(PlanKaldir(tarih: gun));
                          },
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => _kombinAtaDialog(context, gun),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppRenkler.ikincilArkaPlan,
                              borderRadius:
                                  BorderRadius.circular(AppBoyutlar.radiusNormal),
                              border: Border.all(
                                color: AppRenkler.ayirici,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppRenkler.deaktif,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppBoyutlar.boslukOrta),
                          Text(
                            'Kombin ata',
                            style: AppMetinStilleri.govdeNormal.copyWith(
                              color: AppRenkler.metinIkincil,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kombin ata dialog'u
  void _kombinAtaDialog(BuildContext context, DateTime gun) {
    KombinSeciciModal.goster(context, gun);
  }

  // === Yardımcı ===

  String _gunKisaltma(int weekday) {
    const gunler = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return gunler[weekday - 1];
  }

  String _gunAdi(int weekday) {
    const gunler = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe',
      'Cuma', 'Cumartesi', 'Pazar'
    ];
    return gunler[weekday - 1];
  }

  String _ayAdi(int month) {
    const aylar = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return aylar[month - 1];
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
}
