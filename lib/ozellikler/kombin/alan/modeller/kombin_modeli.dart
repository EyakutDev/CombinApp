import 'package:equatable/equatable.dart';
import 'package:combin_app/ozellikler/gardrop/alan/modeller/kiyafet_modeli.dart';

/// Kombin modeli — kombin motorunun çıktısı.
class KombinModeli extends Equatable {
  final String? id;
  final String? kullaniciId;
  final KiyafetModeli? ustGiyim;
  final KiyafetModeli? altGiyim;
  final KiyafetModeli? disGiyim;
  final KiyafetModeli? ayakkabi;
  final KiyafetModeli? aksesuar;
  final String? etkinlikTipi;
  final bool favori;
  final String? notlar;
  final DateTime? olusturulmaTarihi;

  const KombinModeli({
    this.id,
    this.kullaniciId,
    this.ustGiyim,
    this.altGiyim,
    this.disGiyim,
    this.ayakkabi,
    this.aksesuar,
    this.etkinlikTipi,
    this.favori = false,
    this.notlar,
    this.olusturulmaTarihi,
  });

  /// Kombin geçerli mi? En az üst + alt olmalı.
  bool get gecerli => ustGiyim != null && altGiyim != null;

  /// Kombindeki tüm parçalar
  List<KiyafetModeli> get tumParcalar {
    return [ustGiyim, altGiyim, disGiyim, ayakkabi, aksesuar]
        .whereType<KiyafetModeli>()
        .toList();
  }

  /// Parça sayısı
  int get parcaSayisi => tumParcalar.length;

  /// Belirli bir pozisyondaki parçayı değiştir
  KombinModeli parcaDegistir(KiyafetModeli yeniParca) {
    switch (yeniParca.kategori) {
      case KiyafetKategorisi.ustGiyim:
        return kopyala(ustGiyim: yeniParca);
      case KiyafetKategorisi.altGiyim:
        return kopyala(altGiyim: yeniParca);
      case KiyafetKategorisi.disGiyim:
        return kopyala(disGiyim: yeniParca);
      case KiyafetKategorisi.ayakkabi:
        return kopyala(ayakkabi: yeniParca);
      case KiyafetKategorisi.aksesuar:
      case KiyafetKategorisi.canta:
        return kopyala(aksesuar: yeniParca);
    }
  }

  KombinModeli kopyala({
    String? id,
    String? kullaniciId,
    KiyafetModeli? ustGiyim,
    KiyafetModeli? altGiyim,
    KiyafetModeli? disGiyim,
    KiyafetModeli? ayakkabi,
    KiyafetModeli? aksesuar,
    String? etkinlikTipi,
    bool? favori,
    String? notlar,
  }) {
    return KombinModeli(
      id: id ?? this.id,
      kullaniciId: kullaniciId ?? this.kullaniciId,
      ustGiyim: ustGiyim ?? this.ustGiyim,
      altGiyim: altGiyim ?? this.altGiyim,
      disGiyim: disGiyim ?? this.disGiyim,
      ayakkabi: ayakkabi ?? this.ayakkabi,
      aksesuar: aksesuar ?? this.aksesuar,
      etkinlikTipi: etkinlikTipi ?? this.etkinlikTipi,
      favori: favori ?? this.favori,
      notlar: notlar ?? this.notlar,
      olusturulmaTarihi: olusturulmaTarihi,
    );
  }

  /// Supabase'e kaydetmek için JSON
  Map<String, dynamic> toJson() {
    return {
      if (kullaniciId != null) 'kullanici_id': kullaniciId,
      'etkinlik_tipi': etkinlikTipi,
      'favori': favori,
      'notlar': notlar,
    };
  }

  /// Supabase'den gelen JSON'ı parse et (nested yapı: kombinler -> kombin_parcalari -> kiyafetler)
  factory KombinModeli.fromJson(Map<String, dynamic> json) {
    KiyafetModeli? ustGiyim;
    KiyafetModeli? altGiyim;
    KiyafetModeli? disGiyim;
    KiyafetModeli? ayakkabi;
    KiyafetModeli? aksesuar;

    if (json['kombin_parcalari'] != null) {
      final parcalar = json['kombin_parcalari'] as List<dynamic>;
      for (var parca in parcalar) {
        final kiyafetJson = parca['kiyafetler'] as Map<String, dynamic>?;
        if (kiyafetJson == null) continue;

        final kiyafet = KiyafetModeli.fromJson(kiyafetJson);
        final rol = parca['rol'] as String?;

        switch (rol) {
          case 'ust':
            ustGiyim = kiyafet;
            break;
          case 'alt':
            altGiyim = kiyafet;
            break;
          case 'dis':
            disGiyim = kiyafet;
            break;
          case 'ayakkabi':
            ayakkabi = kiyafet;
            break;
          case 'aksesuar':
            aksesuar = kiyafet;
            break;
        }
      }
    }

    return KombinModeli(
      id: json['id'] as String?,
      kullaniciId: json['kullanici_id'] as String?,
      ustGiyim: ustGiyim,
      altGiyim: altGiyim,
      disGiyim: disGiyim,
      ayakkabi: ayakkabi,
      aksesuar: aksesuar,
      etkinlikTipi: json['etkinlik_tipi'] as String?,
      favori: json['favori'] as bool? ?? false,
      notlar: json['notlar'] as String?,
      olusturulmaTarihi: json['olusturulma_tarihi'] != null 
          ? DateTime.parse(json['olusturulma_tarihi'] as String) 
          : null,
    );
  }

  /// Kombin parçalarını JSON'a çevir (kombin_parcalari tablosu için)
  List<Map<String, dynamic>> parcalariJson(String kombinId) {
    final parcalar = <Map<String, dynamic>>[];
    int sira = 0;

    void ekle(KiyafetModeli? kiyafet, String rol) {
      if (kiyafet != null) {
        parcalar.add({
          'kombin_id': kombinId,
          'kiyafet_id': kiyafet.id,
          'rol': rol,
          'sira': sira++,
        });
      }
    }

    ekle(ustGiyim, 'ust');
    ekle(altGiyim, 'alt');
    ekle(disGiyim, 'dis');
    ekle(ayakkabi, 'ayakkabi');
    ekle(aksesuar, 'aksesuar');

    return parcalar;
  }

  @override
  List<Object?> get props => [
        id, ustGiyim, altGiyim, disGiyim, ayakkabi, aksesuar,
        etkinlikTipi, favori,
      ];
}
