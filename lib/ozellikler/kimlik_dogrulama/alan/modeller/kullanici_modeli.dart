import 'package:equatable/equatable.dart';

/// Kullanıcı profil modeli.
/// Auth bilgileri + onboarding tercihleri.
class KullaniciModeli extends Equatable {
  final String id;
  final String isim;
  final String eposta;
  final String? sehir;
  final String? stilTipi;
  final List<String> kullanimAmaclari;
  final bool onboardingTamamlandi;
  final bool bildirimAktif;
  final DateTime olusturulmaTarihi;

  const KullaniciModeli({
    required this.id,
    required this.isim,
    required this.eposta,
    this.sehir,
    this.stilTipi,
    this.kullanimAmaclari = const [],
    this.onboardingTamamlandi = false,
    this.bildirimAktif = true,
    required this.olusturulmaTarihi,
  });

  /// Supabase JSON'dan oluştur
  factory KullaniciModeli.fromJson(Map<String, dynamic> json) {
    return KullaniciModeli(
      id: json['id'] as String,
      isim: json['isim'] as String? ?? '',
      eposta: json['eposta'] as String? ?? '',
      sehir: json['sehir'] as String?,
      stilTipi: json['stil_tipi'] as String?,
      kullanimAmaclari: (json['kullanim_amaclari'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      onboardingTamamlandi: json['onboarding_tamamlandi'] as bool? ?? false,
      bildirimAktif: json['bildirim_aktif'] as bool? ?? true,
      olusturulmaTarihi: DateTime.parse(
        json['olusturulma_tarihi'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isim': isim,
      'eposta': eposta,
      'sehir': sehir,
      'stil_tipi': stilTipi,
      'kullanim_amaclari': kullanimAmaclari,
      'onboarding_tamamlandi': onboardingTamamlandi,
      'bildirim_aktif': bildirimAktif,
    };
  }

  /// Kopyala ve güncelle
  KullaniciModeli kopyala({
    String? isim,
    String? sehir,
    String? stilTipi,
    List<String>? kullanimAmaclari,
    bool? onboardingTamamlandi,
    bool? bildirimAktif,
  }) {
    return KullaniciModeli(
      id: id,
      isim: isim ?? this.isim,
      eposta: eposta,
      sehir: sehir ?? this.sehir,
      stilTipi: stilTipi ?? this.stilTipi,
      kullanimAmaclari: kullanimAmaclari ?? this.kullanimAmaclari,
      onboardingTamamlandi: onboardingTamamlandi ?? this.onboardingTamamlandi,
      bildirimAktif: bildirimAktif ?? this.bildirimAktif,
      olusturulmaTarihi: olusturulmaTarihi,
    );
  }

  @override
  List<Object?> get props => [
        id,
        isim,
        eposta,
        sehir,
        stilTipi,
        kullanimAmaclari,
        onboardingTamamlandi,
        bildirimAktif,
      ];
}
