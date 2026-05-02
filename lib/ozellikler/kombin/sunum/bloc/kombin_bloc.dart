import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:combin_app/ozellikler/gardrop/alan/modeller/kiyafet_modeli.dart';
import 'package:combin_app/ozellikler/gardrop/alan/depolar/gardrop_deposu.dart';
import 'package:combin_app/ozellikler/hava_durumu/alan/modeller/hava_durumu_modeli.dart';
import '../../alan/modeller/kombin_modeli.dart';
import '../../alan/motor/kombin_motoru.dart';
import '../../alan/depolar/kombin_deposu.dart';

// === Events ===

abstract class KombinOlay extends Equatable {
  const KombinOlay();
  @override
  List<Object?> get props => [];
}

/// Yeni kombin öner
class KombinOner extends KombinOlay {
  final HavaDurumuModeli? havaDurumu;
  final String? etkinlikTipi;

  const KombinOner({this.havaDurumu, this.etkinlikTipi});

  @override
  List<Object?> get props => [havaDurumu, etkinlikTipi];
}

/// Kombini yenile (farklı bir kombin öner)
class KombinYenile extends KombinOlay {
  final HavaDurumuModeli? havaDurumu;
  const KombinYenile({this.havaDurumu});

  @override
  List<Object?> get props => [havaDurumu];
}

/// Belirli bir parçayı değiştir
class ParcaDegistirOlay extends KombinOlay {
  final KiyafetKategorisi kategori;
  final HavaDurumuModeli? havaDurumu;

  const ParcaDegistirOlay({
    required this.kategori,
    this.havaDurumu,
  });

  @override
  List<Object?> get props => [kategori, havaDurumu];
}

/// Kombini kaydet (mevcut state.kombin üzerinden)
class KombinKaydet extends KombinOlay {
  const KombinKaydet();
}

/// Manuel oluşturulan kombini kaydet
class ManuelKombinKaydet extends KombinOlay {
  final KombinModeli kombin;
  const ManuelKombinKaydet({required this.kombin});

  @override
  List<Object?> get props => [kombin];
}

/// Etkinlik tipini değiştir
class EtkinlikTipiDegistir extends KombinOlay {
  final String? etkinlikTipi;
  const EtkinlikTipiDegistir({this.etkinlikTipi});

  @override
  List<Object?> get props => [etkinlikTipi];
}

/// Kayıtlı kombinleri getir
class KayitliKombinleriGetir extends KombinOlay {
  const KayitliKombinleriGetir();
}

// === States ===

enum KombinDurumTipi { baslangic, yukleniyor, hazir, bos, hata }

class KombinDurum extends Equatable {
  final KombinDurumTipi tip;
  final KombinModeli? kombin;
  final String? seciliEtkinlik;
  final String? hataMesaji;
  final String? basariMesaji;
  final List<KombinModeli> kayitliKombinler;

  const KombinDurum({
    this.tip = KombinDurumTipi.baslangic,
    this.kombin,
    this.seciliEtkinlik,
    this.hataMesaji,
    this.basariMesaji,
    this.kayitliKombinler = const [],
  });

  KombinDurum kopyala({
    KombinDurumTipi? tip,
    KombinModeli? kombin,
    String? seciliEtkinlik,
    bool etkinlikTemizle = false,
    String? hataMesaji,
    String? basariMesaji,
    List<KombinModeli>? kayitliKombinler,
  }) {
    return KombinDurum(
      tip: tip ?? this.tip,
      kombin: kombin ?? this.kombin,
      seciliEtkinlik:
          etkinlikTemizle ? null : (seciliEtkinlik ?? this.seciliEtkinlik),
      hataMesaji: hataMesaji,
      basariMesaji: basariMesaji,
      kayitliKombinler: kayitliKombinler ?? this.kayitliKombinler,
    );
  }

  @override
  List<Object?> get props => [
        tip, kombin, seciliEtkinlik, hataMesaji, basariMesaji, 
        kayitliKombinler
      ];
}

// === BLoC ===

class KombinBloc extends Bloc<KombinOlay, KombinDurum> {
  final GardropDeposu _gardropDeposu;
  final KombinDeposu? _kombinDeposu;
  final KombinMotoru _motor;
  List<KiyafetModeli> _kiyafetCache = [];

  KombinBloc({
    required GardropDeposu gardropDeposu,
    KombinDeposu? kombinDeposu,
    KombinMotoru? motor,
  })  : _gardropDeposu = gardropDeposu,
        _kombinDeposu = kombinDeposu,
        _motor = motor ?? KombinMotoru(),
        super(const KombinDurum()) {
    on<KombinOner>(_kombinOner);
    on<KombinYenile>(_kombinYenile);
    on<ParcaDegistirOlay>(_parcaDegistir);
    on<EtkinlikTipiDegistir>(_etkinlikTipiDegistir);
    on<KombinKaydet>(_kombinKaydet);
    on<ManuelKombinKaydet>(_manuelKombinKaydet);
    on<KayitliKombinleriGetir>(_kayitliKombinleriGetir);
  }

