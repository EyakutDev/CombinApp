import '../../alan/depolar/kombin_deposu.dart';
import '../../alan/modeller/kombin_modeli.dart';
import '../kaynaklar/kombin_veri_kaynagi.dart';

class KombinDeposuImpl implements KombinDeposu {
  final KombinVeriKaynagi _veriKaynagi;

  KombinDeposuImpl({required KombinVeriKaynagi veriKaynagi})
      : _veriKaynagi = veriKaynagi;

  @override
  Future<void> kombinKaydet(KombinModeli kombin) async {
    await _veriKaynagi.kombinKaydet(kombin);
  }

  @override
  Future<List<KombinModeli>> kayitliKombinleriGetir() async {
    return await _veriKaynagi.kayitliKombinleriGetir();
  }

  @override
  Future<void> kombinSil(String kombinId) async {
    await _veriKaynagi.kombinSil(kombinId);
  }

  @override
  Future<void> kombinFavoriYap(String kombinId, bool favori) async {
    await _veriKaynagi.kombinFavoriYap(kombinId, favori);
  }
}
