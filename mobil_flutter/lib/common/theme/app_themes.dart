import 'package:flutter/material.dart';

// Temalarımızı temsil eden, anlamlı isimler.
enum AppTheme { firtinaYesili, kackarSisi, lazHoronu, zumrutYayla }

// Renk paletimiz. Her rengin bir anlamı, bir hissi var.
class AppColors {
  // Fırtına Yeşili Teması
  static const Color firtinaYesili = Color(0xFF0B3D2C); // Derin, orman yeşili
  static const Color cayFilizi = Color(0xFF4CAF50); // CANLI VE ŞIK YEŞİL
  static const Color ahsapSicakligi = Color(
    0xFFC48A69,
  ); // Vurgu rengi, sıcak ahşap
  static const Color bulutBeyazi = Color(0xFFF5F5F5); // Ferah arka plan
  static const Color dereTasi = Color(
    0xFF4A5D5F,
  ); // Kartların arka planı, metinler

  // Kaçkar Sisi Teması
  static const Color geceMavisi = Color(0xFF0D1B2A); // Koyu, gece arka planı
  static const Color sisliBeyaz = Color(
    0xFFE0E1DD,
  ); // Sisin içindeki ışık, ana yazı rengi
  static const Color ayIsigi = Color(0xFF415A77); // Kartların arka planı

  // Ortak Renkler
  static const Color koyuYazi = Color(0xFF1B262C);

  // Laz Horonu Teması
  static const Color horonMor = Color(0xFF8E24AA); // Mor
  static const Color zurnaTuruncu = Color(0xFFFF7043); // Turuncu vurgu
  static const Color horonArka = Color(0xFFF3E5F5); // Arka plan
  static const Color horonYazi = Color(0xFF4A148C); // Yazılar için koyu mor

  // Zümrüt Yayla Teması
  static const Color zumrutYesil = Color(0xFF2E7D32); // Ana renk
  static const Color toprakBeji = Color(0xFFF9F5EC); // Arka plan
  static const Color cayVurgusu = Color(0xFF81C784); // Vurgu (buton vs)
  static const Color sisGri = Color(0xFFCFD8DC); // Kart arka planı
  static const Color netYazi = Color(0xFF1B1B1B); // Metin rengi
}

// Uygulama temalarını profesyonelce tanımlıyoruz.
final appThemeData = {
  AppTheme.firtinaYesili: ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bulutBeyazi,
    primaryColor: AppColors.firtinaYesili,
    fontFamily: 'NunitoSans',

    colorScheme: const ColorScheme.light(
      primary: AppColors.firtinaYesili,
      // DÜZELTME: İKİNCİL VURGU RENGİMİZ ARTIK O ŞIK YEŞİL!
      secondary: AppColors.cayFilizi,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.koyuYazi,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Lora',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.koyuYazi,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Lora',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.koyuYazi,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.koyuYazi,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.dereTasi),
      // DÜZELTME: Kategori yazısı da artık o şık yeşili kullanacak.
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.cayFilizi,
      ),
    ),
  ),

  AppTheme.kackarSisi: ThemeData(
    // ... (Karanlık tema aynı kalıyor, gerekirse onu da düzenleriz)
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.geceMavisi,
    primaryColor: AppColors.sisliBeyaz,
    fontFamily: 'NunitoSans',

    colorScheme: const ColorScheme.dark(
      primary: AppColors.sisliBeyaz,
      secondary: AppColors
          .cayFilizi, // Karanlık temada da vurgu rengi yeşil olsun, güzel durur.
      surface: AppColors.ayIsigi,
      onPrimary: AppColors.geceMavisi,
      onSecondary: Colors.white,
      onSurface: AppColors.sisliBeyaz,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Lora',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.sisliBeyaz,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Lora',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.sisliBeyaz,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.sisliBeyaz,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.sisliBeyaz),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.cayFilizi,
      ),
    ),
  ),
  AppTheme.lazHoronu: ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.horonArka,
    primaryColor: const Color.fromARGB(255, 26, 19, 27),
    fontFamily: 'NunitoSans',
    colorScheme: const ColorScheme.light(
      primary: AppColors.horonMor,
      secondary: AppColors.zurnaTuruncu,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.horonYazi,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Lora',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.horonYazi,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Lora',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.horonYazi,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.horonYazi,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.zurnaTuruncu),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.horonMor,
      ),
    ),
  ),
  AppTheme.zumrutYayla: ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.toprakBeji,
    primaryColor: AppColors.zumrutYesil,
    fontFamily: 'NunitoSans',
    colorScheme: const ColorScheme.light(
      primary: AppColors.zumrutYesil,
      secondary: AppColors.cayVurgusu,
      surface: AppColors.sisGri,
      onPrimary: Colors.white,
      onSecondary: AppColors.netYazi,
      onSurface: AppColors.netYazi,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.zumrutYesil,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cayVurgusu,
        foregroundColor: AppColors.netYazi,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Lora',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.netYazi,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Lora',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.netYazi,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.netYazi,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.zumrutYesil),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.cayVurgusu,
      ),
    ),
  ),
};
