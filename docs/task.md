# CombinApp — Geliştirme Görev Listesi

## Faz 1.1 — Proje Kurulumu & Temel Altyapı ✅

- [x] Flutter projesi oluştur
- [x] pubspec.yaml bağımlılıkları ekle
- [x] Klasör yapısını oluştur
- [x] Tema sistemi: Liquid Glass renkleri, tipografi, kart stilleri
- [x] Widget kütüphanesi (CamKart, BirincilButon, BosDurum, HataDurumu, Yukleniyor)
- [x] Supabase bağlantı altyapısı (main.dart)

## Faz 1.2 — Auth & Onboarding ✅

- [x] Auth BLoC (giriş, kayıt, çıkış, durum yönetimi)
- [x] Giriş & Kayıt ekranları
- [x] Onboarding (4 adım: şehir, stil, amaç, hava izni)
- [x] GoRouter: auth guard + onboarding guard

## Faz 1.3 — Navigasyon & Ana Sayfa İskeleti ✅

- [x] Bottom navbar shell (5 tab, IndexedStack, buzlu cam)
- [x] Ana sayfa iskelet

## Faz 1.4 — Gardırop Modülü ✅

- [x] Kıyafet modeli (6 kategori, 3 kalınlık, 5 mevsim, 15 renk)
- [x] Gardırop repository + veri kaynağı (Supabase CRUD)
- [x] Gardırop BLoC (8 event handler)
- [x] Kıyafet ekleme/düzenleme ekranı (fotoğraf pipeline)
- [x] Gardırop listeleme (grid/liste, filtre, arama)
- [x] Kıyafet detay ekranı (SliverAppBar)
- [x] Görsel işleme utility (seç → kırp → WebP sıkıştır → thumbnail)
- [x] Supabase veritabanı şeması (SQL dosyası)

## Faz 2 — Kombin Motoru & Hava Durumu ✅

- [x] Hava durumu modeli (WMO kodları, sıcaklık seviyeleri, emoji)
- [x] Hava durumu servisi (Open-Meteo API, 20 şehir)
- [x] Hava durumu BLoC
- [x] Kombin modeli (parçalar, JSON, parça değiştirme)
- [x] Kombin motoru (rule-based, renk uyumu tablosu, hava filtresi)
- [x] Kombin BLoC (öner, yenile, parça değiştir, etkinlik)
- [x] Kombin ekranı (etkinlik filtre, parça kartları, değiştir butonları)
- [x] Ana sayfa tamamlama (dinamik selam, canlı hava durumu, hızlı işlemler)
- [x] Profil ekranı dinamikleştirme (BLoC, çıkış butonu)

## Faz 3 — Planlama & Polish (Sonraki)

- [ ] Plan ekranı: haftalık takvim
- [ ] Güne kombin atama
- [ ] Kullanım geçmişi
- [ ] Profil ekranı düzenleme
- [ ] UI polish + animasyonlar
- [ ] Genel hata/boş durum tamamlama
