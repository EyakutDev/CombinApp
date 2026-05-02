import '../modeller/kullanici_modeli.dart';

/// Kimlik doğrulama deposu arayüzü.
/// Somut implementasyon veri katmanında yapılır.
abstract class KimlikDeposu {
  /// Mevcut oturum durumu
  Stream<KullaniciModeli?> get oturumDurumu;

  /// Mevcut kullanıcıyı getir (null = oturum yok)
  Future<KullaniciModeli?> mevcutKullaniciGetir();

  /// E-posta + şifre ile kayıt
  Future<KullaniciModeli> kayitOl({
    required String isim,
    required String eposta,
    required String sifre,
  });

  /// E-posta + şifre ile giriş
  Future<KullaniciModeli> girisYap({
    required String eposta,
    required String sifre,
  });

  /// Çıkış yap
  Future<void> cikisYap();

  /// Şifre sıfırlama e-postası gönder
  Future<void> sifreSifirla({required String eposta});

  /// Kullanıcı profilini güncelle
  Future<KullaniciModeli> profilGuncelle(KullaniciModeli kullanici);
}
