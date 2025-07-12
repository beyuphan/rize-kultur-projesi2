import 'package:flutter/material.dart';

// Temalarımızı temsil eden, anlamlı isimler.
enum AppTheme {
  firtinaYesili,
  kackarSisi,
}

// Renk paletimiz. Her rengin bir anlamı, bir hissi var.
class AppColors {
  // Fırtına Yeşili Teması
  static const Color firtinaYesili = Color(0xFF0B3D2C);    // Derin, orman yeşili
  static const Color cayFilizi = Color(0xFF4CAF50);      // CANLI VE ŞIK YEŞİL
  static const Color ahsapSicakligi = Color(0xFFC48A69);  // Vurgu rengi, sıcak ahşap
  static const Color bulutBeyazi = Color(0xFFF5F5F5);      // Ferah arka plan
  static const Color dereTasi = Color(0xFF4A5D5F);      // Kartların arka planı, metinler

  // Kaçkar Sisi Teması
  static const Color geceMavisi = Color(0xFF0D1B2A);      // Koyu, gece arka planı
  static const Color sisliBeyaz = Color(0xFFE0E1DD);      // Sisin içindeki ışık, ana yazı rengi
  static const Color ayIsigi = Color(0xFF415A77);         // Kartların arka planı
  
  // Ortak Renkler
  static const Color koyuYazi = Color(0xFF1B262C);
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
      background: AppColors.bulutBeyazi,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.koyuYazi,
      onBackground: AppColors.koyuYazi,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontFamily: 'Lora', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.koyuYazi),
      titleLarge: TextStyle(fontFamily: 'Lora', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.koyuYazi),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.koyuYazi),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.dereTasi),
      // DÜZELTME: Kategori yazısı da artık o şık yeşili kullanacak.
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cayFilizi),
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
      secondary: AppColors.cayFilizi, // Karanlık temada da vurgu rengi yeşil olsun, güzel durur.
      surface: AppColors.ayIsigi,
      background: AppColors.geceMavisi,
      onPrimary: AppColors.geceMavisi,
      onSecondary: Colors.white,
      onSurface: AppColors.sisliBeyaz,
      onBackground: AppColors.sisliBeyaz,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontFamily: 'Lora', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.sisliBeyaz),
      titleLarge: TextStyle(fontFamily: 'Lora', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.sisliBeyaz),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.sisliBeyaz),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.sisliBeyaz),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cayFilizi),
    ),
  ),
};
