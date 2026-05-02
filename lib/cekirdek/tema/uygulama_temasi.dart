import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sabitler/renkler.dart';
import '../sabitler/boyutlar.dart';

/// Uygulama teması — Liquid Glass estetiği.
/// Kırık beyaz arka plan, yumuşak gölgeler, #C84153 vurgu rengi.
class UygulamaTemasi {
  UygulamaTemasi._();

  static ThemeData get acikTema {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // === Renk Şeması ===
      colorScheme: ColorScheme.light(
        primary: AppRenkler.anaVurgu,
        onPrimary: AppRenkler.metinBeyaz,
        secondary: AppRenkler.anaVurguAcik,
        onSecondary: AppRenkler.metinBeyaz,
        surface: AppRenkler.kartArkaPlan,
        onSurface: AppRenkler.metinBirincil,
        error: AppRenkler.hata,
        onError: AppRenkler.metinBeyaz,
      ),

      // === Arka Plan ===
      scaffoldBackgroundColor: AppRenkler.arkaPlan,

      // === AppBar ===
      appBarTheme: AppBarTheme(
        backgroundColor: AppRenkler.arkaPlan,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppRenkler.metinBirincil,
        ),
        iconTheme: const IconThemeData(
          color: AppRenkler.metinBirincil,
          size: 24,
        ),
      ),

      // === Bottom Navigation Bar ===
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppRenkler.navbarArkaPlan,
        selectedItemColor: AppRenkler.navbarSecili,
        unselectedItemColor: AppRenkler.navbarSecilmemis,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // === Kartlar ===
      cardTheme: CardThemeData(
        color: AppRenkler.kartArkaPlan,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // === Elevated Button (Ana Buton) ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppRenkler.anaVurgu,
          foregroundColor: AppRenkler.metinBeyaz,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppBoyutlar.butonYuksekligi),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // === Outlined Button ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppRenkler.anaVurgu,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppBoyutlar.butonYuksekligi),
          side: const BorderSide(color: AppRenkler.anaVurgu, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // === Text Button ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppRenkler.anaVurgu,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // === Input Decoration ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppRenkler.arkaPlan,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppBoyutlar.boslukBuyuk,
          vertical: AppBoyutlar.boslukOrta,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          borderSide: const BorderSide(color: AppRenkler.ayirici),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          borderSide: const BorderSide(color: AppRenkler.ayirici),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          borderSide: const BorderSide(color: AppRenkler.anaVurgu, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
          borderSide: const BorderSide(color: AppRenkler.hata),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          color: AppRenkler.metinUcuncul,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          color: AppRenkler.metinIkincil,
        ),
      ),

      // === Chip ===
      chipTheme: ChipThemeData(
        backgroundColor: AppRenkler.ikincilArkaPlan,
        selectedColor: AppRenkler.anaVurgu.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppRenkler.metinBirincil,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppRenkler.anaVurgu,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppBoyutlar.boslukOrta,
          vertical: AppBoyutlar.boslukKucuk,
        ),
      ),

      // === Divider ===
      dividerTheme: const DividerThemeData(
        color: AppRenkler.ayirici,
        thickness: 1,
        space: 0,
      ),

      // === Floating Action Button ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppRenkler.anaVurgu,
        foregroundColor: AppRenkler.metinBeyaz,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusYuvarlak),
        ),
      ),

      // === Dialog ===
      dialogTheme: DialogThemeData(
        backgroundColor: AppRenkler.kartArkaPlan,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusBuyuk),
        ),
      ),

      // === Bottom Sheet ===
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppRenkler.kartArkaPlan,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBoyutlar.radiusCokBuyuk),
          ),
        ),
      ),

      // === Snackbar ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppRenkler.metinBirincil,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppRenkler.metinBeyaz,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBoyutlar.radiusOrta),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
