import 'package:equatable/equatable.dart';

/// Kimlik doğrulama olayları.
abstract class KimlikOlay extends Equatable {
  const KimlikOlay();

  @override
  List<Object?> get props => [];
}

/// Uygulama başlatıldığında oturum durumunu kontrol et
class OturumKontrolEt extends KimlikOlay {
  const OturumKontrolEt();
}

/// E-posta + şifre ile giriş yap
class GirisYapIstendi extends KimlikOlay {
  final String eposta;
  final String sifre;

  const GirisYapIstendi({
    required this.eposta,
    required this.sifre,
  });

  @override
  List<Object?> get props => [eposta, sifre];
}

/// E-posta + şifre ile kayıt ol
class KayitOlIstendi extends KimlikOlay {
  final String isim;
  final String eposta;
  final String sifre;

  const KayitOlIstendi({
    required this.isim,
    required this.eposta,
    required this.sifre,
  });

  @override
  List<Object?> get props => [isim, eposta, sifre];
}

/// Çıkış yap
class CikisYapIstendi extends KimlikOlay {
  const CikisYapIstendi();
}

/// Şifre sıfırlama
class SifreSifirlaIstendi extends KimlikOlay {
  final String eposta;

  const SifreSifirlaIstendi({required this.eposta});

  @override
  List<Object?> get props => [eposta];
}
