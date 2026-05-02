import 'package:equatable/equatable.dart';

/// Kıyafet kategorileri
enum KiyafetKategorisi {
  ustGiyim('ust_giyim', 'Üst Giyim', 'ust'),
  altGiyim('alt_giyim', 'Alt Giyim', 'alt'),
  disGiyim('dis_giyim', 'Dış Giyim', 'dis'),
  ayakkabi('ayakkabi', 'Ayakkabı', 'ayakkabi'),
  aksesuar('aksesuar', 'Aksesuar', 'aksesuar'),
  canta('canta', 'Çanta', 'aksesuar');

  final String deger;
  final String etiket;
  final String kombinRolu; // kombin motorunda kullanılacak rol

  const KiyafetKategorisi(this.deger, this.etiket, this.kombinRolu);

  static KiyafetKategorisi? degerdenBul(String deger) {
    try {
      return KiyafetKategorisi.values.firstWhere((k) => k.deger == deger);
    } catch (_) {
      return null;
    }
  }
}

/// Kıyafet kalınlığı
enum KiyafetKalinligi {
  ince('ince', 'İnce'),
  orta('orta', 'Orta'),
  kalin('kalin', 'Kalın');

  final String deger;
  final String etiket;

  const KiyafetKalinligi(this.deger, this.etiket);

  static KiyafetKalinligi? degerdenBul(String deger) {
    try {
      return KiyafetKalinligi.values.firstWhere((k) => k.deger == deger);
    } catch (_) {
      return null;
    }
  }
}

/// Mevsim
enum Mevsim {
  ilkbahar('ilkbahar', 'İlkbahar'),
  yaz('yaz', 'Yaz'),
  sonbahar('sonbahar', 'Sonbahar'),
  kis('kis', 'Kış'),
  tumMevsim('tum_mevsim', 'Tüm Mevsim');

  final String deger;
  final String etiket;

  const Mevsim(this.deger, this.etiket);

  static Mevsim? degerdenBul(String deger) {
    try {
      return Mevsim.values.firstWhere((m) => m.deger == deger);
    } catch (_) {
      return null;
    }
  }
}

/// Önceden tanımlı renk paleti
class KiyafetRengi {
  final String id;
  final String isim;
  final int renkKodu; // 0xFFXXXXXX

  const KiyafetRengi({
    required this.id,
    required this.isim,
    required this.renkKodu,
  });

  /// Önceden tanımlanmış 15 temel renk
  static const List<KiyafetRengi> tumRenkler = [
    KiyafetRengi(id: 'siyah', isim: 'Siyah', renkKodu: 0xFF1A1A1A),
    KiyafetRengi(id: 'beyaz', isim: 'Beyaz', renkKodu: 0xFFF5F5F5),
    KiyafetRengi(id: 'gri', isim: 'Gri', renkKodu: 0xFF9E9E9E),
    KiyafetRengi(id: 'lacivert', isim: 'Lacivert', renkKodu: 0xFF1B2A4A),
    KiyafetRengi(id: 'mavi', isim: 'Mavi', renkKodu: 0xFF4A90D9),
    KiyafetRengi(id: 'kirmizi', isim: 'Kırmızı', renkKodu: 0xFFC84153),
    KiyafetRengi(id: 'pembe', isim: 'Pembe', renkKodu: 0xFFE8A0B0),
    KiyafetRengi(id: 'yesil', isim: 'Yeşil', renkKodu: 0xFF5B8C5A),
    KiyafetRengi(id: 'sari', isim: 'Sarı', renkKodu: 0xFFF2C94C),
    KiyafetRengi(id: 'turuncu', isim: 'Turuncu', renkKodu: 0xFFE8875B),
    KiyafetRengi(id: 'mor', isim: 'Mor', renkKodu: 0xFF8B5CF6),
    KiyafetRengi(id: 'kahverengi', isim: 'Kahverengi', renkKodu: 0xFF8B6F47),
    KiyafetRengi(id: 'bej', isim: 'Bej', renkKodu: 0xFFD4C5A9),
    KiyafetRengi(id: 'bordo', isim: 'Bordo', renkKodu: 0xFF722F37),
    KiyafetRengi(id: 'haki', isim: 'Haki', renkKodu: 0xFF7A8450),
  ];

