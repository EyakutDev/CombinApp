import 'package:flutter_bloc/flutter_bloc.dart';
import '../../alan/depolar/gardrop_deposu.dart';
import 'gardrop_olay.dart';
import 'gardrop_durum.dart';

/// Gardırop BLoC'u.
/// Kıyafet listesi, filtreleme, arama, CRUD işlemlerini yönetir.
class GardropBloc extends Bloc<GardropOlay, GardropDurum> {
  final GardropDeposu _gardropDeposu;

  GardropBloc({required GardropDeposu gardropDeposu})
      : _gardropDeposu = gardropDeposu,
        super(const GardropDurum()) {
    on<KiyafetleriYukle>(_kiyafetleriYukle);
    on<KategoriyeGoreFiltrele>(_kategoriyeGoreFiltrele);
    on<KiyafetAra>(_kiyafetAra);
    on<KiyafetEkle>(_kiyafetEkle);
    on<KiyafetGuncelle>(_kiyafetGuncelle);
    on<KiyafetSilEvent>(_kiyafetSil);
    on<FavoriDegistir>(_favoriDegistir);
    on<GorunumModuDegistir>(_gorunumModuDegistir);
  }

  /// Tüm kıyafetleri yükle
  Future<void> _kiyafetleriYukle(
    KiyafetleriYukle olay,
    Emitter<GardropDurum> emit,
  ) async {
    emit(state.kopyala(tip: GardropDurumTipi.yukleniyor));
    try {
      final kiyafetler = await _gardropDeposu.tumKiyafetleriGetir();
      emit(state.kopyala(
        tip: GardropDurumTipi.yuklendi,
        kiyafetler: kiyafetler,
      ));
    } catch (e) {
      // Veritabanı bağlantısı yoksa veya kullanıcı giriş yapmamışsa
      // boş gardırop göster (hata ekranı değil)
      emit(state.kopyala(
        tip: GardropDurumTipi.yuklendi,
        kiyafetler: [],
      ));
    }
  }

  /// Kategoriye göre filtrele
  Future<void> _kategoriyeGoreFiltrele(
    KategoriyeGoreFiltrele olay,
    Emitter<GardropDurum> emit,
  ) async {
    if (olay.kategori == state.seciliKategori) {
      // Aynı kategoriye tekrar tıklandıysa filtreyi kaldır
      emit(state.kopyala(kategoriTemizle: true));
    } else {
      emit(state.kopyala(seciliKategori: olay.kategori));
    }
  }

  /// Arama
  Future<void> _kiyafetAra(
    KiyafetAra olay,
    Emitter<GardropDurum> emit,
  ) async {
    emit(state.kopyala(aramaSorgusu: olay.sorgu));

    if (olay.sorgu.trim().isEmpty) {
      // Arama temizlendi — tüm kıyafetleri göster
      add(const KiyafetleriYukle());
      return;
    }

    try {
      final sonuclar = await _gardropDeposu.kiyafetAra(olay.sorgu);
      emit(state.kopyala(
        tip: GardropDurumTipi.yuklendi,
        kiyafetler: sonuclar,
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: GardropDurumTipi.hata,
        hataMesaji: 'Arama yapılırken hata oluştu',
      ));
    }
  }

  /// Kıyafet ekle
  Future<void> _kiyafetEkle(
    KiyafetEkle olay,
    Emitter<GardropDurum> emit,
  ) async {
    try {
      final yeniKiyafet = await _gardropDeposu.kiyafetEkle(olay.kiyafet);
      final guncelListe = [yeniKiyafet, ...state.kiyafetler];
      emit(state.kopyala(
        tip: GardropDurumTipi.yuklendi,
        kiyafetler: guncelListe,
        basariMesaji: 'Kıyafet eklendi',
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: GardropDurumTipi.hata,
        hataMesaji: 'Kıyafet eklenirken hata oluştu',
      ));
    }
  }

  /// Kıyafet güncelle
  Future<void> _kiyafetGuncelle(
    KiyafetGuncelle olay,
    Emitter<GardropDurum> emit,
  ) async {
    try {
      final guncellenen = await _gardropDeposu.kiyafetGuncelle(olay.kiyafet);
      final guncelListe = state.kiyafetler.map((k) {
        return k.id == guncellenen.id ? guncellenen : k;
      }).toList();
      emit(state.kopyala(
        tip: GardropDurumTipi.yuklendi,
        kiyafetler: guncelListe,
        basariMesaji: 'Kıyafet güncellendi',
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: GardropDurumTipi.hata,
        hataMesaji: 'Kıyafet güncellenirken hata oluştu',
      ));
    }
  }

  /// Kıyafet sil (soft delete)
  Future<void> _kiyafetSil(
    KiyafetSilEvent olay,
    Emitter<GardropDurum> emit,
  ) async {
    try {
      await _gardropDeposu.kiyafetSil(olay.kiyafetId);
      final guncelListe = state.kiyafetler
          .where((k) => k.id != olay.kiyafetId)
          .toList();
      emit(state.kopyala(
        tip: GardropDurumTipi.yuklendi,
        kiyafetler: guncelListe,
        basariMesaji: 'Kıyafet silindi',
      ));
    } catch (e) {
      emit(state.kopyala(
        tip: GardropDurumTipi.hata,
        hataMesaji: 'Kıyafet silinirken hata oluştu',
      ));
    }
  }

  /// Favori toggle
  Future<void> _favoriDegistir(
    FavoriDegistir olay,
    Emitter<GardropDurum> emit,
  ) async {
    try {
      final guncellenen = await _gardropDeposu.favoriDegistir(
        olay.kiyafetId,
        olay.favori,
      );
      final guncelListe = state.kiyafetler.map((k) {
        return k.id == guncellenen.id ? guncellenen : k;
      }).toList();
      emit(state.kopyala(
        tip: GardropDurumTipi.yuklendi,
        kiyafetler: guncelListe,
      ));
    } catch (e) {
      // Sessizce hata yut — kritik değil
    }
  }

  /// Görünüm modu toggle (grid ↔ liste)
  void _gorunumModuDegistir(
    GorunumModuDegistir olay,
    Emitter<GardropDurum> emit,
  ) {
    emit(state.kopyala(gridGorunumu: !state.gridGorunumu));
  }
}
