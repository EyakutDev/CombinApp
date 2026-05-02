# CombinApp — Geliştirme Walkthrough

## Faz 1 — Temel Altyapı (Tamamlandı ✅)

### Önceki Özet
- Flutter projesi + 22 bağımlılık
- Feature-first Clean Architecture
- Liquid Glass tema sistemi (#C84153 vurgu, Inter fontu)
- Auth modülü (Supabase, BLoC, Türkçe hata çevirisi)
- Onboarding (4 adım), GoRouter, 5 tab bottom navbar
- Gardırop modülü (CRUD, grid/liste, filtre/arama, favori, görsel pipeline)
- Supabase veritabanı şeması (6 tablo, RLS, storage bucket)

---

## Faz 2 — Hava Durumu & Kombin Motoru (Tamamlandı ✅)

### Hava Durumu Modülü

**Model** (`hava_durumu_modeli.dart`):
- Open-Meteo WMO hava durumu kodları → Türkçe açıklamalar
- Sıcaklık seviyeleri: çok soğuk (< 5°C) → çok sıcak (> 32°C)
- Emoji desteği (☀️ ⛅ 🌧️ 🌨️ ⛈️)
- Şemsiye gerekli mi kontrolü (yağış olasılığı > %40)

**Servis** (`hava_durumu_servisi.dart`):
- Open-Meteo API — ücretsiz, API key gereksiz
- 20 Türkiye şehri koordinatları (İstanbul, Ankara, İzmir, Bursa...)
- HTTP istek, 10 saniye timeout, hata yönetimi
- Current weather + daily precipitation probability

**BLoC** (`hava_durumu_bloc.dart`):
- Event/State/BLoC tek dosyada (basit modül)
- Şehre göre hava durumu yükleme

### Kombin Motoru

**Model** (`kombin_modeli.dart`):
- 5 pozisyon: üst giyim, alt giyim, dış giyim, ayakkabı, aksesuar
- Minimum geçerlilik: üst + alt zorunlu
- Parça değiştirme metodu
- JSON serialization (Supabase kayıt)
- Kombin parçaları JSON (kombin_parcalari tablosu)

**Motor** (`kombin_motoru.dart`) — Rule-based, cihaz tarafında:
1. **Hava durumu filtresi**: Sıcaklık → mevsim + kalınlık eşleştirme
   - Çok soğuk → kış + kalın
   - Sıcak → yaz + ince
2. **Renk uyumu tablosu**: 15 renk için komşuluk matrisi
   - Nötr renkler (siyah, beyaz, gri, lacivert, bej) her şeyle uyar
   - Her renk için uyumlu renkler tanımlı
3. **Dış giyim kontrolü**: < 18°C, yağmur riski, yüksek rüzgar
4. **Parça değiştirme**: Mevcut kombinden tek parça swap

**BLoC** (`kombin_bloc.dart`):
- KombinOner: kıyafetleri yükle → motor çalıştır
- KombinYenile: farklı kombin (shuffle)
- ParcaDegistir: tek kategori değiştir
- EtkinlikTipiDegistir: günlük, iş, davet, spor filtresi
- Kıyafet cache'leme (tekrar çekmemek için)

### Kombin Ekranı (`kombin_ekrani.dart`):
- Başlangıç durumu: büyük ikon + "Kombin Öner" butonu
- Etkinlik seçici: ☕ Günlük, 💼 İş, 🎉 Davet, 🏃 Spor
- Parça kartları: fotoğraf + renk noktası + kalınlık
- Her parçada "Değiştir" butonu (swap_horiz ikonu)
- "Farklı Kombin Öner" yenile butonu

### Ana Sayfa Tamamlama
- **Dinamik selam**: Saat < 6 → "İyi geceler", < 12 → "Günaydın", < 18 → "İyi günler", else → "İyi akşamlar"
- **Canlı hava durumu kartı**: Emoji, sıcaklık, açıklama, hissedilen, şemsiye uyarısı
- **Hızlı işlemler**: "Kıyafet Ekle" → gardırop ekleme ekranı, "Kombin Oluştur" → kombin öner
- **Profil dinamikleştirme**: Kullanıcı adı/email BLoC'tan, çıkış butonu çalışır

---

## Doğrulama
- `flutter analyze`: **0 error** ✅
- Warning'ler: unused import'lar (ileride kullanılacak), async BuildContext
- Toplam **40+ Dart dosyası** oluşturuldu

## Proje Yapısı (Güncel)
```
lib/
├── main.dart
├── cekirdek/
│   ├── sabitler/ (4 dosya)
│   ├── tema/ (1 dosya)
│   ├── widgets/ (5 dosya)
│   ├── utils/ (gorsel_yardimcilari)
│   └── di/ (bagimlliklar)
├── navigasyon/ (2 dosya)
└── ozellikler/
    ├── kimlik_dogrulama/ (9 dosya)
    ├── onboarding/ (1 dosya)
    ├── ana_sayfa/ (tab_ekranlari)
    ├── gardrop/ (12 dosya)
    ├── hava_durumu/ (3 dosya)
    └── kombin/ (4 dosya)
```

## Sonraki Adım
Faz 3 — Planlama & Polish: haftalık takvim, güne kombin atama, kullanım geçmişi, profil düzenleme, UI animasyonlar.

> [!IMPORTANT]
> `supabase_schema.sql` dosyasını Supabase Dashboard SQL Editor'de çalıştırman gerekiyor. Tablolar oluşturulmadan uygulama çalışmaz.
