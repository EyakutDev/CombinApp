import 'package:equatable/equatable.dart';
import '../../alan/modeller/kullanici_modeli.dart';

/// Kimlik doğrulama durumları.
enum KimlikDurumTipi {
  baslangic,    // uygulama açıldı, henüz kontrol yapılmadı
  yukleniyor,   // işlem devam ediyor
  girisYapildi, // oturum aktif
  girisYok,     // oturum yok
  hata,         // hata oluştu
}

class KimlikDurum extends Equatable {
  final KimlikDurumTipi tip;
  final KullaniciModeli? kullanici;
  final String? hataMesaji;

  const KimlikDurum({
    required this.tip,
    this.kullanici,
    this.hataMesaji,
  });

  /// Başlangıç durumu
  const KimlikDurum.baslangic()
      : tip = KimlikDurumTipi.baslangic,
        kullanici = null,
        hataMesaji = null;

  /// Yükleniyor durumu
  const KimlikDurum.yukleniyor()
      : tip = KimlikDurumTipi.yukleniyor,
        kullanici = null,
        hataMesaji = null;

  /// Giriş yapılmış durumu
  const KimlikDurum.girisYapildi(KullaniciModeli this.kullanici)
      : tip = KimlikDurumTipi.girisYapildi,
        hataMesaji = null;

  /// Giriş yok durumu
  const KimlikDurum.girisYok()
      : tip = KimlikDurumTipi.girisYok,
        kullanici = null,
        hataMesaji = null;

  /// Hata durumu
  const KimlikDurum.hata(String this.hataMesaji)
      : tip = KimlikDurumTipi.hata,
        kullanici = null;

  @override
  List<Object?> get props => [tip, kullanici, hataMesaji];
}
