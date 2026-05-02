import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'renkler.dart';

/// Uygulama genelinde kullanılan metin stilleri.
/// Google Fonts "Inter" ailesi kullanılır — temiz, modern, okunabilir.
class AppMetinStilleri {
  AppMetinStilleri._();

  // === Başlıklar ===
  static TextStyle baslikBuyuk = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppRenkler.metinBirincil,
    letterSpacing: -0.5,
  );

  static TextStyle baslikOrta = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppRenkler.metinBirincil,
    letterSpacing: -0.3,
  );

  static TextStyle baslikKucuk = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppRenkler.metinBirincil,
  );

  // === Gövde Metinleri ===
  static TextStyle govdeBuyuk = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppRenkler.metinBirincil,
  );

  static TextStyle govdeNormal = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppRenkler.metinBirincil,
  );

  static TextStyle govdeKucuk = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppRenkler.metinIkincil,
  );

  static TextStyle govdeKalin = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppRenkler.metinBirincil,
  );

  // === Etiketler ===
  static TextStyle etiket = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppRenkler.metinUcuncul,
    letterSpacing: 0.5,
  );

  // === Buton Metinleri ===
  static TextStyle butonBuyuk = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppRenkler.metinBeyaz,
  );

  static TextStyle butonKucuk = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppRenkler.anaVurgu,
  );

  // === Navbar ===
  static TextStyle navbarEtiket = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
