import 'package:flutter_bloc/flutter_bloc.dart';
import '../../alan/depolar/kimlik_deposu.dart';
import 'kimlik_olay.dart';
import 'kimlik_durum.dart';

/// Kimlik doğrulama BLoC'u.
/// Auth akışlarını yönetir: oturum kontrolü, giriş, kayıt, çıkış.
class KimlikBloc extends Bloc<KimlikOlay, KimlikDurum> {
  final KimlikDeposu _kimlikDeposu;

  KimlikBloc({required KimlikDeposu kimlikDeposu})
      : _kimlikDeposu = kimlikDeposu,
        super(const KimlikDurum.baslangic()) {
    on<OturumKontrolEt>(_oturumKontrolEt);
    on<GirisYapIstendi>(_girisYap);
    on<KayitOlIstendi>(_kayitOl);
    on<CikisYapIstendi>(_cikisYap);
    on<SifreSifirlaIstendi>(_sifreSifirla);
  }

  /// Oturum durumunu kontrol et
  Future<void> _oturumKontrolEt(
    OturumKontrolEt olay,
    Emitter<KimlikDurum> emit,
  ) async {
    emit(const KimlikDurum.yukleniyor());
    try {
      final kullanici = await _kimlikDeposu.mevcutKullaniciGetir();
      if (kullanici != null) {
        emit(KimlikDurum.girisYapildi(kullanici));
      } else {
        emit(const KimlikDurum.girisYok());
      }
    } catch (e) {
      emit(const KimlikDurum.girisYok());
    }
  }

  /// Giriş yap
  Future<void> _girisYap(
    GirisYapIstendi olay,
    Emitter<KimlikDurum> emit,
  ) async {
    emit(const KimlikDurum.yukleniyor());
    try {
      final kullanici = await _kimlikDeposu.girisYap(
        eposta: olay.eposta,
        sifre: olay.sifre,
      );
      emit(KimlikDurum.girisYapildi(kullanici));
    } catch (e) {
      emit(KimlikDurum.hata(_hataMetniCevir(e)));
    }
  }

  /// Kayıt ol
  Future<void> _kayitOl(
    KayitOlIstendi olay,
    Emitter<KimlikDurum> emit,
  ) async {
    emit(const KimlikDurum.yukleniyor());
    try {
      final kullanici = await _kimlikDeposu.kayitOl(
        isim: olay.isim,
        eposta: olay.eposta,
        sifre: olay.sifre,
      );
      emit(KimlikDurum.girisYapildi(kullanici));
    } catch (e) {
      emit(KimlikDurum.hata(_hataMetniCevir(e)));
    }
  }

  /// Çıkış yap
  Future<void> _cikisYap(
    CikisYapIstendi olay,
    Emitter<KimlikDurum> emit,
  ) async {
    emit(const KimlikDurum.yukleniyor());
    try {
      await _kimlikDeposu.cikisYap();
      emit(const KimlikDurum.girisYok());
    } catch (e) {
      emit(KimlikDurum.hata(_hataMetniCevir(e)));
    }
  }

  /// Şifre sıfırla
  Future<void> _sifreSifirla(
    SifreSifirlaIstendi olay,
    Emitter<KimlikDurum> emit,
  ) async {
    emit(const KimlikDurum.yukleniyor());
    try {
      await _kimlikDeposu.sifreSifirla(eposta: olay.eposta);
      // Başarılı — kullanıcıya bilgi gösterilecek (ekranda handle edilir)
      emit(const KimlikDurum.girisYok());
    } catch (e) {
      emit(KimlikDurum.hata(_hataMetniCevir(e)));
    }
  }

  /// Supabase hata mesajlarını Türkçeye çevir
  String _hataMetniCevir(Object hata) {
    final mesaj = hata.toString().toLowerCase();
    if (mesaj.contains('invalid login credentials') ||
        mesaj.contains('invalid_credentials')) {
      return 'E-posta veya şifre hatalı';
    }
    if (mesaj.contains('email already registered') ||
        mesaj.contains('user already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı';
    }
    if (mesaj.contains('password should be at least')) {
      return 'Şifre en az 6 karakter olmalı';
    }
    if (mesaj.contains('invalid email')) {
      return 'Geçersiz e-posta adresi';
    }
    if (mesaj.contains('network') || mesaj.contains('socket')) {
      return 'İnternet bağlantınızı kontrol edin';
    }
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
