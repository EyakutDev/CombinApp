import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/ozellikler/kombin/sunum/bloc/kombin_bloc.dart';
import 'package:combin_app/ozellikler/plan/alan/modeller/plan_modeli.dart';
import 'package:combin_app/ozellikler/plan/sunum/bloc/plan_bloc.dart';
import 'package:combin_app/cekirdek/widgets/cam_snack_bar.dart';

/// Belirli bir güne kombin atamak için açılan modal.
class KombinSeciciModal extends StatefulWidget {
  final DateTime gun;

  const KombinSeciciModal({super.key, required this.gun});

  static void goster(BuildContext context, DateTime gun) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KombinSeciciModal(gun: gun),
    );
  }

  @override
  State<KombinSeciciModal> createState() => _KombinSeciciModalState();
}

class _KombinSeciciModalState extends State<KombinSeciciModal> {
  @override
  void initState() {
    super.initState();
    // Modal açıldığında kayıtlı kombinleri getir
    context.read<KombinBloc>().add(const KayitliKombinleriGetir());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppRenkler.arkaPlan,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBoyutlar.radiusBuyuk),
        ),
      ),
      child: Column(
        children: [
          // Tutamak
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppRenkler.ayirici,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppBoyutlar.boslukNormal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kombin Seç',
                  style: AppMetinStilleri.baslikOrta,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppRenkler.ayirici),
          
          // Hızlı Seçenekler (Yeni Öner vs)
          Padding(
            padding: const EdgeInsets.all(AppBoyutlar.boslukNormal),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      CamSnackBar.bilgi(context, 'Kombin ekranından yeni öneri alabilirsiniz.');
                    },
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text('Yeni Öneri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppRenkler.anaVurgu.withValues(alpha: 0.1),
                      foregroundColor: AppRenkler.anaVurgu,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: AppBoyutlar.boslukNormal),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/manuel-kombin', extra: widget.gun);
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Manuel Oluştur'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppRenkler.metinBirincil,
                      side: const BorderSide(color: AppRenkler.ayirici),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Kayıtlı Kombinler Listesi
          Expanded(
            child: BlocBuilder<KombinBloc, KombinDurum>(
              builder: (context, durum) {
                if (durum.kayitliKombinler.isEmpty) {
                  return const Center(
                    child: Text('Kaydedilmiş kombin bulunamadı.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppBoyutlar.boslukNormal),
                  itemCount: durum.kayitliKombinler.length,
                  itemBuilder: (context, index) {
                    final kombin = durum.kayitliKombinler[index];
                    // Kombinin ilk görselini al
                    final ilkParca = kombin.tumParcalar.isNotEmpty 
                        ? kombin.tumParcalar.first 
                        : null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppBoyutlar.boslukNormal),
                      color: AppRenkler.kartArkaPlan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBoyutlar.radiusNormal),
                        side: BorderSide(color: AppRenkler.ayirici),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppRenkler.ikincilArkaPlan,
                            borderRadius: BorderRadius.circular(AppBoyutlar.radiusKucuk),
                          ),
                          child: ilkParca != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(AppBoyutlar.radiusKucuk),
                                  child: CachedNetworkImage(
                                    imageUrl: ilkParca.kucukGorselUrl ?? ilkParca.gorselUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Icon(Icons.checkroom_rounded),
                                    errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                                  ),
                                )
                              : const Icon(Icons.checkroom_rounded),
                        ),
                        title: Text(
                          kombin.etkinlikTipi ?? 'Günlük Kombin',
                          style: AppMetinStilleri.govdeNormal.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${kombin.parcaSayisi} parça',
                          style: AppMetinStilleri.govdeKucuk,
                        ),
                        trailing: OutlinedButton(
                          onPressed: () {
                            if (kombin.id != null) {
                              final plan = PlanModeli(
                                kullaniciId: '', // BLoC dolduracak
                                kombinId: kombin.id!,
                                tarih: widget.gun,
                                kombin: kombin,
                              );
                              context.read<PlanBloc>().add(
                                GunePlanAta(tarih: widget.gun, plan: plan)
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppRenkler.anaVurgu,
                            side: const BorderSide(color: AppRenkler.anaVurgu),
                          ),
                          child: const Text('Ata'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
