import 'package:flutter/material.dart';
import '../sabitler/renkler.dart';
import '../sabitler/boyutlar.dart';
import '../sabitler/metin_stilleri.dart';

/// Hata durumlarında gösterilen widget.
/// İkon + hata mesajı + tekrar dene butonu.
class HataDurumu extends StatelessWidget {
  /// Hata mesajı
  final String mesaj;

  /// Tekrar deneme işlevi
  final VoidCallback? tekrarDene;

  /// Özel ikon (varsayılan: hata ikonu)
  final IconData ikon;

  const HataDurumu({
    super.key,
    required this.mesaj,
    this.tekrarDene,
    this.ikon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppBoyutlar.boslukCokBuyuk),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hata ikonu
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppRenkler.hata.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ikon,
                size: 32,
                color: AppRenkler.hata.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: AppBoyutlar.boslukBuyuk),

            // Hata mesajı
            Text(
              mesaj,
              style: AppMetinStilleri.govdeNormal.copyWith(
                color: AppRenkler.metinIkincil,
              ),
              textAlign: TextAlign.center,
            ),

            // Tekrar dene butonu
            if (tekrarDene != null) ...[
              const SizedBox(height: AppBoyutlar.boslukNormal),
              TextButton.icon(
                onPressed: tekrarDene,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tekrar Dene'),
                style: TextButton.styleFrom(
                  foregroundColor: AppRenkler.anaVurgu,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
