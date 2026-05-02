import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cekirdek/sabitler/api_sabitleri.dart';
import 'cekirdek/tema/uygulama_temasi.dart';
import 'navigasyon/uygulama_yonlendiricisi.dart';
import 'ozellikler/kimlik_dogrulama/alan/depolar/kimlik_deposu.dart';
import 'ozellikler/kimlik_dogrulama/veri/kaynaklar/kimlik_veri_kaynagi.dart';
import 'ozellikler/kimlik_dogrulama/veri/depolar/kimlik_deposu_impl.dart';
import 'ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_bloc.dart';
import 'ozellikler/kimlik_dogrulama/sunum/bloc/kimlik_olay.dart';
import 'ozellikler/gardrop/alan/depolar/gardrop_deposu.dart';
import 'ozellikler/gardrop/veri/kaynaklar/gardrop_veri_kaynagi.dart';
import 'ozellikler/gardrop/veri/depolar/gardrop_deposu_impl.dart';
import 'ozellikler/gardrop/sunum/bloc/gardrop_bloc.dart';
import 'ozellikler/hava_durumu/veri/hava_durumu_servisi.dart';
import 'ozellikler/hava_durumu/sunum/bloc/hava_durumu_bloc.dart';
import 'ozellikler/kombin/veri/kaynaklar/kombin_veri_kaynagi.dart';
import 'ozellikler/kombin/alan/depolar/kombin_deposu.dart';
import 'ozellikler/kombin/veri/depolar/kombin_deposu_impl.dart';
import 'ozellikler/kombin/sunum/bloc/kombin_bloc.dart';
import 'ozellikler/plan/veri/kaynaklar/plan_veri_kaynagi.dart';
import 'ozellikler/plan/alan/depolar/plan_deposu.dart';
import 'ozellikler/plan/veri/depolar/plan_deposu_impl.dart';
import 'ozellikler/plan/sunum/bloc/plan_bloc.dart';

/// Uygulama giriş noktası.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase başlat
  await Supabase.initialize(
    url: ApiSabitleri.supabaseUrl,
    anonKey: ApiSabitleri.supabaseAnonKey,
  );

  runApp(const CombinApp());
}

/// Uygulama kök widget'ı.
class CombinApp extends StatefulWidget {
  const CombinApp({super.key});

  @override
  State<CombinApp> createState() => _CombinAppState();
}

class _CombinAppState extends State<CombinApp> {
  // Bağımlılıklar
  late final KimlikVeriKaynagi _kimlikVeriKaynagi;
  late final KimlikDeposu _kimlikDeposu;
  late final KimlikBloc _kimlikBloc;
  late final GardropVeriKaynagi _gardropVeriKaynagi;
  late final GardropDeposu _gardropDeposu;
  late final GardropBloc _gardropBloc;
  late final HavaDurumuServisi _havaDurumuServisi;
  late final HavaDurumuBloc _havaDurumuBloc;
  late final KombinVeriKaynagi _kombinVeriKaynagi;
  late final KombinDeposu _kombinDeposu;
  late final KombinBloc _kombinBloc;
  late final PlanVeriKaynagi _planVeriKaynagi;
  late final PlanDeposu _planDeposu;
  late final PlanBloc _planBloc;
  late final UygulamaYonlendiricisi _yonlendirici;

  @override
  void initState() {
    super.initState();

    // DI — basit manual injection (MVP için yeterli)
    final supabaseClient = Supabase.instance.client;

    // Auth
    _kimlikVeriKaynagi = KimlikVeriKaynagi(supabaseClient: supabaseClient);
    _kimlikDeposu = KimlikDeposuImpl(veriKaynagi: _kimlikVeriKaynagi);
    _kimlikBloc = KimlikBloc(kimlikDeposu: _kimlikDeposu);

    // Gardırop
    _gardropVeriKaynagi = GardropVeriKaynagi(supabaseClient: supabaseClient);
    _gardropDeposu = GardropDeposuImpl(veriKaynagi: _gardropVeriKaynagi);
    _gardropBloc = GardropBloc(gardropDeposu: _gardropDeposu);

    // Hava durumu
    _havaDurumuServisi = HavaDurumuServisi();
    _havaDurumuBloc = HavaDurumuBloc(servis: _havaDurumuServisi);

    // Kombin
    _kombinVeriKaynagi = KombinVeriKaynagi(supabase: supabaseClient);
    _kombinDeposu = KombinDeposuImpl(veriKaynagi: _kombinVeriKaynagi);
    _kombinBloc = KombinBloc(
      gardropDeposu: _gardropDeposu,
      kombinDeposu: _kombinDeposu,
    );

    // Plan
    _planVeriKaynagi = PlanVeriKaynagi(supabase: supabaseClient);
    _planDeposu = PlanDeposuImpl(veriKaynagi: _planVeriKaynagi);
    _planBloc = PlanBloc(planDeposu: _planDeposu);

    _yonlendirici = UygulamaYonlendiricisi(kimlikBloc: _kimlikBloc);

    // Oturum durumunu kontrol et
    _kimlikBloc.add(const OturumKontrolEt());
  }

  @override
  void dispose() {
    _kimlikBloc.close();
    _gardropBloc.close();
    _havaDurumuBloc.close();
    _kombinBloc.close();
    _planBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<KimlikBloc>.value(value: _kimlikBloc),
        BlocProvider<GardropBloc>.value(value: _gardropBloc),
        BlocProvider<HavaDurumuBloc>.value(value: _havaDurumuBloc),
        BlocProvider<KombinBloc>.value(value: _kombinBloc),
        BlocProvider<PlanBloc>.value(value: _planBloc),
      ],
      child: MaterialApp.router(
        title: 'CombinApp',
        debugShowCheckedModeBanner: false,
        theme: UygulamaTemasi.acikTema,
        routerConfig: _yonlendirici.yonlendirici,
      ),
    );
  }
}
