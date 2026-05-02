import 'dart:math';
import 'package:combin_app/ozellikler/gardrop/alan/modeller/kiyafet_modeli.dart';
import 'package:combin_app/ozellikler/hava_durumu/alan/modeller/hava_durumu_modeli.dart';
import 'package:combin_app/ozellikler/kombin/alan/modeller/kombin_modeli.dart';

/// Rule-based kombin motoru.
/// Tamamen cihaz tarafında çalışır — sunucu maliyeti yok.
///
/// Kurallar:
/// 1. Hava durumuna göre mevsim ve kalınlık filtresi
/// 2. Renk uyumu (temel kurallar)
/// 3. Etkinlik tipine göre kategori önceliklendirme
/// 4. Rastgele çeşitlilik
class KombinMotoru {
  final Random _random = Random();

  /// Hava durumu ve etkinliğe göre kombin öner.
  /// [kiyafetler] — kullanıcının tüm aktif kıyafetleri
  /// [havaDurumu] — güncel hava durumu (null ise filtre uygulanmaz)
  /// [etkinlikTipi] — is, gunluk, ozel_davet, spor (null ise genel)
  KombinModeli? kombinOner({
    required List<KiyafetModeli> kiyafetler,
    HavaDurumuModeli? havaDurumu,
    String? etkinlikTipi,
  }) {
    if (kiyafetler.isEmpty) return null;

    // 1. Hava durumuna göre uygun kıyafetleri filtrele
    var uygunKiyafetler = _havaDurumuFiltre(kiyafetler, havaDurumu);

    // Filtre çok daraltıyorsa tüm kıyafetleri kullan
    if (_yeterliMi(uygunKiyafetler) == false) {
      uygunKiyafetler = kiyafetler;
    }

    // 2. Kategorilere ayır
    final ustler = uygunKiyafetler
        .where((k) => k.kategori == KiyafetKategorisi.ustGiyim)
        .toList();
    final altlar = uygunKiyafetler
        .where((k) => k.kategori == KiyafetKategorisi.altGiyim)
        .toList();
    final disler = uygunKiyafetler
        .where((k) => k.kategori == KiyafetKategorisi.disGiyim)
        .toList();
    final ayaklar = uygunKiyafetler
        .where((k) => k.kategori == KiyafetKategorisi.ayakkabi)
        .toList();
    final aksesuarlar = uygunKiyafetler
        .where((k) =>
            k.kategori == KiyafetKategorisi.aksesuar ||
            k.kategori == KiyafetKategorisi.canta)
        .toList();

    // En az üst ve alt olmalı
    if (ustler.isEmpty || altlar.isEmpty) return null;

    // 3. Ana parçaları seç
    final secilenUst = _rastgeleSec(ustler);
    if (secilenUst == null) return null;

    // Alt giyimi renk uyumuna göre seç
    final secilenAlt = _renkUyumuylaSec(altlar, secilenUst.renk);

    // 4. Dış giyim — sıcaklığa göre
    KiyafetModeli? secilenDis;
    if (havaDurumu != null && _disGiyimGerekli(havaDurumu)) {
      secilenDis = _renkUyumuylaSec(disler, secilenUst.renk);
    }

    // 5. Ayakkabı ve aksesuar
    final secilenAyakkabi = _rastgeleSec(ayaklar);
    final secilenAksesuar = _rastgeleSec(aksesuarlar);

    return KombinModeli(
      ustGiyim: secilenUst,
      altGiyim: secilenAlt,
      disGiyim: secilenDis,
      ayakkabi: secilenAyakkabi,
      aksesuar: secilenAksesuar,
      etkinlikTipi: etkinlikTipi,
    );
  }

