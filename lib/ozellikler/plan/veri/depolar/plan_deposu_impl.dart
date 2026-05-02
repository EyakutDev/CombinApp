import '../../alan/depolar/plan_deposu.dart';
import '../../alan/modeller/plan_modeli.dart';
import '../kaynaklar/plan_veri_kaynagi.dart';

class PlanDeposuImpl implements PlanDeposu {
  final PlanVeriKaynagi veriKaynagi;

  PlanDeposuImpl({required this.veriKaynagi});

  @override
  Future<List<PlanModeli>> planlariGetir(DateTime baslangic, DateTime bitis) {
    return veriKaynagi.planlariGetir(baslangic, bitis);
  }

  @override
  Future<PlanModeli> gunePlanAta(PlanModeli plan) {
    return veriKaynagi.gunePlanAta(plan);
  }

  @override
  Future<void> planKaldir(DateTime tarih) {
    return veriKaynagi.planKaldir(tarih);
  }
}
