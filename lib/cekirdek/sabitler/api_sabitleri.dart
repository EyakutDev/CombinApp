/// API sabitleri ve endpoint tanımları.
class ApiSabitleri {
  ApiSabitleri._();

  // === Supabase ===
  // Not: Bu değerler Supabase projesi oluşturulunca güncellenecek
  static const String supabaseUrl = 'https://szkajskjsarnqzzfyqag.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6a2Fqc2tqc2FybnF6emZ5cWFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2ODQzNDIsImV4cCI6MjA5MjI2MDM0Mn0.a081VU56yXq-Btp-xcbi9qrO7-CuPY6z4QNp-mbbWGM';

  // === Hava Durumu (Open-Meteo) ===
  /// Open-Meteo API — ücretsiz, API key gerektirmez
  static const String havaDurumuBaseUrl = 'https://api.open-meteo.com/v1';
  static const String havaDurumuTahminEndpoint = '$havaDurumuBaseUrl/forecast';

  // === Storage Bucket İsimleri ===
  static const String kiyafetBucket = 'kiyafetler';

  // === Görsel Ayarları ===
  static const int gorselMaxGenislik = 800;
  static const int gorselMaxYukseklik = 800;
  static const int thumbnailBoyutu = 200;
  static const int gorselKalitesi = 80; // %80 WebP kalitesi
}
