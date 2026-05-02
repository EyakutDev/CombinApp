import 'package:supabase_flutter/supabase_flutter.dart';
import '../../alan/modeller/plan_modeli.dart';
import 'package:combin_app/ozellikler/kombin/alan/modeller/kombin_modeli.dart';

class PlanVeriKaynagi {
  final SupabaseClient _supabase;

  PlanVeriKaynagi({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Belirtilen tarih aralığındaki planları ve ilgili kombinleri getirir
  Future<List<PlanModeli>> planlariGetir(DateTime baslangic, DateTime bitis) async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final baslangicStr = '${baslangic.year}-${baslangic.month.toString().padLeft(2, '0')}-${baslangic.day.toString().padLeft(2, '0')}';
    final bitisStr = '${bitis.year}-${bitis.month.toString().padLeft(2, '0')}-${bitis.day.toString().padLeft(2, '0')}';

    final response = await _supabase
        .from('planlar')
        .select('*, kombinler(*, kombin_parcalari(*, kiyafetler(*)))')
        .eq('kullanici_id', kullaniciId)
        .gte('tarih', baslangicStr)
        .lte('tarih', bitisStr);

    return (response as List<dynamic>).map((json) {
      final plan = PlanModeli.fromJson(json as Map<String, dynamic>);
      
      // İlişkili kombin verisini parse et
      if (json['kombinler'] != null) {
        final kombin = KombinModeli.fromJson(json['kombinler'] as Map<String, dynamic>);
        return plan.kopyala(kombin: kombin);
      }
      
      return plan;
    }).toList();
  }

  /// Güne plan ata (varsa günceller - upsert)
  Future<PlanModeli> gunePlanAta(PlanModeli plan) async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final planVerisi = plan.toJson();
    
    // UPSERT: kullanici_id ve tarih ikilisi UNIQUE olduğu için
    // aynı güne yeni plan eklendiğinde eskisinin üzerine yazar.
    final response = await _supabase
        .from('planlar')
        .upsert(planVerisi, onConflict: 'kullanici_id, tarih')
        .select('*, kombinler(*, kombin_parcalari(*, kiyafetler(*)))')
        .single();

    final kaydedilenPlan = PlanModeli.fromJson(response);
    
    if (response['kombinler'] != null) {
      final kombin = KombinModeli.fromJson(response['kombinler'] as Map<String, dynamic>);
      return kaydedilenPlan.kopyala(kombin: kombin);
    }
    
    return kaydedilenPlan;
  }

  /// Belirli bir gündeki planı kaldırır
  Future<void> planKaldir(DateTime tarih) async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final tarihStr = '${tarih.year}-${tarih.month.toString().padLeft(2, '0')}-${tarih.day.toString().padLeft(2, '0')}';

    await _supabase
        .from('planlar')
        .delete()
        .eq('kullanici_id', kullaniciId)
        .eq('tarih', tarihStr);
  }
}
