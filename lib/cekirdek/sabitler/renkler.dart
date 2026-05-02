import 'dart:ui';

/// Uygulama genelinde kullanılan renk sabitleri.
/// Premium Liquid Glass tasarım dili — krem arka plan, beyaz cam kartlar, #D94A56 vurgu.
class AppRenkler {
  AppRenkler._();

  // === Ana Renkler ===
  /// Ana vurgu rengi — butonlar, seçili durumlar, ikon detayları
  static const Color anaVurgu = Color(0xFFD94A56);
  static const Color anaVurguAcik = Color(0xFFE87A85);
  static const Color anaVurguKoyu = Color(0xFFB53945);

  // === Arka Plan ===
  /// Uygulamanın ana arka planı (Krem/Kirli Beyaz)
  static const Color arkaPlan = Color(0xFFFFFDFB);
  /// Kartlar için saf beyaz (Krem üzerinde öne çıkması için)
  static const Color kartArkaPlan = Color(0xFFFFFFFF);
  /// İkincil arka plan (grouping alanları, çipler)
  static const Color ikincilArkaPlan = Color(0xFFF7F4F2);

  // === Metin Renkleri ===
  /// Başlıklar ve ana metinler (Kömür Grisi)
  static const Color metinBirincil = Color(0xFF2D2D2D);
  /// Alt başlıklar ve etiketler
  static const Color metinIkincil = Color(0xFF8E8E8E);
  /// Placeholder ve pasif metinler
  static const Color metinUcuncul = Color(0xFFB5B5B5);
  static const Color metinBeyaz = Color(0xFFFFFFFF);

  // === Cam (Glass) Efekt Renkleri ===
  /// Glassmorphism kart arka planı
  static const Color camArkaPlan = Color(0xE6FFFFFF); // %90 opak beyaz
  /// Glassmorphism kenarlık (Işık yansıması için)
  static const Color camKenarlik = Color(0x66FFFFFF); // %40 opak beyaz
  /// Glassmorphism gölge
  static const Color camGolge = Color(0x0A000000); // %4 siyah (Çok daha hafif)

  // === Sıvı Gradyan (Liquid Mesh) Renkleri ===
  static const Color meshGradient1 = Color(0xFFE87A85); // Açık Pembe
  static const Color meshGradient2 = Color(0xFFD94A56); // Kırmızı
  static const Color meshGradient3 = Color(0xFFFDE8E9); // Krem/Pembe

  // === Durum Renkleri ===
  static const Color basari = Color(0xFF5CB85C);
  static const Color uyari = Color(0xFFF0AD4E);
  static const Color hata = Color(0xFFD9534F);
  static const Color bilgi = Color(0xFF5BC0DE);

  // === Navbar ===
  static const Color navbarSecili = anaVurgu;
  static const Color navbarSecilmemis = Color(0xFFB5B5B5);
  static const Color navbarArkaPlan = Color(0xF2FFFFFF); // %95 beyaz

  // === Diğer ===
  static const Color ayirici = Color(0xFFF0EBE6);
  static const Color deaktif = Color(0xFFE0E0E0);
  static const Color favoriKalp = anaVurgu;
}
