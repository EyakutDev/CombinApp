import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../alan/modeller/hava_durumu_modeli.dart';
import '../../veri/hava_durumu_servisi.dart';

// === Events ===

abstract class HavaDurumuOlay extends Equatable {
  const HavaDurumuOlay();
  @override
  List<Object?> get props => [];
}

class HavaDurumuYukle extends HavaDurumuOlay {
  final String sehir;
  const HavaDurumuYukle({required this.sehir});

  @override
  List<Object?> get props => [sehir];
}

// === States ===

enum HavaDurumuDurumTipi { baslangic, yukleniyor, yuklendi, hata }

class HavaDurumuDurum extends Equatable {
  final HavaDurumuDurumTipi tip;
  final HavaDurumuModeli? havaDurumu;
  final String? sehir;
  final String? hataMesaji;

  const HavaDurumuDurum({
    this.tip = HavaDurumuDurumTipi.baslangic,
    this.havaDurumu,
    this.sehir,
    this.hataMesaji,
  });

  HavaDurumuDurum kopyala({
    HavaDurumuDurumTipi? tip,
    HavaDurumuModeli? havaDurumu,
    String? sehir,
    String? hataMesaji,
  }) {
    return HavaDurumuDurum(
      tip: tip ?? this.tip,
      havaDurumu: havaDurumu ?? this.havaDurumu,
      sehir: sehir ?? this.sehir,
      hataMesaji: hataMesaji,
    );
  }

  @override
  List<Object?> get props => [tip, havaDurumu, sehir, hataMesaji];
}

// === BLoC ===

class HavaDurumuBloc extends Bloc<HavaDurumuOlay, HavaDurumuDurum> {
  final HavaDurumuServisi _servis;

  HavaDurumuBloc({required HavaDurumuServisi servis})
      : _servis = servis,
        super(const HavaDurumuDurum()) {
    on<HavaDurumuYukle>(_havaDurumuYukle);
  }

  Future<void> _havaDurumuYukle(
    HavaDurumuYukle olay,
    Emitter<HavaDurumuDurum> emit,
  ) async {
    emit(state.kopyala(
      tip: HavaDurumuDurumTipi.yukleniyor,
      sehir: olay.sehir,
    ));

    try {
      final havaDurumu = await _servis.havaDurumuGetir(olay.sehir);
      emit(state.kopyala(
        tip: HavaDurumuDurumTipi.yuklendi,
        havaDurumu: havaDurumu,
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: HavaDurumuDurumTipi.hata,
        hataMesaji: 'Hava durumu alınamadı',
      ));
    }
  }

  @override
  Future<void> close() {
    _servis.dispose();
    return super.close();
  }
}
