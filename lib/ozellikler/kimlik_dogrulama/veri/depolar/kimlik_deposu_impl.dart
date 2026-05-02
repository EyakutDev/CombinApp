import '../../alan/depolar/kimlik_deposu.dart';
import '../../alan/modeller/kullanici_modeli.dart';
import '../kaynaklar/kimlik_veri_kaynagi.dart';

/// KimlikDeposu somut implementasyonu.
/// Veri kaynağını soyutlama katmanına bağlar.
class KimlikDeposuImpl implements KimlikDeposu {
  final KimlikVeriKaynagi _veriKaynagi;

  KimlikDeposuImpl({required KimlikVeriKaynagi veriKaynagi})
      : _veriKaynagi = veriKaynagi;

  @override
  Stream<KullaniciModeli?> get oturumDurumu => _veriKaynagi.oturumDurumu;

  @override
  Future<KullaniciModeli?> mevcutKullaniciGetir() =>
      _veriKaynagi.mevcutKullaniciGetir();

  @override
  Future<KullaniciModeli> kayitOl({
    required String isim,
    required String eposta,
    required String sifre,
  }) =>
      _veriKaynagi.kayitOl(isim: isim, eposta: eposta, sifre: sifre);

  @override
  Future<KullaniciModeli> girisYap({
    required String eposta,
    required String sifre,
  }) =>
      _veriKaynagi.girisYap(eposta: eposta, sifre: sifre);

  @override
  Future<void> cikisYap() => _veriKaynagi.cikisYap();

  @override
  Future<void> sifreSifirla({required String eposta}) =>
      _veriKaynagi.sifreSifirla(eposta: eposta);

  @override
  Future<KullaniciModeli> profilGuncelle(KullaniciModeli kullanici) =>
      _veriKaynagi.profilGuncelle(kullanici);
}
