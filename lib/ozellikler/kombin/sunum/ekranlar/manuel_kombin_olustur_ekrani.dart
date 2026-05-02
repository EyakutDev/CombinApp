import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/ozellikler/gardrop/alan/modeller/kiyafet_modeli.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/bloc/gardrop_bloc.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/bloc/gardrop_durum.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/bloc/gardrop_olay.dart';
import 'package:combin_app/ozellikler/kombin/sunum/bloc/kombin_bloc.dart';
import 'package:combin_app/ozellikler/kombin/alan/modeller/kombin_modeli.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_bloc.dart';
import 'package:combin_app/cekirdek/widgets/cam_snack_bar.dart';

class ManuelKombinOlusturEkrani extends StatefulWidget {
  final DateTime? atanacakGun;

  const ManuelKombinOlusturEkrani({super.key, this.atanacakGun});

  @override
  State<ManuelKombinOlusturEkrani> createState() => _ManuelKombinOlusturEkraniState();
}

class _ManuelKombinOlusturEkraniState extends State<ManuelKombinOlusturEkrani> {
  final Set<String> _seciliKiyafetIdleri = {};
  final List<KiyafetModeli> _seciliKiyafetler = [];
  final TextEditingController _isimController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<GardropBloc>().add(const KiyafetleriYukle());
  }

  @override
  void dispose() {
    _isimController.dispose();
    super.dispose();
  }

  void _kiyafetSecimiDegistir(KiyafetModeli kiyafet) {
    setState(() {
      if (_seciliKiyafetIdleri.contains(kiyafet.id)) {
        _seciliKiyafetIdleri.remove(kiyafet.id);
        _seciliKiyafetler.removeWhere((k) => k.id == kiyafet.id);
      } else {
        _seciliKiyafetIdleri.add(kiyafet.id);
        _seciliKiyafetler.add(kiyafet);
      }
    });
  }

  void _kombinKaydet() {
    if (_seciliKiyafetler.isEmpty) {
      CamSnackBar.uyari(context, 'Lütfen en az bir parça seçin.');
      return;
    }

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
              _camHapMetin('Kombine İsim Ver', AppMetinStilleri.baslikOrta),
              const SizedBox(height: AppBoyutlar.boslukOrta),
              TextField(
                controller: _isimController,
                decoration: InputDecoration(
                  hintText: 'Örn: Cuma Akşamı',
                  filled: true,
                  fillColor: AppRenkler.ikincilArkaPlan.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppBoyutlar.boslukBuyuk),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak)),
                      ),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: AppBoyutlar.boslukOrta),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final isim = _isimController.text.trim().isEmpty ? 'Manuel Kombin' : _isimController.text.trim();
                        final kullaniciId = context.read<KimlikBloc>().state.kullanici?.id ?? '';
                        
                        
                        final yeniKombin = KombinModeli(
                          kullaniciId: kullaniciId,
                          ustGiyim: _seciliKiyafetler.where((k) => k.kategori == KiyafetKategorisi.ustGiyim).firstOrNull,
                          altGiyim: _seciliKiyafetler.where((k) => k.kategori == KiyafetKategorisi.altGiyim).firstOrNull,
                          ayakkabi: _seciliKiyafetler.where((k) => k.kategori == KiyafetKategorisi.ayakkabi).firstOrNull,
                          disGiyim: _seciliKiyafetler.where((k) => k.kategori == KiyafetKategorisi.disGiyim).firstOrNull,
                          aksesuar: _seciliKiyafetler.where((k) => k.kategori == KiyafetKategorisi.aksesuar || k.kategori == KiyafetKategorisi.canta).firstOrNull,
                          olusturulmaTarihi: DateTime.now(),
                          etkinlikTipi: isim,
                        );

                        context.read<KombinBloc>().add(ManuelKombinKaydet(kombin: yeniKombin));

                        // Eğer plandan gelindiyse plana ata (Gelecekte KombinBloc'dan ID alınması gerekecek, şimdilik UI'da atama pas geçilebilir veya sahte id ile eklenebilir)
                        // Şimdilik sadece kaydediyoruz, plan ataması KombinBloc'un ID oluşturmasından sonra yapılmalı.
                        
                        Navigator.pop(ctx);
                        context.pop();
                        CamSnackBar.basari(context, '$isim başarıyla oluşturuldu!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppRenkler.anaVurgu,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak)),
                      ),
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _camHapMetin(String metin, TextStyle stil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppRenkler.camGolge,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(metin, style: stil, textAlign: TextAlign.center),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppRenkler.arkaPlan,
      appBar: AppBar(
        title: _camHapMetin('Manuel Kombin', AppMetinStilleri.baslikOrta),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppRenkler.metinBirincil),
      ),
      body: BlocBuilder<GardropBloc, GardropDurum>(
        builder: (context, durum) {
          if (durum.tip == GardropDurumTipi.yukleniyor) {
            return const Center(child: CircularProgressIndicator());
          }

          if (durum.kiyafetler.isEmpty) {
            return Center(
              child: _camHapMetin('Gardırobunda parça yok. Önce kıyafet ekle.', AppMetinStilleri.govdeNormal),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppBoyutlar.boslukNormal,
              crossAxisSpacing: AppBoyutlar.boslukNormal,
              childAspectRatio: 0.8,
            ),
            itemCount: durum.kiyafetler.length,
            itemBuilder: (context, index) {
              final kiyafet = durum.kiyafetler[index];
              final seciliMi = _seciliKiyafetIdleri.contains(kiyafet.id);

              return GestureDetector(
                onTap: () => _kiyafetSecimiDegistir(kiyafet),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
                    border: Border.all(
                      color: seciliMi ? AppRenkler.anaVurgu : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppRenkler.camGolge,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk - 3),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: kiyafet.gorselUrl,
                          fit: BoxFit.cover,
                        ),
                        if (seciliMi)
                          Container(
                            color: AppRenkler.anaVurgu.withValues(alpha: 0.3),
                            child: const Center(
                              child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _seciliKiyafetler.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _kombinKaydet,
              backgroundColor: AppRenkler.anaVurgu,
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: Text('Kaydet (${_seciliKiyafetler.length})', style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