  static KiyafetRengi? iddenBul(String id) {
    try {
      return tumRenkler.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Kıyafet veri modeli.
class KiyafetModeli extends Equatable {
  final String id;
  final String kullaniciId;
  final String? isim;
  final KiyafetKategorisi kategori;
  final String renk; // KiyafetRengi.id
  final List<Mevsim> mevsimler;
  final KiyafetKalinligi kalinlik;
  final String gorselUrl;
  final String? kucukGorselUrl;
  final bool favori;
  final bool aktif;
  final String? notlar;
  final DateTime olusturulmaTarihi;
  final DateTime guncellemeTarihi;

  const KiyafetModeli({
    required this.id,
    required this.kullaniciId,
    this.isim,
    required this.kategori,
    required this.renk,
    required this.mevsimler,
    required this.kalinlik,
    required this.gorselUrl,
    this.kucukGorselUrl,
    this.favori = false,
    this.aktif = true,
    this.notlar,
    required this.olusturulmaTarihi,
    required this.guncellemeTarihi,
  });

  /// Supabase JSON'dan oluştur
  factory KiyafetModeli.fromJson(Map<String, dynamic> json) {
    return KiyafetModeli(
      id: json['id'] as String,
      kullaniciId: json['kullanici_id'] as String,
      isim: json['isim'] as String?,
      kategori: KiyafetKategorisi.degerdenBul(json['kategori'] as String) ??
          KiyafetKategorisi.ustGiyim,
      renk: json['renk'] as String,
      mevsimler: (json['mevsimler'] as List<dynamic>?)
              ?.map((m) => Mevsim.degerdenBul(m as String))
              .whereType<Mevsim>()
              .toList() ??
          [],
      kalinlik: KiyafetKalinligi.degerdenBul(json['kalinlik'] as String) ??
          KiyafetKalinligi.orta,
      gorselUrl: json['gorsel_url'] as String,
      kucukGorselUrl: json['kucuk_gorsel_url'] as String?,
      favori: json['favori'] as bool? ?? false,
      aktif: json['aktif'] as bool? ?? true,
      notlar: json['notlar'] as String?,
      olusturulmaTarihi: DateTime.parse(json['olusturulma_tarihi'] as String),
      guncellemeTarihi: DateTime.parse(json['guncelleme_tarihi'] as String),
    );
  }

  /// JSON'a dönüştür (insert/update için)
  Map<String, dynamic> toJson() {
    return {
      'kullanici_id': kullaniciId,
      'isim': isim,
      'kategori': kategori.deger,
      'renk': renk,
      'mevsimler': mevsimler.map((m) => m.deger).toList(),
      'kalinlik': kalinlik.deger,
      'gorsel_url': gorselUrl,
      'kucuk_gorsel_url': kucukGorselUrl,
      'favori': favori,
      'aktif': aktif,
      'notlar': notlar,
    };
  }

  /// Kopyala ve güncelle
  KiyafetModeli kopyala({
    String? isim,
    KiyafetKategorisi? kategori,
    String? renk,
    List<Mevsim>? mevsimler,
    KiyafetKalinligi? kalinlik,
    String? gorselUrl,
    String? kucukGorselUrl,
    bool? favori,
    bool? aktif,
    String? notlar,
  }) {
    return KiyafetModeli(
      id: id,
      kullaniciId: kullaniciId,
      isim: isim ?? this.isim,
      kategori: kategori ?? this.kategori,
      renk: renk ?? this.renk,
      mevsimler: mevsimler ?? this.mevsimler,
      kalinlik: kalinlik ?? this.kalinlik,
      gorselUrl: gorselUrl ?? this.gorselUrl,
      kucukGorselUrl: kucukGorselUrl ?? this.kucukGorselUrl,
      favori: favori ?? this.favori,
      aktif: aktif ?? this.aktif,
      notlar: notlar ?? this.notlar,
      olusturulmaTarihi: olusturulmaTarihi,
      guncellemeTarihi: DateTime.now(),
    );
  }

  /// Görüntülenecek renk bilgisi
  KiyafetRengi? get renkBilgisi => KiyafetRengi.iddenBul(renk);

  @override
  List<Object?> get props => [
        id, kullaniciId, isim, kategori, renk, mevsimler,
        kalinlik, gorselUrl, favori, aktif,
      ];
}
