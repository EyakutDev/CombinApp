import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/widgets/bos_durum.dart';
import 'package:combin_app/ozellikler/kombin/sunum/bloc/kombin_bloc.dart';
import 'package:combin_app/ozellikler/kombin/alan/modeller/kombin_modeli.dart';
import 'package:combin_app/ozellikler/gardrop/alan/modeller/kiyafet_modeli.dart';

class KayitliKombinlerEkrani extends StatefulWidget {
  const KayitliKombinlerEkrani({super.key});

  @override
  State<KayitliKombinlerEkrani> createState() => _KayitliKombinlerEkraniState();
}

class _KayitliKombinlerEkraniState extends State<KayitliKombinlerEkrani> {
  @override
  void initState() {
    super.initState();
    context.read<KombinBloc>().add(const KayitliKombinleriGetir());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlı Kombinler'),
      ),
      body: BlocBuilder<KombinBloc, KombinDurum>(
        builder: (context, durum) {
          if (durum.kayitliKombinler.isEmpty) {
            return const BosDurum(
              ikon: Icons.bookmark_border_rounded,
              baslik: 'Henüz kombin kaydetmedin',
              aciklama: 'Beğendiğin kombinleri kaydederek buraya ekleyebilirsin.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppBoyutlar.boslukBuyuk),
            itemCount: durum.kayitliKombinler.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppBoyutlar.boslukBuyuk),
            itemBuilder: (context, index) {
              final kombin = durum.kayitliKombinler[index];
              return _KombinKarti(kombin: kombin);
            },
          );
        },
      ),
    );
  }
}

class _KombinKarti extends StatelessWidget {
  final KombinModeli kombin;

  const _KombinKarti({required this.kombin});

  @override
  Widget build(BuildContext context) {
    final parcalar = kombin.tumParcalar;
    
    return Container(
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan,
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusNormal),
        border: Border.all(color: AppRenkler.ayirici),
      ),
      padding: const EdgeInsets.all(AppBoyutlar.boslukOrta),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (kombin.etkinlikTipi != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppBoyutlar.boslukOrta,
                    vertical: AppBoyutlar.boslukKucuk,
                  ),
                  decoration: BoxDecoration(
                    color: AppRenkler.anaVurgu.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppBoyutlar.radiusKucuk),
                  ),
                  child: Text(
                    _etkinlikEtiketiGetir(kombin.etkinlikTipi!),
                    style: AppMetinStilleri.etiket.copyWith(
                      color: AppRenkler.anaVurgu,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              IconButton(
                onPressed: () {
                  // İleride silme eklenecek
                },
                icon: const Icon(Icons.bookmark_rounded, color: AppRenkler.anaVurgu),
                tooltip: 'Kaydedilenlerden Çıkar',
              ),
            ],
          ),
          const SizedBox(height: AppBoyutlar.boslukOrta),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: parcalar.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppBoyutlar.boslukOrta),
              itemBuilder: (context, index) {
                return _ParcaOnizleme(kiyafet: parcalar[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _etkinlikEtiketiGetir(String etkinlikTipi) {
    switch (etkinlikTipi) {
      case 'gunluk':
        return '☕ Günlük';
      case 'is':
        return '💼 İş';
      case 'ozel_davet':
        return '🎉 Davet';
      case 'spor':
        return '🏃 Spor';
      default:
        return etkinlikTipi;
    }
  }
}

class _ParcaOnizleme extends StatelessWidget {
  final KiyafetModeli kiyafet;

  const _ParcaOnizleme({required this.kiyafet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusKucuk),
        border: Border.all(color: AppRenkler.ayirici),
      ),
      clipBehavior: Clip.hardEdge,
      child: CachedNetworkImage(
        imageUrl: kiyafet.kucukGorselUrl ?? kiyafet.gorselUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppRenkler.ikincilArkaPlan,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppRenkler.ikincilArkaPlan,
          child: const Icon(Icons.checkroom_rounded, color: AppRenkler.deaktif),
        ),
      ),
    );
  }
}
