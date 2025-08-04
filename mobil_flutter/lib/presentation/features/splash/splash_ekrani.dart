// lib/presentation/features/splash/splash_ekrani.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobil_flutter/presentation/features/home/widgets/auth_yonlendirici.dart';

class SplashEkrani extends StatefulWidget {
  const SplashEkrani({super.key});

  @override
  State<SplashEkrani> createState() => _SplashEkraniState();
}

class _SplashEkraniState extends State<SplashEkrani> {
  @override
  void initState() {
    super.initState();
    // 3 saniye bekleyip AuthYonlendirici'ye geçiş yap
    Timer(const Duration(seconds: 3), () {
      if (mounted) { // Ekranın hala görünür olduğundan emin ol
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthYonlendirici()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cihazın boyutlarını alalım ki logo her ekranda orantılı dursun
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Arka plan rengini temanla uyumlu yapabilirsin
      backgroundColor: const Color(0xFFF5F5F5), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png', // Logo dosyanın yolu
              width: screenWidth * 0.5, // Ekran genişliğinin yarısı kadar olsun
            ),
            const SizedBox(height: 24),
            // İsim
            const Text(
              'Rize Kültür',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF004D40), // Koyu bir çay yeşili
              ),
            ),
             const SizedBox(height: 8),
             Text(
              'Rize\'yi Keşfet',
               style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 40),
            // Yüklenme animasyonu
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004D40)),
            ),
          ],
        ),
      ),
    );
  }
}