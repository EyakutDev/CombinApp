import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ana_kabuk.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/ekranlar/giris_ekrani.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/ekranlar/kayit_ekrani.dart';
import 'package:combin_app/ozellikler/onboarding/sunum/ekranlar/onboarding_ekrani.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_bloc.dart';
import 'package:combin_app/ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_durum.dart';
import 'package:combin_app/ozellikler/kombin/sunum/ekranlar/kayitli_kombinler_ekrani.dart';
import 'package:combin_app/ozellikler/kombin/sunum/ekranlar/manuel_kombin_olustur_ekrani.dart';
import 'package:combin_app/ozellikler/gardrop/sunum/ekranlar/kiyafet_ekle_ekrani.dart';

/// Uygulama yönlendiricisi — GoRouter ile deklaratif navigasyon.
/// Auth guard ve onboarding guard içerir.
class UygulamaYonlendiricisi {
  final KimlikBloc kimlikBloc;

  UygulamaYonlendiricisi({required this.kimlikBloc});

  late final GoRouter yonlendirici = GoRouter(
    initialLocation: '/kayit',
    debugLogDiagnostics: true,

    // Auth guard — oturum durumuna göre yönlendirme
    redirect: (context, durum) {
      final kimlikDurumu = kimlikBloc.state;
      final girisYapildi = kimlikDurumu.tip == KimlikDurumTipi.girisYapildi;
      final girisYolunda = durum.matchedLocation == '/giris' ||
          durum.matchedLocation == '/kayit' ||
          durum.matchedLocation == '/sifre-sifirla';

      // Oturum yoksa giriş sayfasına yönlendir
      // GEÇİCİ OLARAK KAPATILDI (Misafir Girişi İçin)
      // if (!girisYapildi && !girisYolunda) {
      //   return '/giris';
      // }

      // Oturum varsa ve giriş sayfasındaysa ana sayfaya yönlendir
      if (girisYapildi && girisYolunda) {
        // Onboarding tamamlanmamışsa onboarding'e yönlendir
        final kullanici = kimlikDurumu.kullanici;
        if (kullanici != null && !kullanici.onboardingTamamlandi) {
          return '/onboarding';
        }
        return '/';
      }

      return null; // yönlendirme yok
    },

    // Oturum durumu değiştiğinde yeniden değerlendir
    refreshListenable: GoRouterRefreshStream(kimlikBloc.stream),

    routes: [
      // === Ana Kabuk (5 tab) ===
      GoRoute(
        path: '/',
        builder: (context, durum) => const AnaKabuk(),
      ),

      // === Kimlik Doğrulama ===
      GoRoute(
        path: '/giris',
        builder: (context, durum) => const GirisEkrani(),
      ),
      GoRoute(
        path: '/kayit',
        builder: (context, durum) => const KayitEkrani(),
      ),
      GoRoute(
        path: '/sifre-sifirla',
        builder: (context, durum) => const Scaffold(
          body: Center(child: Text('Şifre Sıfırlama — Yapım aşamasında')),
        ),
      ),

      // === Onboarding ===
      GoRoute(
        path: '/onboarding',
        builder: (context, durum) => const OnboardingEkrani(),
      ),

      // === Kombin Alt Ekranları ===
      GoRoute(
        path: '/kayitli-kombinler',
        builder: (context, durum) => const KayitliKombinlerEkrani(),
      ),
      GoRoute(
        path: '/manuel-kombin',
        builder: (context, durum) {
          final gun = durum.extra as DateTime?;
          return ManuelKombinOlusturEkrani(atanacakGun: gun);
        },
      ),

      // === Gardırop Alt Ekranları ===
      GoRoute(
        path: '/kiyafet-ekle',
        builder: (context, durum) => const KiyafetEkleEkrani(),
      ),
    ],
  );
}

/// GoRouter'ın BLoC stream'ini dinlemesi için yardımcı sınıf.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