  /// Belirli bir parçayı değiştirerek alternatif öner.
  /// [mevcutKombin] mevcut kombin,
  /// [degistirilecekKategori] değiştirilecek parçanın kategorisi,
  /// [kiyafetler] tüm kıyafetler
  KombinModeli? parcaDegistir({
    required KombinModeli mevcutKombin,
    required KiyafetKategorisi degistirilecekKategori,
    required List<KiyafetModeli> kiyafetler,
    HavaDurumuModeli? havaDurumu,
  }) {
    // Bu kategorideki kıyafetleri filtrele
    var adaylar = kiyafetler
        .where((k) => k.kategori == degistirilecekKategori)
        .toList();

    if (havaDurumu != null) {
      adaylar = _havaDurumuFiltre(adaylar, havaDurumu);
    }

    // Mevcut parçayı çıkar
    final mevcutId = _mevcutParcaId(mevcutKombin, degistirilecekKategori);
    if (mevcutId != null) {
      adaylar = adaylar.where((k) => k.id != mevcutId).toList();
    }

    if (adaylar.isEmpty) return null;

    // Üst giyim referansına göre renk uyumu
    final referansRenk = mevcutKombin.ustGiyim?.renk;
    final yeniParca = referansRenk != null
        ? _renkUyumuylaSec(adaylar, referansRenk)
        : _rastgeleSec(adaylar);

    if (yeniParca == null) return null;
    return mevcutKombin.parcaDegistir(yeniParca);
  }

  // === Yardımcı Metodlar ===

  /// Hava durumuna göre filtrele
  List<KiyafetModeli> _havaDurumuFiltre(
    List<KiyafetModeli> kiyafetler,
    HavaDurumuModeli? havaDurumu,
  ) {
    if (havaDurumu == null) return kiyafetler;

    final uygunMevsimler = _sicaklikaMevsim(havaDurumu.sicaklikSeviyesi);
    final uygunKalinliklar = _sicakligaKalinlik(havaDurumu.sicaklikSeviyesi);

    return kiyafetler.where((k) {
      // Mevsim filtresi — "Tüm Mevsim" her zaman geçer
      final mevsimUyumu = k.mevsimler.contains(Mevsim.tumMevsim) ||
          k.mevsimler.any((m) => uygunMevsimler.contains(m));

      // Kalınlık filtresi
      final kalinlikUyumu = uygunKalinliklar.contains(k.kalinlik);

      return mevsimUyumu && kalinlikUyumu;
    }).toList();
  }

  /// Sıcaklık seviyesine uygun mevsimler
  Set<Mevsim> _sicaklikaMevsim(SicaklikSeviyesi seviye) {
    switch (seviye) {
      case SicaklikSeviyesi.cokSoguk:
      case SicaklikSeviyesi.soguk:
        return {Mevsim.kis};
      case SicaklikSeviyesi.serin:
        return {Mevsim.sonbahar, Mevsim.ilkbahar};
      case SicaklikSeviyesi.ilik:
        return {Mevsim.ilkbahar, Mevsim.sonbahar};
      case SicaklikSeviyesi.sicak:
      case SicaklikSeviyesi.cokSicak:
        return {Mevsim.yaz};
    }
  }

  /// Sıcaklık seviyesine uygun kalınlıklar
  Set<KiyafetKalinligi> _sicakligaKalinlik(SicaklikSeviyesi seviye) {
    switch (seviye) {
      case SicaklikSeviyesi.cokSoguk:
        return {KiyafetKalinligi.kalin};
      case SicaklikSeviyesi.soguk:
        return {KiyafetKalinligi.kalin, KiyafetKalinligi.orta};
      case SicaklikSeviyesi.serin:
        return {KiyafetKalinligi.orta};
      case SicaklikSeviyesi.ilik:
        return {KiyafetKalinligi.orta, KiyafetKalinligi.ince};
      case SicaklikSeviyesi.sicak:
      case SicaklikSeviyesi.cokSicak:
        return {KiyafetKalinligi.ince};
    }
  }

  /// Dış giyim gerekli mi?
  bool _disGiyimGerekli(HavaDurumuModeli havaDurumu) {
    return havaDurumu.sicaklik < 18 ||
        havaDurumu.semsiyeGerekli ||
        havaDurumu.ruzgarHizi > 25;
  }

  /// Minimum kategori kontrolü
  bool _yeterliMi(List<KiyafetModeli> kiyafetler) {
    final ustVar = kiyafetler.any((k) => k.kategori == KiyafetKategorisi.ustGiyim);
    final altVar = kiyafetler.any((k) => k.kategori == KiyafetKategorisi.altGiyim);
    return ustVar && altVar;
  }

