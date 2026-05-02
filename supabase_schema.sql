-- =============================================
-- CombinApp — Veritabanı Tabloları
-- Bu SQL'i Supabase Dashboard > SQL Editor'de çalıştır
-- =============================================

-- 1. Kullanıcı profil tablosu
CREATE TABLE IF NOT EXISTS kullanicilar (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    isim TEXT NOT NULL,
    eposta TEXT,
    sehir TEXT,
    stil_tipi TEXT,
    kullanim_amaclari TEXT[] DEFAULT '{}',
    onboarding_tamamlandi BOOLEAN DEFAULT FALSE,
    bildirim_aktif BOOLEAN DEFAULT TRUE,
    olusturulma_tarihi TIMESTAMPTZ DEFAULT NOW(),
    guncelleme_tarihi TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Kıyafetler tablosu
CREATE TABLE IF NOT EXISTS kiyafetler (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kullanici_id UUID NOT NULL REFERENCES kullanicilar(id) ON DELETE CASCADE,
    isim TEXT,
    kategori TEXT NOT NULL,
    renk TEXT NOT NULL,
    mevsimler TEXT[] NOT NULL DEFAULT '{}',
    kalinlik TEXT NOT NULL DEFAULT 'orta',
    gorsel_url TEXT NOT NULL,
    kucuk_gorsel_url TEXT,
    favori BOOLEAN DEFAULT FALSE,
    aktif BOOLEAN DEFAULT TRUE,
    notlar TEXT,
    olusturulma_tarihi TIMESTAMPTZ DEFAULT NOW(),
    guncelleme_tarihi TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Kombinler tablosu
CREATE TABLE IF NOT EXISTS kombinler (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kullanici_id UUID NOT NULL REFERENCES kullanicilar(id) ON DELETE CASCADE,
    etkinlik_tipi TEXT,
    favori BOOLEAN DEFAULT FALSE,
    notlar TEXT,
    olusturulma_tarihi TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Kombin parçaları tablosu
CREATE TABLE IF NOT EXISTS kombin_parcalari (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kombin_id UUID NOT NULL REFERENCES kombinler(id) ON DELETE CASCADE,
    kiyafet_id UUID NOT NULL REFERENCES kiyafetler(id) ON DELETE CASCADE,
    rol TEXT NOT NULL,
    sira INT DEFAULT 0
);

-- 5. Planlar tablosu
CREATE TABLE IF NOT EXISTS planlar (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kullanici_id UUID NOT NULL REFERENCES kullanicilar(id) ON DELETE CASCADE,
    kombin_id UUID NOT NULL REFERENCES kombinler(id) ON DELETE CASCADE,
    tarih DATE NOT NULL,
    olusturulma_tarihi TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(kullanici_id, tarih)
);

-- 6. Kullanım geçmişi
CREATE TABLE IF NOT EXISTS kullanim_gecmisi (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kullanici_id UUID NOT NULL REFERENCES kullanicilar(id) ON DELETE CASCADE,
    kiyafet_id UUID NOT NULL REFERENCES kiyafetler(id) ON DELETE CASCADE,
    kombin_id UUID REFERENCES kombinler(id) ON DELETE SET NULL,
    tarih DATE NOT NULL DEFAULT CURRENT_DATE,
    olusturulma_tarihi TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- İndeksler
-- =============================================
CREATE INDEX IF NOT EXISTS idx_kiyafet_kullanici ON kiyafetler(kullanici_id);
CREATE INDEX IF NOT EXISTS idx_kiyafet_kategori ON kiyafetler(kullanici_id, kategori);
CREATE INDEX IF NOT EXISTS idx_kiyafet_favori ON kiyafetler(kullanici_id, favori);
CREATE INDEX IF NOT EXISTS idx_kombin_kullanici ON kombinler(kullanici_id);
CREATE INDEX IF NOT EXISTS idx_kombin_parcalari_kombin ON kombin_parcalari(kombin_id);
CREATE INDEX IF NOT EXISTS idx_plan_tarih ON planlar(kullanici_id, tarih);
CREATE INDEX IF NOT EXISTS idx_kullanim_kiyafet ON kullanim_gecmisi(kiyafet_id, tarih);

-- =============================================
-- Row Level Security (RLS)
-- =============================================

-- Kullanıcılar
ALTER TABLE kullanicilar ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Kullanici kendi verisini okur" ON kullanicilar
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Kullanici kendi verisini gunceller" ON kullanicilar
    FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Kullanici kendi kaydini olusturur" ON kullanicilar
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Kıyafetler
ALTER TABLE kiyafetler ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Kullanici kendi kiyafetlerini okur" ON kiyafetler
    FOR SELECT USING (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kiyafet ekler" ON kiyafetler
    FOR INSERT WITH CHECK (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kendi kiyafetini gunceller" ON kiyafetler
    FOR UPDATE USING (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kendi kiyafetini siler" ON kiyafetler
    FOR DELETE USING (auth.uid() = kullanici_id);

-- Kombinler
ALTER TABLE kombinler ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Kullanici kendi kombinlerini okur" ON kombinler
    FOR SELECT USING (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kombin ekler" ON kombinler
    FOR INSERT WITH CHECK (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kendi kombinini gunceller" ON kombinler
    FOR UPDATE USING (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kendi kombinini siler" ON kombinler
    FOR DELETE USING (auth.uid() = kullanici_id);

-- Kombin parçaları
ALTER TABLE kombin_parcalari ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Kullanici kendi kombin parcalarini okur" ON kombin_parcalari
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM kombinler WHERE kombinler.id = kombin_parcalari.kombin_id AND kombinler.kullanici_id = auth.uid())
    );
CREATE POLICY "Kullanici kombin parcasi ekler" ON kombin_parcalari
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM kombinler WHERE kombinler.id = kombin_parcalari.kombin_id AND kombinler.kullanici_id = auth.uid())
    );
CREATE POLICY "Kullanici kendi kombin parcasini siler" ON kombin_parcalari
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM kombinler WHERE kombinler.id = kombin_parcalari.kombin_id AND kombinler.kullanici_id = auth.uid())
    );

-- Planlar
ALTER TABLE planlar ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Kullanici kendi planlarini okur" ON planlar
    FOR SELECT USING (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici plan ekler" ON planlar
    FOR INSERT WITH CHECK (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kendi planini gunceller" ON planlar
    FOR UPDATE USING (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici kendi planini siler" ON planlar
    FOR DELETE USING (auth.uid() = kullanici_id);

-- Kullanım geçmişi
ALTER TABLE kullanim_gecmisi ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Kullanici kendi gecmisini okur" ON kullanim_gecmisi
    FOR SELECT USING (auth.uid() = kullanici_id);
CREATE POLICY "Kullanici gecmis ekler" ON kullanim_gecmisi
    FOR INSERT WITH CHECK (auth.uid() = kullanici_id);

-- =============================================
-- Storage Bucket
-- =============================================
-- Not: Bu kısmı Supabase Dashboard > Storage'dan manuel oluştur:
-- Bucket adı: kiyafetler
-- Public: false (RLS ile kontrol)
-- Allowed MIME types: image/jpeg, image/png, image/webp
-- Max file size: 5MB

-- Storage policy (SQL Editor'den çalıştır):
INSERT INTO storage.buckets (id, name, public) VALUES ('kiyafetler', 'kiyafetler', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Kullanici kendi gorsellerini yukler" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'kiyafetler' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Kullanici kendi gorsellerini okur" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'kiyafetler' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Kullanici kendi gorsellerini siler" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'kiyafetler' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );
