import 'package:flutter/material.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';

/// Liquid Glass temalı SnackBar yardımcı sınıfı.
/// Tüm uygulama genelinde tutarlı bildirim deneyimi sağlar.
class CamSnackBar {
  CamSnackBar._();

  /// Başarı bildirimi
  static void basari(BuildContext context, String mesaj) {
    _goster(
      context,
      mesaj: mesaj,
      ikon: Icons.check_circle_rounded,
      ikonRengi: AppRenkler.basari,
      kenarRengi: AppRenkler.basari.withValues(alpha: 0.3),
    );
  }

  /// Hata bildirimi
  static void hata(BuildContext context, String mesaj) {
    _goster(
      context,
      mesaj: mesaj,
      ikon: Icons.error_rounded,
      ikonRengi: AppRenkler.hata,
      kenarRengi: AppRenkler.hata.withValues(alpha: 0.3),
    );
  }

  /// Bilgi bildirimi
  static void bilgi(BuildContext context, String mesaj) {
    _goster(
      context,
      mesaj: mesaj,
      ikon: Icons.info_rounded,
      ikonRengi: AppRenkler.anaVurgu,
      kenarRengi: AppRenkler.anaVurgu.withValues(alpha: 0.3),
    );
  }

  /// Uyarı bildirimi
  static void uyari(BuildContext context, String mesaj) {
    _goster(
      context,
      mesaj: mesaj,
      ikon: Icons.warning_rounded,
      ikonRengi: const Color(0xFFF59E0B),
      kenarRengi: const Color(0xFFF59E0B).withValues(alpha: 0.3),
    );
  }

  static void _goster(
    BuildContext context, {
    required String mesaj,
    required IconData ikon,
    required Color ikonRengi,
    required Color kenarRengi,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppRenkler.kartArkaPlan.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
            border: Border.all(color: kenarRengi),
            boxShadow: [
              BoxShadow(
                color: AppRenkler.camGolge,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ikonRengi.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(ikon, color: ikonRengi, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mesaj,
                  style: AppMetinStilleri.govdeNormal.copyWith(
                    color: AppRenkler.metinBirincil,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