  /// Rastgele seç
  KiyafetModeli? _rastgeleSec(List<KiyafetModeli> liste) {
    if (liste.isEmpty) return null;
    return liste[_random.nextInt(liste.length)];
  }

  /// Renk uyumuna göre seç — uyumlu bulursa onu, bulamazsa rastgele
  KiyafetModeli? _renkUyumuylaSec(
    List<KiyafetModeli> adaylar,
    String referansRenk,
  ) {
    if (adaylar.isEmpty) return null;

    // Uyumlu renkleri bul
    final uyumluRenkler = _uyumluRenkler(referansRenk);
    final uyumluAdaylar = adaylar.where((k) => uyumluRenkler.contains(k.renk)).toList();

    if (uyumluAdaylar.isNotEmpty) {
      return uyumluAdaylar[_random.nextInt(uyumluAdaylar.length)];
    }

    // Nötr renkleri dene
    final notrAdaylar = adaylar.where((k) => _notrRenk(k.renk)).toList();
    if (notrAdaylar.isNotEmpty) {
      return notrAdaylar[_random.nextInt(notrAdaylar.length)];
    }

    // Son çare — rastgele
    return adaylar[_random.nextInt(adaylar.length)];
  }

  /// Temel renk uyumu kuralları
  Set<String> _uyumluRenkler(String renk) {
    // Nötr renkler her şeyle uyar
    const notrler = {'siyah', 'beyaz', 'gri', 'lacivert', 'bej'};

    // Renk eşleştirme tablosu
    const uyumTablosu = {
      'siyah': {'beyaz', 'gri', 'kirmizi', 'pembe', 'lacivert', 'mavi', 'bej'},
      'beyaz': {'siyah', 'lacivert', 'mavi', 'kirmizi', 'yesil', 'pembe', 'bej'},
      'gri': {'siyah', 'beyaz', 'pembe', 'mavi', 'mor', 'kirmizi'},
      'lacivert': {'beyaz', 'bej', 'kahverengi', 'gri', 'kirmizi'},
      'mavi': {'beyaz', 'gri', 'bej', 'kahverengi', 'siyah'},
      'kirmizi': {'siyah', 'beyaz', 'gri', 'lacivert'},
      'pembe': {'gri', 'beyaz', 'lacivert', 'siyah', 'bej'},
      'yesil': {'beyaz', 'bej', 'kahverengi', 'siyah'},
      'sari': {'lacivert', 'gri', 'beyaz', 'siyah'},
      'turuncu': {'lacivert', 'beyaz', 'bej', 'siyah'},
      'mor': {'gri', 'beyaz', 'siyah', 'bej'},
      'kahverengi': {'beyaz', 'bej', 'lacivert', 'yesil', 'haki'},
      'bej': {'beyaz', 'kahverengi', 'lacivert', 'bordo', 'haki'},
      'bordo': {'bej', 'beyaz', 'siyah', 'gri', 'lacivert'},
      'haki': {'beyaz', 'bej', 'kahverengi', 'siyah'},
    };

    return {...notrler, ...(uyumTablosu[renk] ?? {})};
  }

  /// Nötr renk mi?
  bool _notrRenk(String renk) {
    return {'siyah', 'beyaz', 'gri', 'lacivert', 'bej'}.contains(renk);
  }

  /// Mevcut kombinden parça ID'si
  String? _mevcutParcaId(KombinModeli kombin, KiyafetKategorisi kategori) {
    switch (kategori) {
      case KiyafetKategorisi.ustGiyim:
        return kombin.ustGiyim?.id;
      case KiyafetKategorisi.altGiyim:
        return kombin.altGiyim?.id;
      case KiyafetKategorisi.disGiyim:
        return kombin.disGiyim?.id;
      case KiyafetKategorisi.ayakkabi:
        return kombin.ayakkabi?.id;
      case KiyafetKategorisi.aksesuar:
      case KiyafetKategorisi.canta:
        return kombin.aksesuar?.id;
    }
  }
}
