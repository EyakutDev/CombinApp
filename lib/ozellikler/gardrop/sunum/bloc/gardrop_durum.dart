import 'package:equatable/equatable.dart';
import '../../alan/modeller/kiyafet_modeli.dart';

/// Gardırop durumları.
enum GardropDurumTipi {
  baslangic,
  yukleniyor,
  yuklendi,
  hata,
}

class GardropDurum extends Equatable {
  final GardropDurumTipi tip;
  final List<KiyafetModeli> kiyafetler;
  final KiyafetKategorisi? seciliKategori;
  final String aramaSorgusu;
  final bool gridGorunumu; // true = grid, false = liste
  final String? hataMesaji;
  final String? basariMesaji;

  const GardropDurum({
    this.tip = GardropDurumTipi.baslangic,
    this.kiyafetler = const [],
    this.seciliKategori,
    this.aramaSorgusu = '',
    this.gridGorunumu = true,
    this.hataMesaji,
    this.basariMesaji,
  });

  /// Filtrelenmiş kıyafet listesi
  List<KiyafetModeli> get filtrelenmisKiyafetler {
    var sonuc = kiyafetler;

    // Kategori filtresi
    if (seciliKategori != null) {
      sonuc = sonuc.where((k) => k.kategori == seciliKategori).toList();
    }

    return sonuc;
  }

  /// Kategori bazlı sayılar
  Map<KiyafetKategorisi, int> get kategoriSayilari {
    final sayilar = <KiyafetKategorisi, int>{};
    for (final kategori in KiyafetKategorisi.values) {
      sayilar[kategori] = kiyafetler.where((k) => k.kategori == kategori).length;
    }
    return sayilar;
  }

  /// Toplam kıyafet sayısı
  int get toplamSayi => kiyafetler.length;

  GardropDurum kopyala({
    GardropDurumTipi? tip,
    List<KiyafetModeli>? kiyafetler,
    KiyafetKategorisi? seciliKategori,
    bool kategoriTemizle = false, // null yapmak istiyorsak
    String? aramaSorgusu,
    bool? gridGorunumu,
    String? hataMesaji,
    String? basariMesaji,
  }) {
    return GardropDurum(
      tip: tip ?? this.tip,
      kiyafetler: kiyafetler ?? this.kiyafetler,
      seciliKategori: kategoriTemizle ? null : (seciliKategori ?? this.seciliKategori),
      aramaSorgusu: aramaSorgusu ?? this.aramaSorgusu,
      gridGorunumu: gridGorunumu ?? this.gridGorunumu,
      hataMesaji: hataMesaji,
      basariMesaji: basariMesaji,
    );
  }

  @override
  List<Object?> get props => [
        tip, kiyafetler, seciliKategori, aramaSorgusu,
        gridGorunumu, hataMesaji, basariMesaji,
      ];
}
