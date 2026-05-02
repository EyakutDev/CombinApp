import '../modeller/kombin_modeli.dart';

abstract class KombinDeposu {
  Future<void> kombinKaydet(KombinModeli kombin);
  Future<List<KombinModeli>> kayitliKombinleriGetir();
  Future<void> kombinSil(String kombinId);
  Future<void> kombinFavoriYap(String kombinId, bool favori);
}