  /// Kıyafetleri yükle ve kombin öner
  Future<void> _kombinOner(
    KombinOner olay,
    Emitter<KombinDurum> emit,
  ) async {
    emit(state.kopyala(tip: KombinDurumTipi.yukleniyor));

    try {
      // Kıyafetleri cache'le
      _kiyafetCache = await _gardropDeposu.tumKiyafetleriGetir();

      if (_kiyafetCache.isEmpty) {
        emit(state.kopyala(tip: KombinDurumTipi.bos));
        return;
      }

      final kombin = _motor.kombinOner(
        kiyafetler: _kiyafetCache,
        havaDurumu: olay.havaDurumu,
        etkinlikTipi: olay.etkinlikTipi ?? state.seciliEtkinlik,
      );

      if (kombin == null || !kombin.gecerli) {
        emit(state.kopyala(
          tip: KombinDurumTipi.bos,
          hataMesaji: 'Uygun kombin oluşturulamadı. Daha fazla kıyafet ekle.',
        ));
        return;
      }

      emit(state.kopyala(
        tip: KombinDurumTipi.hazir,
        kombin: kombin,
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: KombinDurumTipi.hata,
        hataMesaji: 'Kombin oluşturulurken hata',
      ));
    }
  }

  /// Yeni kombin öner (shuffle)
  Future<void> _kombinYenile(
    KombinYenile olay,
    Emitter<KombinDurum> emit,
  ) async {
    emit(state.kopyala(tip: KombinDurumTipi.yukleniyor));

    try {
      if (_kiyafetCache.isEmpty) {
        _kiyafetCache = await _gardropDeposu.tumKiyafetleriGetir();
      }

      final kombin = _motor.kombinOner(
        kiyafetler: _kiyafetCache,
        havaDurumu: olay.havaDurumu,
        etkinlikTipi: state.seciliEtkinlik,
      );

      if (kombin == null || !kombin.gecerli) {
        emit(state.kopyala(tip: KombinDurumTipi.bos));
        return;
      }

      emit(state.kopyala(
        tip: KombinDurumTipi.hazir,
        kombin: kombin,
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: KombinDurumTipi.hata,
        hataMesaji: 'Yeni kombin oluşturulamadı',
      ));
    }
  }

  /// Parça değiştir
  Future<void> _parcaDegistir(
    ParcaDegistirOlay olay,
    Emitter<KombinDurum> emit,
  ) async {
    if (state.kombin == null) return;

    final yeniKombin = _motor.parcaDegistir(
      mevcutKombin: state.kombin!,
      degistirilecekKategori: olay.kategori,
      kiyafetler: _kiyafetCache,
      havaDurumu: olay.havaDurumu,
    );

    if (yeniKombin != null) {
      emit(state.kopyala(kombin: yeniKombin));
    }
  }

  /// Etkinlik tipi değiştir
  void _etkinlikTipiDegistir(
    EtkinlikTipiDegistir olay,
    Emitter<KombinDurum> emit,
  ) {
    if (olay.etkinlikTipi == state.seciliEtkinlik) {
      emit(state.kopyala(etkinlikTemizle: true));
    } else {
      emit(state.kopyala(seciliEtkinlik: olay.etkinlikTipi));
    }
  }

  /// Kombin kaydet
  Future<void> _kombinKaydet(
    KombinKaydet olay,
    Emitter<KombinDurum> emit,
  ) async {
    if (state.kombin == null || _kombinDeposu == null) return;

    emit(state.kopyala(tip: KombinDurumTipi.yukleniyor));

    try {
      // Mevcut kombini, seçili etkinlik tipi ile güncelle
      final kaydedilecekKombin = state.kombin!.kopyala(
        etkinlikTipi: state.seciliEtkinlik,
      );

      await _kombinDeposu.kombinKaydet(kaydedilecekKombin);

      emit(state.kopyala(
        tip: KombinDurumTipi.hazir,
        basariMesaji: 'Kombin başarıyla kaydedildi!',
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: KombinDurumTipi.hazir, // Hata mesajı göstereceğiz ama UI hazır kalsın
        hataMesaji: 'Kombin kaydedilirken bir hata oluştu: ${e.toString()}',
      ));
    }
  }

  /// Manuel Kombin Kaydet
  Future<void> _manuelKombinKaydet(
    ManuelKombinKaydet olay,
    Emitter<KombinDurum> emit,
  ) async {
    if (_kombinDeposu == null) return;

    emit(state.kopyala(tip: KombinDurumTipi.yukleniyor));

    try {
      await _kombinDeposu.kombinKaydet(olay.kombin);

      // Yeni oluşturulan kombini de state'e koyabiliriz
      emit(state.kopyala(
        tip: KombinDurumTipi.hazir,
        kombin: olay.kombin,
        basariMesaji: 'Manuel kombin başarıyla kaydedildi!',
      ));
      
      // Listeyi güncelle
      add(const KayitliKombinleriGetir());
    } catch (e) {
      emit(state.kopyala(
        tip: KombinDurumTipi.hazir,
        hataMesaji: 'Manuel kombin kaydedilirken hata: ${e.toString()}',
      ));
    }
  }

  /// Kayıtlı kombinleri getir
  Future<void> _kayitliKombinleriGetir(
    KayitliKombinleriGetir olay,
    Emitter<KombinDurum> emit,
  ) async {
    if (_kombinDeposu == null) return;

    try {
      final kombinler = await _kombinDeposu.kayitliKombinleriGetir();
      emit(state.kopyala(kayitliKombinler: kombinler));
    } catch (e) {
      emit(state.kopyala(
        hataMesaji: 'Kayıtlı kombinler yüklenirken hata oluştu',
      ));
    }
  }
}
