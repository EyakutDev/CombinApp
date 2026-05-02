import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/widgets/birincil_buton.dart';

class OnboardingEkrani extends StatefulWidget {
  const OnboardingEkrani({super.key});

  @override
  State<OnboardingEkrani> createState() => _OnboardingEkraniState();
}

class _OnboardingEkraniState extends State<OnboardingEkrani> {
  String? _seciliSehir = 'İstanbul';
  String? _seciliStil = 'Günlük';
  String? _seciliAmac = 'Ofis';
  bool _havaDurumuIzni = true;

  final List<String> _sehirler = ['İstanbul', 'Ankara', 'İzmir', 'Antalya', 'Bursa'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppRenkler.arkaPlan,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppBoyutlar.boslukCokBuyuk,
                left: AppBoyutlar.boslukBuyuk,
                right: AppBoyutlar.boslukBuyuk,
                bottom: 120, // Buton için boşluk
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _camHap('Seni daha iyi tanıyalım ✨', AppMetinStilleri.baslikBuyuk),
                  const SizedBox(height: AppBoyutlar.boslukKucuk),
                  _camHap(
                    'Dolabını senin için daha akıllı hale getirebilmemiz için birkaç sorumuz var.',
                    AppMetinStilleri.govdeKucuk,
                  ),
                  const SizedBox(height: AppBoyutlar.boslukDevasa),

                  // Şehir Seçimi
                  _camHap('Şehir', AppMetinStilleri.govdeKalin),
                  const SizedBox(height: AppBoyutlar.boslukNormal),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppBoyutlar.boslukNormal),
                    decoration: BoxDecoration(
                      color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _seciliSehir,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppRenkler.metinIkincil),
                        items: _sehirler.map((String sehir) {
                          return DropdownMenuItem<String>(
                            value: sehir,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppRenkler.metinIkincil, size: 20),
                                const SizedBox(width: AppBoyutlar.boslukKucuk),
                                Text(sehir, style: AppMetinStilleri.govdeKalin),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _seciliSehir = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

                  // Stil Tipi
                  _camHap('Stil Tipi', AppMetinStilleri.govdeKalin),
                  const SizedBox(height: AppBoyutlar.boslukNormal),
                  Row(
                    children: [
                      Expanded(child: _secenekButonu('Günlük', Icons.checkroom_rounded, _seciliStil, (v) => setState(() => _seciliStil = v))),
                      const SizedBox(width: AppBoyutlar.boslukNormal),
                      Expanded(child: _secenekButonu('Şık', Icons.accessibility_new_rounded, _seciliStil, (v) => setState(() => _seciliStil = v))),
                      const SizedBox(width: AppBoyutlar.boslukNormal),
                      Expanded(child: _secenekButonu('Minimal', Icons.dry_cleaning_rounded, _seciliStil, (v) => setState(() => _seciliStil = v))),
                      const SizedBox(width: AppBoyutlar.boslukNormal),
                      Expanded(child: _secenekButonu('Romantik', Icons.favorite_border_rounded, _seciliStil, (v) => setState(() => _seciliStil = v))),
                    ],
                  ),

                  const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

                  // Kullanım Amacı
                  _camHap('Kullanım Amacı', AppMetinStilleri.govdeKalin),
                  const SizedBox(height: AppBoyutlar.boslukNormal),
                  Row(
                    children: [
                      Expanded(child: _secenekButonu('Ofis', Icons.work_outline_rounded, _seciliAmac, (v) => setState(() => _seciliAmac = v))),
                      const SizedBox(width: AppBoyutlar.boslukNormal),
                      Expanded(child: _secenekButonu('Spor', Icons.fitness_center_rounded, _seciliAmac, (v) => setState(() => _seciliAmac = v))),
                      const SizedBox(width: AppBoyutlar.boslukNormal),
                      Expanded(child: _secenekButonu('Seyahat', Icons.flight_takeoff_rounded, _seciliAmac, (v) => setState(() => _seciliAmac = v))),
                      const SizedBox(width: AppBoyutlar.boslukNormal),
                      Expanded(child: _secenekButonu('Davet', Icons.star_border_rounded, _seciliAmac, (v) => setState(() => _seciliAmac = v))),
                    ],
                  ),

                  const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

                  // Hava Durumu İzni
                  _camHap('Hava Durumu İzni', AppMetinStilleri.govdeKalin),
                  const SizedBox(height: AppBoyutlar.boslukNormal),
                  Container(
                    padding: const EdgeInsets.all(AppBoyutlar.boslukNormal),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFA000)),
                        ),
                        const SizedBox(width: AppBoyutlar.boslukOrta),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hava durumu bilgisine eriş', style: AppMetinStilleri.govdeKalin),
                              const SizedBox(height: 4),
                              Text('Bulunduğun konuma göre kombin önerileri sunabilmemiz için hava durumu izni istiyoruz.', style: AppMetinStilleri.etiket.copyWith(height: 1.3)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _havaDurumuIzni,
                          onChanged: (val) => setState(() => _havaDurumuIzni = val),
                          activeTrackColor: AppRenkler.anaVurgu,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sabit Devam Et Butonu
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
                    metin: 'Devam Et',
                    tiklandiginda: () {
                      context.go('/'); // Ana sayfaya yönlendir
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secenekButonu(String etiket, IconData ikon, String? seciliDeger, Function(String) onSelect) {
    final secili = seciliDeger == etiket;
    return GestureDetector(
      onTap: () => onSelect(etiket),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppBoyutlar.boslukOrta),
            decoration: BoxDecoration(
              color: secili
                  ? AppRenkler.anaVurgu.withValues(alpha: 0.12)
                  : AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: secili
                    ? AppRenkler.anaVurgu.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppRenkler.camGolge,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              ikon,
              color: secili ? AppRenkler.anaVurgu : AppRenkler.metinIkincil,
              size: 28,
            ),
          ),
          const SizedBox(height: AppBoyutlar.boslukKucuk),
          Text(
            etiket,
            style: AppMetinStilleri.etiket.copyWith(
              color: secili ? AppRenkler.metinBirincil : AppRenkler.metinIkincil,
              fontWeight: secili ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
}
