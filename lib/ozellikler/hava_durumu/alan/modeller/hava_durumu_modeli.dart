import 'package:equatable/equatable.dart';

/// Hava durumu veri modeli.
/// Open-Meteo API'den gelen verileri temsil eder.
class HavaDurumuModeli extends Equatable {
  final double sicaklik; // °C
  final double hissedilenSicaklik; // °C
  final int havaDurumuKodu; // WMO weather code
  final double ruzgarHizi; // km/s
  final int nem; // %
  final double yagisOlasiligi; // %

  const HavaDurumuModeli({
    required this.sicaklik,
    required this.hissedilenSicaklik,
    required this.havaDurumuKodu,
    required this.ruzgarHizi,
    required this.nem,
    required this.yagisOlasiligi,
  });

  /// Open-Meteo API JSON'dan oluştur
  factory HavaDurumuModeli.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>?;

    // Günlük yağış olasılığını al (varsa)
    double yagisOlasiligi = 0;
    if (daily != null &&
        daily['precipitation_probability_max'] != null &&
        (daily['precipitation_probability_max'] as List).isNotEmpty) {
      yagisOlasiligi =
          (daily['precipitation_probability_max'] as List)[0]?.toDouble() ?? 0;
    }

    return HavaDurumuModeli(
      sicaklik: (current['temperature_2m'] as num).toDouble(),
      hissedilenSicaklik: (current['apparent_temperature'] as num).toDouble(),
      havaDurumuKodu: current['weather_code'] as int,
      ruzgarHizi: (current['wind_speed_10m'] as num).toDouble(),
      nem: (current['relative_humidity_2m'] as num).toInt(),
      yagisOlasiligi: yagisOlasiligi,
    );
  }

  /// WMO hava durumu kodundan açıklama
  String get havaDurumuAciklamasi {
    switch (havaDurumuKodu) {
      case 0:
        return 'Açık';
      case 1:
        return 'Çoğunlukla açık';
      case 2:
        return 'Parçalı bulutlu';
      case 3:
        return 'Kapalı';
      case 45:
      case 48:
        return 'Sisli';
      case 51:
      case 53:
      case 55:
        return 'Çisenti';
      case 56:
      case 57:
        return 'Dondurucu çisenti';
      case 61:
      case 63:
      case 65:
        return 'Yağmurlu';
      case 66:
      case 67:
        return 'Dondurucu yağmur';
      case 71:
      case 73:
      case 75:
        return 'Karlı';
      case 77:
        return 'Kar taneleri';
      case 80:
      case 81:
      case 82:
        return 'Sağanak yağış';
      case 85:
      case 86:
        return 'Kar yağışı';
      case 95:
        return 'Gök gürültülü fırtına';
      case 96:
      case 99:
        return 'Dolu ile fırtına';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Hava durumu ikonu (Material Icons)
  String get havaDurumuEmoji {
    if (havaDurumuKodu == 0) return '☀️';
    if (havaDurumuKodu <= 3) return '⛅';
    if (havaDurumuKodu <= 48) return '🌫️';
    if (havaDurumuKodu <= 57) return '🌦️';
    if (havaDurumuKodu <= 67) return '🌧️';
    if (havaDurumuKodu <= 77) return '🌨️';
    if (havaDurumuKodu <= 82) return '🌧️';
    if (havaDurumuKodu <= 86) return '🌨️';
    return '⛈️';
  }

  /// Şemsiye gerekiyor mu?
  bool get semsiyeGerekli => yagisOlasiligi > 40;

  /// Sıcaklık seviyesi (kombin motoru için)
  SicaklikSeviyesi get sicaklikSeviyesi {
    if (sicaklik < 5) return SicaklikSeviyesi.cokSoguk;
    if (sicaklik < 12) return SicaklikSeviyesi.soguk;
    if (sicaklik < 18) return SicaklikSeviyesi.serin;
    if (sicaklik < 25) return SicaklikSeviyesi.ilik;
    if (sicaklik < 32) return SicaklikSeviyesi.sicak;
    return SicaklikSeviyesi.cokSicak;
  }

  @override
  List<Object?> get props => [
        sicaklik, hissedilenSicaklik, havaDurumuKodu,
        ruzgarHizi, nem, yagisOlasiligi,
      ];
}

/// Sıcaklık seviyeleri — kombin motorunda kullanılır
enum SicaklikSeviyesi {
  cokSoguk('çok soğuk'), // < 5°C
  soguk('soğuk'),         // 5-12°C
  serin('serin'),         // 12-18°C
  ilik('ılık'),           // 18-25°C
  sicak('sıcak'),         // 25-32°C
  cokSicak('çok sıcak');  // > 32°C

  final String etiket;
  const SicaklikSeviyesi(this.etiket);
}
