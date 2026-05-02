import 'package:flutter/material.dart';
import '../sabitler/renkler.dart';
import '../sabitler/boyutlar.dart';
import '../sabitler/metin_stilleri.dart';

/// Ana aksiyon butonu — #C84153 arka plan, beyaz metin.
/// Tam genişlik, yuvarlak köşeler, opsiyonel ikon ve yükleniyor durumu.
class BirincilButon extends StatelessWidget {
  /// Buton metni
  final String metin;

  /// Tıklama işlevi
  final VoidCallback? tiklandiginda;

  /// Yükleniyor durumu — true ise spinner gösterilir
  final bool yukleniyor;

  /// Sol tarafta ikon (opsiyonel)
  final IconData? ikon;

  /// Tam genişlik mi
  final bool tamGenislik;

  /// Küçük versiyon mu
  final bool kucuk;

  const BirincilButon({
    super.key,
    required this.metin,
    this.tiklandiginda,
    this.yukleniyor = false,
    this.ikon,
    this.tamGenislik = true,
    this.kucuk = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamGenislik ? double.infinity : null,
      height: kucuk ? AppBoyutlar.butonKucukYuksekligi : AppBoyutlar.butonYuksekligi,
      child: ElevatedButton(
        onPressed: yukleniyor ? null : tiklandiginda,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppRenkler.anaVurgu,
          foregroundColor: AppRenkler.metinBeyaz,
          disabledBackgroundColor: AppRenkler.anaVurgu.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppBoyutlar.radiusYuvarlak,
            ),
          ),
        ),
        child: yukleniyor
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppRenkler.metinBeyaz,
                ),
              )
            : Row(
                mainAxisSize: tamGenislik ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ikon != null) ...[
                    Icon(ikon, size: kucuk ? 18 : 20),
                    const SizedBox(width: AppBoyutlar.boslukKucuk),
                  ],
                  Text(
                    metin,
                    style: kucuk
                        ? AppMetinStilleri.butonKucuk.copyWith(color: AppRenkler.metinBeyaz)
                        : AppMetinStilleri.butonBuyuk,
                  ),
                ],
              ),
      ),
    );
  }
}

/// İkincil buton — kenarlıklı, şeffaf arka plan.
class IkincilButon extends StatelessWidget {
  final String metin;
  final VoidCallback? tiklandiginda;
  final bool yukleniyor;
  final IconData? ikon;
  final bool tamGenislik;

  const IkincilButon({
    super.key,
    required this.metin,
    this.tiklandiginda,
    this.yukleniyor = false,
    this.ikon,
    this.tamGenislik = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamGenislik ? double.infinity : null,
      height: AppBoyutlar.butonYuksekligi,
      child: OutlinedButton(
        onPressed: yukleniyor ? null : tiklandiginda,
        child: yukleniyor
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppRenkler.anaVurgu,
                ),
              )
            : Row(
                mainAxisSize: tamGenislik ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ikon != null) ...[
                    Icon(ikon, size: 20),
                    const SizedBox(width: AppBoyutlar.boslukKucuk),
                  ],
                  Text(metin),
                ],
              ),
      ),
    );
  }
}
