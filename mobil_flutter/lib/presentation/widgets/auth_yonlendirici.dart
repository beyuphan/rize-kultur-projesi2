import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/screens/giris_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/main_navigation_screen.dart';

class AuthYonlendirici extends ConsumerWidget {
  const AuthYonlendirici({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth provider'daki durumu izle
    final authStatus = ref.watch(authProvider);

    // Duruma göre ilgili ekranı göster
    switch (authStatus) {
      case AuthStatus.girisYapildi:
        return const MainNavigationScreen();
      case AuthStatus.girisYapilmadi:
        return const GirisEkrani();
      case AuthStatus.bilinmiyor:
      default:
        // Auth durumu kontrol edilirken yüklenme animasyonu göster
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
