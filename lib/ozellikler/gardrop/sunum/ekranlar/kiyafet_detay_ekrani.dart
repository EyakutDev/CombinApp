import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/widgets/birincil_buton.dart';
import '../../alan/modeller/kiyafet_modeli.dart';
import '../bloc/gardrop_bloc.dart';
import '../bloc/gardrop_olay.dart';

/// Kıyafet detay ekranı.
/// Tam boy fotoğraf, etiketler, favori, aksiyonlar.
class KiyafetDetayEkrani extends StatelessWidget {
  final KiyafetModeli kiyafet;

  /// Düzenle butonuna basıldığında callback
  final void Function(KiyafetModeli)? duzenleBasildi;

  /// "Bu parçayla kombin yap" callback
  final void Function(KiyafetModeli)? kombinYapBasildi;

  const KiyafetDetayEkrani({
    super.key,
    required this.kiyafet,
    this.duzenleBasildi,
    this.kombinYapBasildi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // === Büyük Fotoğraf AppBar ===
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Favori butonu
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    kiyafet.favori ? Icons.favorite : Icons.favorite_border,
                    color: kiyafet.favori ? AppRenkler.favoriKalp : Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  context.read<GardropBloc>().add(
                        FavoriDegistir(
                          kiyafetId: kiyafet.id,
                          favori: !kiyafet.favori,
                        ),
                      );
                },
              ),
              // Daha fazla menü
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert,
                      color: Colors.white, size: 18),
                ),
                onPressed: () => _dahaFazlaDialog(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: kiyafet.gorselUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppRenkler.ikincilArkaPlan,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppRenkler.ikincilArkaPlan,
                  child: const Icon(Icons.checkroom_rounded,
                      size: 64, color: AppRenkler.deaktif),
                ),
              ),
            ),
          ),

          // === Detay İçeriği ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori başlığı
                  Text(
                    kiyafet.kategori.etiket,
                    style: AppMetinStilleri.baslikBuyuk,
                  ),

                  const SizedBox(height: AppBoyutlar.boslukBuyuk),

                  // Etiketler
                  _etiketSatiri(
                    ikon: Icons.palette_outlined,
                    baslik: 'Renk',
                    deger: kiyafet.renkBilgisi?.isim ?? kiyafet.renk,
                    renkKodu: kiyafet.renkBilgisi?.renkKodu,
                  ),
                  const SizedBox(height: AppBoyutlar.boslukOrta),

                  _etiketSatiri(
                    ikon: Icons.thermostat_outlined,
                    baslik: 'Kalınlık',
                    deger: kiyafet.kalinlik.etiket,
                  ),
                  const SizedBox(height: AppBoyutlar.boslukOrta),

                  _etiketSatiri(
                    ikon: Icons.wb_sunny_outlined,
                    baslik: 'Mevsim',
                    deger: kiyafet.mevsimler.map((m) => m.etiket).join(', '),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

                  // Aksiyonlar
                  BirincilButon(
                    metin: 'Bu Parçayla Kombin Yap',
                    ikon: Icons.auto_awesome_outlined,
                    tiklandiginda: () => kombinYapBasildi?.call(kiyafet),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukOrta),

                  // Düzenle butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => duzenleBasildi?.call(kiyafet),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Düzenle'),
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukBuyuk),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Etiket satırı — ikon + başlık + değer
  Widget _etiketSatiri({
    required IconData ikon,
    required String baslik,
    required String deger,
    int? renkKodu,
  }) {
    return Row(
      children: [
        Icon(ikon, size: 20, color: AppRenkler.metinIkincil),
        const SizedBox(width: AppBoyutlar.boslukOrta),
        Text('$baslik: ', style: AppMetinStilleri.govdeKucuk),
        if (renkKodu != null) ...[
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Color(renkKodu),
              shape: BoxShape.circle,
              border: Border.all(color: AppRenkler.ayirici, width: 0.5),
            ),
          ),
        ],
        Text(
          deger,
          style: AppMetinStilleri.govdeNormal.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Daha fazla menü (sil, düzenle)
  void _dahaFazlaDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Düzenle'),
                onTap: () {
                  Navigator.pop(ctx);
                  duzenleBasildi?.call(kiyafet);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppRenkler.hata),
                title: Text(
                  'Sil',
                  style: AppMetinStilleri.govdeBuyuk.copyWith(
                    color: AppRenkler.hata,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _silOnayDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Silme onay dialogu
  void _silOnayDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppRenkler.arkaPlan.withValues(alpha: 0.8),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
          decoration: BoxDecoration(
            color: AppRenkler.kartArkaPlan.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppBoyutlar.radiusCokBuyuk),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppRenkler.camGolge,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppRenkler.hata.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, color: AppRenkler.hata, size: 36),
              ),
              const SizedBox(height: AppBoyutlar.boslukOrta),
              Text(
                'Kıyafeti Sil',
                style: AppMetinStilleri.baslikOrta,
              ),
              const SizedBox(height: AppBoyutlar.boslukKucuk),
              Text(
                'Bu kıyafeti silmek istediğinden emin misin? Bu işlem geri alınamaz.',
                style: AppMetinStilleri.govdeNormal,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppBoyutlar.boslukBuyuk),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                        ),
                      ),
                      child: Text('İptal', style: AppMetinStilleri.govdeKalin),
                    ),
                  ),
                  const SizedBox(width: AppBoyutlar.boslukOrta),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<GardropBloc>().add(
                              KiyafetSilEvent(kiyafetId: kiyafet.id),
                            );
                        Navigator.of(context).pop(); // Detay sayfasından çık
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppRenkler.hata,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                        ),
                      ),
                      child: Text('Sil', style: AppMetinStilleri.govdeKalin.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
