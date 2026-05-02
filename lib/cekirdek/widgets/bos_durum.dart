import 'package:flutter/material.dart';
import '../sabitler/renkler.dart';
import '../sabitler/boyutlar.dart';
import '../sabitler/metin_stilleri.dart';

/// Veri yok / boş liste durumlarında gösterilen widget.
/// İkon + başlık + açıklama + opsiyonel aksiyon butonu.
class BosDurum extends StatelessWidget {
  /// Gösterilecek ikon
  final IconData ikon;

  /// Ana başlık
  final String baslik;

  /// Açıklama metni
  final String aciklama;

  /// Aksiyon butonu metni (opsiyonel)
  final String? butonMetni;

  /// Aksiyon butonu tıklama işlevi
  final VoidCallback? butonTiklandiginda;

  const BosDurum({
    super.key,
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    this.butonMetni,
    this.butonTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppBoyutlar.boslukCokBuyuk),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İkon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppRenkler.anaVurgu.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ikon,
                size: 36,
                color: AppRenkler.anaVurgu.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: AppBoyutlar.boslukBuyuk),

            // Başlık
            Text(
              baslik,
              style: AppMetinStilleri.baslikKucuk,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppBoyutlar.boslukKucuk),

            // Açıklama
            Text(
              aciklama,
              style: AppMetinStilleri.govdeKucuk,
              textAlign: TextAlign.center,
            ),

            // Aksiyon butonu
            if (butonMetni != null && butonTiklandiginda != null) ...[
              const SizedBox(height: AppBoyutlar.boslukBuyuk),
              TextButton.icon(
                onPressed: butonTiklandiginda,
                icon: const Icon(Icons.add, size: 18),
                label: Text(butonMetni!),
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
