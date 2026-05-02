import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:combin_app/cekirdek/sabitler/api_sabitleri.dart';
import '../alan/modeller/hava_durumu_modeli.dart';

/// Open-Meteo API ile hava durumu servisi.
/// Ücretsiz, API key gerektirmez, günlük 10.000 istek limiti.
class HavaDurumuServisi {
  final http.Client _httpClient;

  HavaDurumuServisi({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Türkiye şehirlerinin koordinatları
  static const Map<String, Map<String, double>> sehirKoordinatlari = {
    'İstanbul': {'lat': 41.0082, 'lon': 28.9784},
    'Ankara': {'lat': 39.9334, 'lon': 32.8597},
    'İzmir': {'lat': 38.4192, 'lon': 27.1287},
    'Bursa': {'lat': 40.1885, 'lon': 29.0610},
    'Antalya': {'lat': 36.8969, 'lon': 30.7133},
    'Adana': {'lat': 37.0000, 'lon': 35.3213},
    'Konya': {'lat': 37.8746, 'lon': 32.4932},
    'Gaziantep': {'lat': 37.0662, 'lon': 37.3833},
    'Mersin': {'lat': 36.8121, 'lon': 34.6415},
    'Kayseri': {'lat': 38.7312, 'lon': 35.4787},
    'Eskişehir': {'lat': 39.7767, 'lon': 30.5206},
    'Trabzon': {'lat': 41.0027, 'lon': 39.7168},
    'Samsun': {'lat': 41.2928, 'lon': 36.3313},
    'Diyarbakır': {'lat': 37.9144, 'lon': 40.2306},
    'Denizli': {'lat': 37.7765, 'lon': 29.0864},
    'Muğla': {'lat': 37.2153, 'lon': 28.3636},
    'Tekirdağ': {'lat': 40.9781, 'lon': 27.5117},
    'Sakarya': {'lat': 40.6940, 'lon': 30.4358},
    'Kocaeli': {'lat': 40.7654, 'lon': 29.9408},
    'Balıkesir': {'lat': 39.6484, 'lon': 27.8826},
  };

  /// Şehre göre hava durumu getir
  Future<HavaDurumuModeli> havaDurumuGetir(String sehir) async {
    final koordinat = sehirKoordinatlari[sehir];
    if (koordinat == null) {
      // Varsayılan olarak İstanbul
      return havaDurumuGetirKoordinat(41.0082, 28.9784);
    }

    return havaDurumuGetirKoordinat(koordinat['lat']!, koordinat['lon']!);
  }

  /// Koordinata göre hava durumu getir
  Future<HavaDurumuModeli> havaDurumuGetirKoordinat(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      '${ApiSabitleri.havaDurumuBaseUrl}/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,'
      'apparent_temperature,weather_code,wind_speed_10m'
      '&daily=precipitation_probability_max'
      '&timezone=auto'
      '&forecast_days=1',
    );

    try {
      final yanit = await _httpClient.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (yanit.statusCode == 200) {
        final json = jsonDecode(yanit.body) as Map<String, dynamic>;
        return HavaDurumuModeli.fromJson(json);
      } else {
        throw Exception('Hava durumu alınamadı: HTTP ${yanit.statusCode}');
      }
    } catch (e) {
      throw Exception('Hava durumu servisi hatası: $e');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
