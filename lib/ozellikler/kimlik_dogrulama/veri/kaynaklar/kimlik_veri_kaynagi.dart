import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../alan/modeller/kullanici_modeli.dart';

/// Supabase Auth ve kullanıcı tablosu ile kimlik doğrulama işlemleri.
class KimlikVeriKaynagi {
  final SupabaseClient _supabaseClient;

  KimlikVeriKaynagi({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Oturum değişikliklerini dinle
  Stream<KullaniciModeli?> get oturumDurumu {
    return _supabaseClient.auth.onAuthStateChange.asyncMap((veri) async {
      final oturum = veri.session;
      if (oturum == null) return null;
      return await _kullaniciBilgileriniGetir(oturum.user.id);
    });
  }

  /// Mevcut kullanıcıyı getir
  Future<KullaniciModeli?> mevcutKullaniciGetir() async {
    final kullanici = _supabaseClient.auth.currentUser;
    if (kullanici == null) return null;
    return await _kullaniciBilgileriniGetir(kullanici.id);
  }

  /// E-posta + şifre ile kayıt
  Future<KullaniciModeli> kayitOl({
    required String isim,
    required String eposta,
    required String sifre,
  }) async {
    // Supabase Auth ile kayıt
    final yanit = await _supabaseClient.auth.signUp(
      email: eposta,
      password: sifre,
    );

    final kullanici = yanit.user;
    if (kullanici == null) {
      throw Exception('Kayıt başarısız');
    }

    // Kullanıcı profil tablosuna ekle
    await _supabaseClient.from('kullanicilar').insert({
      'id': kullanici.id,
      'isim': isim,
      'eposta': eposta,
    });

    return KullaniciModeli(
      id: kullanici.id,
      isim: isim,
      eposta: eposta,
      olusturulmaTarihi: DateTime.now(),
    );
  }

  /// E-posta + şifre ile giriş
  Future<KullaniciModeli> girisYap({
    required String eposta,
    required String sifre,
  }) async {
    final yanit = await _supabaseClient.auth.signInWithPassword(
      email: eposta,
      password: sifre,
    );

    final kullanici = yanit.user;
    if (kullanici == null) {
      throw Exception('Giriş başarısız');
    }

    return await _kullaniciBilgileriniGetir(kullanici.id) ??
        KullaniciModeli(
          id: kullanici.id,
          isim: '',
          eposta: eposta,
          olusturulmaTarihi: DateTime.now(),
        );
  }

  /// Çıkış
  Future<void> cikisYap() async {
    await _supabaseClient.auth.signOut();
  }

  /// Şifre sıfırlama
  Future<void> sifreSifirla({required String eposta}) async {
    await _supabaseClient.auth.resetPasswordForEmail(eposta);
  }

  /// Profil güncelle
  Future<KullaniciModeli> profilGuncelle(KullaniciModeli kullanici) async {
    await _supabaseClient.from('kullanicilar').update(kullanici.toJson()).eq('id', kullanici.id);
    return kullanici;
  }

  /// Kullanıcı bilgilerini DB'den getir
  Future<KullaniciModeli?> _kullaniciBilgileriniGetir(String kullaniciId) async {
    try {
      final veri = await _supabaseClient
          .from('kullanicilar')
          .select()
          .eq('id', kullaniciId)
          .maybeSingle();

      if (veri == null) return null;
      return KullaniciModeli.fromJson(veri);
    } catch (e) {
      return null;
    }
  }
}
