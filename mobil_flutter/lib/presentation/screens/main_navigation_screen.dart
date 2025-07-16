import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart'; // YENİ AUTH PROVIDER
import 'package:mobil_flutter/presentation/screens/ayarlar_ekrani_misafir.dart';
import 'package:mobil_flutter/presentation/screens/harita_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/kesfet_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/profil_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/rotalar_ekrani.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

final seciliEkranIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seciliIndex = ref.watch(seciliEkranIndexProvider);
    // YENİ: Kendi auth provider'ımızı dinliyoruz.
    final authStatus = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    // Giriş yapılıp yapılmadığını kontrol ediyoruz.
    final bool isLoggedIn = authStatus == AuthStatus.girisYapildi;

    // Giriş durumuna göre gösterilecek ekran listesini belirliyoruz
    final ekranlar = [
      const KesfetEkrani(),
      const HaritaEkrani(),
      const RotalarEkrani(),
      isLoggedIn ? const ProfilEkrani() : const AyarlarEkraniMisafir(),
    ];

    return Scaffold(
      body: ekranlar[seciliIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: seciliIndex,
        onTap: (index) =>
            ref.read(seciliEkranIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            label: l10n.bottomNavExplore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            label: l10n.bottomNavMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_outlined),
            label: l10n.bottomNavRoutes,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              isLoggedIn ? Icons.person_outline : Icons.settings_outlined,
            ),
            label: isLoggedIn ? l10n.bottomNavProfile : l10n.bottomNavSettings,
          ),
        ],
      ),
    );
  }
}
