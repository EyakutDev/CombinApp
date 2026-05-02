import '../../alan/depolar/gardrop_deposu.dart';
import '../../alan/modeller/kiyafet_modeli.dart';
import '../kaynaklar/gardrop_veri_kaynagi.dart';

/// GardropDeposu somut implementasyonu.
class GardropDeposuImpl implements GardropDeposu {
  final GardropVeriKaynagi _veriKaynagi;

  GardropDeposuImpl({required GardropVeriKaynagi veriKaynagi})
      : _veriKaynagi = veriKaynagi;

  @override
  Future<List<KiyafetModeli>> tumKiyafetleriGetir() =>
      _veriKaynagi.tumKiyafetleriGetir();

  @override
  Future<List<KiyafetModeli>> kategoriyeGoreGetir(KiyafetKategorisi kategori) =>
      _veriKaynagi.kategoriyeGoreGetir(kategori);

  @override
  Future<List<KiyafetModeli>> favorileriGetir() =>
      _veriKaynagi.favorileriGetir();

  @override
  Future<KiyafetModeli?> kiyafetGetir(String id) =>
      _veriKaynagi.kiyafetGetir(id);

  @override
  Future<KiyafetModeli> kiyafetEkle(KiyafetModeli kiyafet) =>
      _veriKaynagi.kiyafetEkle(kiyafet);

  @override
  Future<KiyafetModeli> kiyafetGuncelle(KiyafetModeli kiyafet) =>
      _veriKaynagi.kiyafetGuncelle(kiyafet);

  @override
  Future<void> kiyafetSil(String id) => _veriKaynagi.kiyafetSil(id);

  @override
  Future<KiyafetModeli> favoriDegistir(String id, bool favori) =>
      _veriKaynagi.favoriDegistir(id, favori);

  @override
  Future<List<KiyafetModeli>> kiyafetAra(String sorgu) =>
      _veriKaynagi.kiyafetAra(sorgu);

  @override
  Future<String> gorselYukle({
    required String kullaniciId,
    required String dosyaYolu,
    required String dosyaAdi,
  }) =>
      _veriKaynagi.gorselYukle(
        kullaniciId: kullaniciId,
        dosyaYolu: dosyaYolu,
        dosyaAdi: dosyaAdi,
      );

  @override
  Future<String> thumbnailYukle({
    required String kullaniciId,
    required String dosyaYolu,
    required String dosyaAdi,
  }) =>
      _veriKaynagi.thumbnailYukle(
        kullaniciId: kullaniciId,
        dosyaYolu: dosyaYolu,
        dosyaAdi: dosyaAdi,
      );

  @override
  Future<void> gorselSil(String gorselYolu) =>
      _veriKaynagi.gorselSil(gorselYolu);
}
