import '../../alan/modeller/plan_modeli.dart';

abstract class PlanDeposu {
  Future<List<PlanModeli>> planlariGetir(DateTime baslangic, DateTime bitis);
  Future<PlanModeli> gunePlanAta(PlanModeli plan);
  Future<void> planKaldir(DateTime tarih);
}
