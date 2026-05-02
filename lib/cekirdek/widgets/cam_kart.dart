import 'dart:ui';
import 'package:flutter/material.dart';
import '../sabitler/renkler.dart';
import '../sabitler/boyutlar.dart';

/// Liquid Glass estetiğinde cam kartı widget'ı.
/// Arka plan bulanıklaştırma, yarı saydam beyaz dolgu, yumuşak kenarlık.
class CamKart extends StatelessWidget {
  /// Kart içeriği
  final Widget cocuk;

  /// Ek padding (varsayılan: 16)
  final EdgeInsetsGeometry? icBosluk;

  /// Ek margin
  final EdgeInsetsGeometry? disBosluk;

  /// Bulanıklaştırma miktarı (varsayılan: 40)
  final double bulaniklik;

  /// Kenarlık gösterilsin mi
  final bool kenarlikGoster;

  /// Tıklama işlevi
  final VoidCallback? tiklandiginda;

  /// Kart yüksekliği (opsiyonel)
  final double? yukseklik;

  /// Kart genişliği (opsiyonel)
  final double? genislik;

  const CamKart({
    super.key,
    required this.cocuk,
    this.icBosluk,
    this.disBosluk,
    this.bulaniklik = 10.0,
    this.kenarlikGoster = true,
    this.tiklandiginda,
    this.yukseklik,
    this.genislik,
  });

  @override
  Widget build(BuildContext context) {
    final kart = ClipRRect(
      borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: bulaniklik,
          sigmaY: bulaniklik,
        ),
        child: Container(
          height: yukseklik,
          width: genislik,
          padding: icBosluk ?? const EdgeInsets.all(AppBoyutlar.boslukNormal),
          decoration: BoxDecoration(
            color: AppRenkler.camArkaPlan,
            borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
            border: kenarlikGoster
                ? Border.all(
                    color: AppRenkler.camKenarlik,
                    width: 1.0,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppRenkler.camGolge,
                blurRadius: 24.0, // AppBoyutlar'ı beklememek için sabit yaygın gölge
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: cocuk,
        ),
      ),
    );

    // Tıklanabilir versiyon
    if (tiklandiginda != null) {
      return Padding(
        padding: disBosluk ?? EdgeInsets.zero,
        child: GestureDetector(
          onTap: tiklandiginda,
          child: kart,
        ),
      );
    }

    return Padding(
      padding: disBosluk ?? EdgeInsets.zero,
      child: kart,
    );
  }
}
