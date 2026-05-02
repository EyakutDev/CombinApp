import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../alan/modeller/plan_modeli.dart';
import '../../alan/depolar/plan_deposu.dart';

// === Events ===

abstract class PlanOlay extends Equatable {
  const PlanOlay();
  @override
  List<Object?> get props => [];
}

/// Belirli haftanın planlarını yükle
class HaftaPlanYukle extends PlanOlay {
  final DateTime haftaninIlkGunu;
  const HaftaPlanYukle({required this.haftaninIlkGunu});

  @override
  List<Object?> get props => [haftaninIlkGunu];
}

/// Önceki haftaya geç
class OncekiHaftayaGec extends PlanOlay {
  const OncekiHaftayaGec();
}

/// Sonraki haftaya geç
class SonrakiHaftayaGec extends PlanOlay {
  const SonrakiHaftayaGec();
}

/// Güne plan ata (henüz Supabase bağlanmadığında local)
class GunePlanAta extends PlanOlay {
  final DateTime tarih;
  final PlanModeli plan;
  const GunePlanAta({required this.tarih, required this.plan});

  @override
  List<Object?> get props => [tarih, plan];
}

/// Günden planı kaldır
class PlanKaldir extends PlanOlay {
  final DateTime tarih;
  const PlanKaldir({required this.tarih});

  @override
  List<Object?> get props => [tarih];
}

// === States ===

enum PlanDurumTipi { baslangic, yukleniyor, yuklendi, hata }

class PlanDurum extends Equatable {
  final PlanDurumTipi tip;
  final HaftaModeli? hafta;
  final DateTime? secilenGun;
  final String? hataMesaji;

  const PlanDurum({
    this.tip = PlanDurumTipi.baslangic,
    this.hafta,
    this.secilenGun,
    this.hataMesaji,
  });

  PlanDurum kopyala({
    PlanDurumTipi? tip,
    HaftaModeli? hafta,
    DateTime? secilenGun,
    String? hataMesaji,
  }) {
    return PlanDurum(
      tip: tip ?? this.tip,
      hafta: hafta ?? this.hafta,
      secilenGun: secilenGun ?? this.secilenGun,
      hataMesaji: hataMesaji,
    );
  }

  @override
  List<Object?> get props => [tip, hafta, secilenGun, hataMesaji];
}

// === BLoC ===

class PlanBloc extends Bloc<PlanOlay, PlanDurum> {
  final PlanDeposu? _planDeposu;

  PlanBloc({PlanDeposu? planDeposu}) 
    : _planDeposu = planDeposu,
      super(const PlanDurum()) {
    on<HaftaPlanYukle>(_haftaPlanYukle);
    on<OncekiHaftayaGec>(_oncekiHafta);
    on<SonrakiHaftayaGec>(_sonrakiHafta);
    on<GunePlanAta>(_gunePlanAta);
    on<PlanKaldir>(_planKaldir);
  }

  /// Mevcut haftanın Pazartesi gününü bul
  static DateTime buHaftaninPazartesisi() {
    final bugun = DateTime.now();
    final pazartesi = bugun.subtract(Duration(days: bugun.weekday - 1));
    return DateTime(pazartesi.year, pazartesi.month, pazartesi.day);
  }

  Future<void> _haftaPlanYukle(
    HaftaPlanYukle olay,
    Emitter<PlanDurum> emit,
  ) async {
    emit(state.kopyala(tip: PlanDurumTipi.yukleniyor));

    try {
      final hafta = HaftaModeli(haftaninIlkGunu: olay.haftaninIlkGunu);
      final bitisGunu = olay.haftaninIlkGunu.add(const Duration(days: 6));

      if (_planDeposu != null) {
        try {
          final planlar = await _planDeposu.planlariGetir(olay.haftaninIlkGunu, bitisGunu);
          for (final plan in planlar) {
            final normalTarih = DateTime(plan.tarih.year, plan.tarih.month, plan.tarih.day);
            hafta.gunler[normalTarih] = plan;
          }
        } catch (_) {
          // Veritabanı hatası — boş planla devam et
        }
      }

      emit(state.kopyala(
        tip: PlanDurumTipi.yuklendi,
        hafta: hafta,
        secilenGun: DateTime.now(),
      ));
    } catch (e) {
      // Hafta modeli bile oluşturulamazsa, yine de boş hafta göster
      final hafta = HaftaModeli(haftaninIlkGunu: olay.haftaninIlkGunu);
      emit(state.kopyala(
        tip: PlanDurumTipi.yuklendi,
        hafta: hafta,
        secilenGun: DateTime.now(),
      ));
    }
  }

  void _oncekiHafta(OncekiHaftayaGec olay, Emitter<PlanDurum> emit) {
    if (state.hafta == null) return;
    final oncekiPazartesi =
        state.hafta!.haftaninIlkGunu.subtract(const Duration(days: 7));
    add(HaftaPlanYukle(haftaninIlkGunu: oncekiPazartesi));
  }

  void _sonrakiHafta(SonrakiHaftayaGec olay, Emitter<PlanDurum> emit) {
    if (state.hafta == null) return;
    final sonrakiPazartesi =
        state.hafta!.haftaninIlkGunu.add(const Duration(days: 7));
    add(HaftaPlanYukle(haftaninIlkGunu: sonrakiPazartesi));
  }

  Future<void> _gunePlanAta(GunePlanAta olay, Emitter<PlanDurum> emit) async {
    if (state.hafta == null) return;

    try {
      PlanModeli kaydedilenPlan = olay.plan;
      if (_planDeposu != null) {
        kaydedilenPlan = await _planDeposu.gunePlanAta(olay.plan);
      }

      final normalTarih =
          DateTime(olay.tarih.year, olay.tarih.month, olay.tarih.day);
      final yeniGunler = Map<DateTime, PlanModeli?>.from(state.hafta!.gunler);
      yeniGunler[normalTarih] = kaydedilenPlan;

      final yeniHafta = HaftaModeli(
        haftaninIlkGunu: state.hafta!.haftaninIlkGunu,
        gunler: yeniGunler,
      );

      emit(state.kopyala(hafta: yeniHafta));
    } catch (e) {
      emit(state.kopyala(hataMesaji: 'Plan kaydedilemedi: ${e.toString()}'));
    }
  }

  Future<void> _planKaldir(PlanKaldir olay, Emitter<PlanDurum> emit) async {
    if (state.hafta == null) return;

    try {
      if (_planDeposu != null) {
        await _planDeposu.planKaldir(olay.tarih);
      }

      final normalTarih =
          DateTime(olay.tarih.year, olay.tarih.month, olay.tarih.day);
      final yeniGunler = Map<DateTime, PlanModeli?>.from(state.hafta!.gunler);
      yeniGunler.remove(normalTarih);

      final yeniHafta = HaftaModeli(
        haftaninIlkGunu: state.hafta!.haftaninIlkGunu,
        gunler: yeniGunler,
      );

      emit(state.kopyala(hafta: yeniHafta));
    } catch (e) {
      emit(state.kopyala(hataMesaji: 'Plan kaldırılamadı: ${e.toString()}'));
    }
  }
}
