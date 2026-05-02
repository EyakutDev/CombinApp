import 'package:supabase_flutter/supabase_flutter.dart';
import '../../alan/modeller/kombin_modeli.dart';

class KombinVeriKaynagi {
  final SupabaseClient _supabase;

  KombinVeriKaynagi({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<void> kombinKaydet(KombinModeli kombin) async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final kombinVerisi = kombin.toJson();
    kombinVerisi['kullanici_id'] = kullaniciId;

    // 1. Kombini kaydet ve ID'yi al
    final kayitliKombin = await _supabase
        .from('kombinler')
        .insert(kombinVerisi)
        .select('id')
        .single();

    final kombinId = kayitliKombin['id'] as String;

    // 2. Kombin parçalarını kaydet
    final parcalar = kombin.parcalariJson(kombinId);
    if (parcalar.isNotEmpty) {
      await _supabase.from('kombin_parcalari').insert(parcalar);
    }
  }

  Future<List<KombinModeli>> kayitliKombinleriGetir() async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final response = await _supabase
        .from('kombinler')
        .select('*, kombin_parcalari(*, kiyafetler(*))')
        .eq('kullanici_id', kullaniciId)
        .order('olusturulma_tarihi', ascending: false);

    return (response as List<dynamic>)
        .map((json) => KombinModeli.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> kombinSil(String kombinId) async {
    await _supabase.from('kombinler').delete().eq('id', kombinId);
  }

  Future<void> kombinFavoriYap(String kombinId, bool favori) async {
    await _supabase
        .from('kombinler')
        .update({'favori': favori})
        .eq('id', kombinId);
  }
}
