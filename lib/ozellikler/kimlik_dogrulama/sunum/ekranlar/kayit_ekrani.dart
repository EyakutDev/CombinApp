import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';
import 'package:combin_app/cekirdek/sabitler/boyutlar.dart';
import 'package:combin_app/cekirdek/sabitler/metin_stilleri.dart';
import 'package:combin_app/cekirdek/widgets/birincil_buton.dart';
import '../bloc/kimlik_bloc.dart';
import '../bloc/kimlik_olay.dart';
import '../bloc/kimlik_durum.dart';
import 'package:combin_app/cekirdek/widgets/cam_snack_bar.dart';

/// Kayıt ekranı — isim, e-posta, şifre ile hesap oluşturma.
class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _formAnahtari = GlobalKey<FormState>();
  final _isimController = TextEditingController();
  final _epostaController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();
  bool _sifreGizli = true;

  @override
  void dispose() {
    _isimController.dispose();
    _epostaController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }

  void _kayitOl() {
    if (_formAnahtari.currentState?.validate() ?? false) {
      context.read<KimlikBloc>().add(
            KayitOlIstendi(
              isim: _isimController.text.trim(),
              eposta: _epostaController.text.trim(),
              sifre: _sifreController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<KimlikBloc, KimlikDurum>(
        listener: (context, durum) {
          if (durum.tip == KimlikDurumTipi.hata && durum.hataMesaji != null) {
            CamSnackBar.hata(context, durum.hataMesaji!);
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formAnahtari,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Görseli & Geri Butonu
                Stack(
                  children: [
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1558769132-cb1fac0840c2?q=80&w=800&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppBoyutlar.radiusCokBuyuk),
                          bottomRight: Radius.circular(AppBoyutlar.radiusCokBuyuk),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppBoyutlar.boslukKucuk,
                      left: AppBoyutlar.boslukKucuk,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppRenkler.metinBirincil),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppBoyutlar.boslukKucuk,
                      right: AppBoyutlar.boslukKucuk,
                      child: TextButton(
                        onPressed: () => context.go('/'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.7),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                          ),
                        ),
                        child: Text(
                          'Atla',
                          style: AppMetinStilleri.govdeKalin.copyWith(color: AppRenkler.anaVurgu),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppBoyutlar.boslukBuyuk),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppBoyutlar.boslukBuyuk),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Başlık — Cam Hap
                      Center(
                        child: _camHapMetin('Tarzına katıl ✨', AppMetinStilleri.baslikBuyuk),
                      ),
                      const SizedBox(height: AppBoyutlar.boslukKucuk),
                      Center(
                        child: _camHapMetin(
                          'Dolabını dijitalleştirmek için hemen kayıt ol.',
                          AppMetinStilleri.govdeKucuk,
                        ),
                      ),
                      const SizedBox(height: AppBoyutlar.boslukDevasa),

                  // İsim — Cam Hap Alanı
                  Container(
                    decoration: BoxDecoration(
                      color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextFormField(
                      controller: _isimController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'İsim',
                        hintText: 'Adın',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppRenkler.metinIkincil),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      validator: (deger) {
                        if (deger == null || deger.trim().isEmpty) {
                          return 'İsim gerekli';
                        }
                        if (deger.trim().length < 2) {
                          return 'İsim en az 2 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukNormal),

                  // E-posta — Cam Hap Alanı
                  Container(
                    decoration: BoxDecoration(
                      color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextFormField(
                      controller: _epostaController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'E-posta adresin',
                        hintText: 'ornek@mail.com',
                        prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppRenkler.metinIkincil),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      validator: (deger) {
                        if (deger == null || deger.trim().isEmpty) {
                          return 'E-posta gerekli';
                        }
                        if (!deger.contains('@') || !deger.contains('.')) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukNormal),

                  // Şifre — Cam Hap Alanı
                  Container(
                    decoration: BoxDecoration(
                      color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextFormField(
                      controller: _sifreController,
                      obscureText: _sifreGizli,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Şifren',
                        hintText: 'En az 6 karakter',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppRenkler.metinIkincil),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _sifreGizli
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppRenkler.metinUcuncul,
                          ),
                          onPressed: () {
                            setState(() => _sifreGizli = !_sifreGizli);
                          },
                        ),
                      ),
                      validator: (deger) {
                        if (deger == null || deger.isEmpty) {
                          return 'Şifre gerekli';
                        }
                        if (deger.length < 6) {
                          return 'Şifre en az 6 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukNormal),

                  // Şifre tekrar — Cam Hap Alanı
                  Container(
                    decoration: BoxDecoration(
                      color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [BoxShadow(color: AppRenkler.camGolge, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextFormField(
                      controller: _sifreTekrarController,
                      obscureText: _sifreGizli,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _kayitOl(),
                      decoration: const InputDecoration(
                        labelText: 'Şifreni Doğrula',
                        hintText: 'Şifreni tekrar gir',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppRenkler.metinIkincil),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      validator: (deger) {
                        if (deger != _sifreController.text) {
                          return 'Şifreler eşleşmiyor';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukCokBuyuk),

                  // Kayıt butonu
                  BlocBuilder<KimlikBloc, KimlikDurum>(
                    builder: (context, durum) {
                      return BirincilButon(
                        metin: 'Kayıt Ol',
                        yukleniyor: durum.tip == KimlikDurumTipi.yukleniyor,
                        tiklandiginda: _kayitOl,
                      );
                    },
                  ),

                  const SizedBox(height: AppBoyutlar.boslukNormal),

                  // Giriş Yap Butonu
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppRenkler.anaVurgu, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
                      ),
                    ),
                    child: Text(
                      'Zaten hesabın var mı? Giriş Yap',
                      style: AppMetinStilleri.govdeKalin.copyWith(
                        color: AppRenkler.anaVurgu,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppBoyutlar.boslukOrta),

                  // Veya şu ile devam et — Cam Hap
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: _camHapMetin('Veya şu ile devam et', AppMetinStilleri.etiket),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: AppBoyutlar.boslukOrta),

                  // Sosyal Giriş Butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Platform.isIOS)
                        Padding(
                          padding: const EdgeInsets.only(right: AppBoyutlar.boslukNormal),
                          child: _sosyalButon(
                            ikon: Icons.apple_rounded, // Temsili Apple ikonu
                            renk: Colors.black,
                            onTap: () {}, // Apple login logic
                          ),
                        ),
                      _sosyalButon(
                        ikon: Icons.g_mobiledata_rounded, // Temsili Google ikonu
                        renk: Colors.blue,
                        onTap: () {}, // Google login logic
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppBoyutlar.boslukCokBuyuk),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _sosyalButon({
    required IconData ikon,
    required Color renk,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppRenkler.camGolge,
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(ikon, color: renk, size: 36),
      ),
    );
  }

  Widget _camHapMetin(String metin, TextStyle stil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppRenkler.kartArkaPlan.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppRenkler.camGolge,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(metin, style: stil),
    );
  }
}
