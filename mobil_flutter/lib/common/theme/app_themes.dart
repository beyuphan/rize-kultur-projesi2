import 'package:flutter/material.dart';

// Tema modlarını temsil eden bir enum. 
// Bu, kodumuzu daha okunaklı ve yönetilebilir yapar.
enum AppTheme {
  yaylaYesili,
  sisBulutu,
}

// Uygulamamızda kullanacağımız tüm renkleri tek bir yerden yönetiyoruz.
// Yarın bir rengi değiştirmek istediğimizde, sadece burayı değiştireceğiz.
class AppColors {
  static const Color yaylaYesili = Color(0xFF2A9D8F);
  static const Color sisliArkaPlan = Color(0xFF264653);
  static const Color vurguSarisi = Color(0xFFE9C46A);
  static const Color beyazYazi = Colors.white;
  static const Color acikArkaPlan = Color(0xFFF4F1DE);
  static const Color koyuYazi = Color(0xFF222222);
}

// Uygulama temalarımızı burada bir harita (Map) içinde tutuyoruz.
// Bu, temalar arasında geçiş yapmayı çok kolaylaştırır.
final appThemeData = {
  AppTheme.yaylaYesili: ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.yaylaYesili,
    scaffoldBackgroundColor: AppColors.acikArkaPlan,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.yaylaYesili,
      foregroundColor: AppColors.beyazYazi, // AppBar üzerindeki ikon ve yazı renkleri
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.yaylaYesili,
      secondary: AppColors.vurguSarisi,
      onPrimary: AppColors.beyazYazi,
      background: AppColors.acikArkaPlan,
      onBackground: AppColors.koyuYazi,
    ),
    // ... diğer widget temaları buraya eklenebilir
  ),
  AppTheme.sisBulutu: ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.beyazYazi,
    scaffoldBackgroundColor: AppColors.sisliArkaPlan,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black26,
      foregroundColor: AppColors.beyazYazi,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.beyazYazi,
      secondary: AppColors.vurguSarisi,
      background: AppColors.sisliArkaPlan,
      onBackground: AppColors.beyazYazi,
    ),
     // ... diğer widget temaları buraya eklenebilir
  ),
};
