import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/ozellikler/ana_sayfa/sunum/ekranlar/tab_ekranlari.dart';

/// 5 tab'lı alt navbar shell.
/// IndexedStack ile tab bazlı state korunur.
/// Buzlu cam efektli navbar arka planı.
class AnaKabuk extends StatefulWidget {
  /// Başlangıç tab indeksi (deep link desteği için)
  final int baslangicIndeksi;

  const AnaKabuk({super.key, this.baslangicIndeksi = 0});

  @override
  State<AnaKabuk> createState() => _AnaKabukState();
}

class _AnaKabukState extends State<AnaKabuk> {
  late int _seciliIndeks;

  // Tab ekranları — IndexedStack ile state korunur
  final List<Widget> _ekranlar = const [
    AnaSayfaEkrani(),
    GardropEkrani(),
    KombinEkrani(),
    PlanEkrani(),
    ProfilEkrani(),
  ];

  @override
  void initState() {
    super.initState();
    _seciliIndeks = widget.baslangicIndeksi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _seciliIndeks,
        children: _ekranlar,
      ),
      extendBody: true, // Navbar arkasına içerik uzansın (blur efekti için)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppRenkler.navbarArkaPlan,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: AppBoyutlar.navbarYuksekligi + 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _navbarOgesi(
                              indeks: 0,
                              ikon: Icons.home_outlined,
                              seciliIkon: Icons.home_rounded,
                              etiket: 'Ana Sayfa',
                            ),
                            _navbarOgesi(
                              indeks: 1,
                              ikon: Icons.checkroom_outlined,
                              seciliIkon: Icons.checkroom_rounded,
                              etiket: 'Gardırop',
                            ),
                            _navbarOgesi(
                              indeks: 2,
                              ikon: Icons.auto_awesome_outlined,
                              seciliIkon: Icons.auto_awesome,
                              etiket: 'Kombin',
                            ),
                            _navbarOgesi(
                              indeks: 3,
                              ikon: Icons.calendar_today_outlined,
                              seciliIkon: Icons.calendar_today_rounded,
                              etiket: 'Plan',
                            ),
                            _navbarOgesi(
                              indeks: 4,
                              ikon: Icons.person_outline_rounded,
                              seciliIkon: Icons.person_rounded,
                              etiket: 'Profil',
                            ),
                          ],
                        ),
                      ),
                      if (Platform.isIOS)
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2), // Cam görünümüne uygun hafif bir çizgi
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navbarOgesi({
    required int indeks,
    required IconData ikon,
    required IconData seciliIkon,
    required String etiket,
  }) {
    final secili = _seciliIndeks == indeks;
    return GestureDetector(
      onTap: () {
        setState(() => _seciliIndeks = indeks);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                secili ? seciliIkon : ikon,
                key: ValueKey(secili),
                size: 24,
                color: secili
                    ? AppRenkler.navbarSecili
                    : AppRenkler.navbarSecilmemis,
              ),
            ),
            const SizedBox(height: 4),
            // Etiket
            Text(
              etiket,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: secili ? FontWeight.w600 : FontWeight.w500,
                color: secili
                    ? AppRenkler.navbarSecili
                    : AppRenkler.navbarSecilmemis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
