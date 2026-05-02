import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../alan/modeller/kiyafet_modeli.dart';

/// Supabase ile gardırop veri işlemleri.
class GardropVeriKaynagi {
  final SupabaseClient _supabase;

  GardropVeriKaynagi({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  /// Kullanıcının tüm kıyafetlerini getir
  Future<List<KiyafetModeli>> tumKiyafetleriGetir() async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Oturum bulunamadı');

    final veri = await _supabase
        .from('kiyafetler')
        .select()
        .eq('kullanici_id', kullaniciId)
        .eq('aktif', true)
        .order('olusturulma_tarihi', ascending: false);

    return (veri as List)
        .map((json) => KiyafetModeli.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Kategoriye göre filtrele
  Future<List<KiyafetModeli>> kategoriyeGoreGetir(
      KiyafetKategorisi kategori) async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Oturum bulunamadı');

    final veri = await _supabase
        .from('kiyafetler')
        .select()
        .eq('kullanici_id', kullaniciId)
        .eq('aktif', true)
        .eq('kategori', kategori.deger)
        .order('olusturulma_tarihi', ascending: false);

    return (veri as List)
        .map((json) => KiyafetModeli.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Favori kıyafetleri getir
  Future<List<KiyafetModeli>> favorileriGetir() async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Oturum bulunamadı');

    final veri = await _supabase
        .from('kiyafetler')
        .select()
        .eq('kullanici_id', kullaniciId)
        .eq('aktif', true)
        .eq('favori', true)
        .order('olusturulma_tarihi', ascending: false);

    return (veri as List)
        .map((json) => KiyafetModeli.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Tek kıyafet getir
  Future<KiyafetModeli?> kiyafetGetir(String id) async {
    final veri = await _supabase
        .from('kiyafetler')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (veri == null) return null;
    return KiyafetModeli.fromJson(veri);
  }

  /// Kıyafet ekle
  Future<KiyafetModeli> kiyafetEkle(KiyafetModeli kiyafet) async {
    final veri = await _supabase
        .from('kiyafetler')
        .insert(kiyafet.toJson())
        .select()
        .single();

    return KiyafetModeli.fromJson(veri);
  }

  /// Kıyafet güncelle
  Future<KiyafetModeli> kiyafetGuncelle(KiyafetModeli kiyafet) async {
    final veri = await _supabase
        .from('kiyafetler')
        .update(kiyafet.toJson())
        .eq('id', kiyafet.id)
        .select()
        .single();

    return KiyafetModeli.fromJson(veri);
  }

  /// Kıyafet sil (soft delete — aktif = false)
  Future<void> kiyafetSil(String id) async {
    await _supabase
        .from('kiyafetler')
        .update({'aktif': false})
        .eq('id', id);
  }

  /// Favori toggle
  Future<KiyafetModeli> favoriDegistir(String id, bool favori) async {
    final veri = await _supabase
        .from('kiyafetler')
        .update({'favori': favori})
        .eq('id', id)
        .select()
        .single();

    return KiyafetModeli.fromJson(veri);
  }

  /// Basit metin araması (kategori ve renk üzerinde)
  Future<List<KiyafetModeli>> kiyafetAra(String sorgu) async {
    final kullaniciId = _supabase.auth.currentUser?.id;
    if (kullaniciId == null) throw Exception('Oturum bulunamadı');

    // Sorguyu küçük harfe çevir ve boşlukları temizle
    final temizSorgu = sorgu.trim().toLowerCase();
    if (temizSorgu.isEmpty) return tumKiyafetleriGetir();

    // Tüm kıyafetleri çek ve client-side filtrele
    // (Supabase free plan'da full-text search sınırlı)
    final tumKiyafetler = await tumKiyafetleriGetir();

    return tumKiyafetler.where((kiyafet) {
      final kategoriUyumu = kiyafet.kategori.etiket.toLowerCase().contains(temizSorgu);
      final renkUyumu = (kiyafet.renkBilgisi?.isim ?? '').toLowerCase().contains(temizSorgu);
      final kalinlikUyumu = kiyafet.kalinlik.etiket.toLowerCase().contains(temizSorgu);
      final mevsimUyumu = kiyafet.mevsimler.any(
        (m) => m.etiket.toLowerCase().contains(temizSorgu),
      );
      return kategoriUyumu || renkUyumu || kalinlikUyumu || mevsimUyumu;
    }).toList();
  }

  /// Görsel yükle → public URL döndür
  Future<String> gorselYukle({
    required String kullaniciId,
    required String dosyaYolu,
    required String dosyaAdi,
  }) async {
    final storagePath = '$kullaniciId/$dosyaAdi';

    await _supabase.storage
        .from('kiyafetler')
        .upload(storagePath, File(dosyaYolu));

    final url = _supabase.storage
        .from('kiyafetler')
        .getPublicUrl(storagePath);

    return url;
  }

  /// Thumbnail yükle → public URL döndür
  Future<String> thumbnailYukle({
    required String kullaniciId,
    required String dosyaYolu,
    required String dosyaAdi,
  }) async {
    final storagePath = '$kullaniciId/kucuk_$dosyaAdi';

    await _supabase.storage
        .from('kiyafetler')
        .upload(storagePath, File(dosyaYolu));

    final url = _supabase.storage
        .from('kiyafetler')
        .getPublicUrl(storagePath);

    return url;
  }

  /// Görseli storage'dan sil
  Future<void> gorselSil(String gorselYolu) async {
    await _supabase.storage.from('kiyafetler').remove([gorselYolu]);
  }
}
