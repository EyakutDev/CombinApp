import 'package:equatable/equatable.dart';
import '../../alan/modeller/kiyafet_modeli.dart';

/// Gardırop olayları.
abstract class GardropOlay extends Equatable {
  const GardropOlay();

  @override
  List<Object?> get props => [];
}

/// Tüm kıyafetleri yükle
class KiyafetleriYukle extends GardropOlay {
  const KiyafetleriYukle();
}

/// Kategoriye göre filtrele
class KategoriyeGoreFiltrele extends GardropOlay {
  final KiyafetKategorisi? kategori; // null = tümü

  const KategoriyeGoreFiltrele({this.kategori});

  @override
  List<Object?> get props => [kategori];
}

/// Kıyafet ara
class KiyafetAra extends GardropOlay {
  final String sorgu;

  const KiyafetAra({required this.sorgu});

  @override
  List<Object?> get props => [sorgu];
}

/// Yeni kıyafet ekle
class KiyafetEkle extends GardropOlay {
  final KiyafetModeli kiyafet;

  const KiyafetEkle({required this.kiyafet});

  @override
  List<Object?> get props => [kiyafet];
}

/// Kıyafet güncelle
class KiyafetGuncelle extends GardropOlay {
  final KiyafetModeli kiyafet;

  const KiyafetGuncelle({required this.kiyafet});

  @override
  List<Object?> get props => [kiyafet];
}

/// Kıyafet sil
class KiyafetSilEvent extends GardropOlay {
  final String kiyafetId;

  const KiyafetSilEvent({required this.kiyafetId});

  @override
  List<Object?> get props => [kiyafetId];
}

/// Favori toggle
class FavoriDegistir extends GardropOlay {
  final String kiyafetId;
  final bool favori;

  const FavoriDegistir({required this.kiyafetId, required this.favori});

  @override
  List<Object?> get props => [kiyafetId, favori];
}

/// Görünüm modunu değiştir (grid / liste)
class GorunumModuDegistir extends GardropOlay {
  const GorunumModuDegistir();
}
