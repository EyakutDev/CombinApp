import '../modeller/kiyafet_modeli.dart';

/// Gardırop deposu arayüzü.
abstract class GardropDeposu {
  /// Tüm kıyafetleri getir
  Future<List<KiyafetModeli>> tumKiyafetleriGetir();

  /// Kategoriye göre filtrele
  Future<List<KiyafetModeli>> kategoriyeGoreGetir(KiyafetKategorisi kategori);

  /// Favori kıyafetleri getir
  Future<List<KiyafetModeli>> favorileriGetir();

  /// Tek kıyafet getir
  Future<KiyafetModeli?> kiyafetGetir(String id);

  /// Kıyafet ekle
  Future<KiyafetModeli> kiyafetEkle(KiyafetModeli kiyafet);

  /// Kıyafet güncelle
  Future<KiyafetModeli> kiyafetGuncelle(KiyafetModeli kiyafet);

  /// Kıyafet sil
  Future<void> kiyafetSil(String id);

  /// Favori toggle
  Future<KiyafetModeli> favoriDegistir(String id, bool favori);

  /// Arama
  Future<List<KiyafetModeli>> kiyafetAra(String sorgu);

  /// Görsel yükle → URL döndür
  Future<String> gorselYukle({
    required String kullaniciId,
    required String dosyaYolu,
    required String dosyaAdi,
  });

  /// Thumbnail yükle → URL döndür
  Future<String> thumbnailYukle({
    required String kullaniciId,
    required String dosyaYolu,
    required String dosyaAdi,
  });

  /// Görseli sil
  Future<void> gorselSil(String gorselYolu);
}
