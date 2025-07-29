// lib/presentation/features/home/screens/main_navigation_screen.dart
import 'package:mobil_flutter/presentation/features/auth/screens/misafir_ekrani.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';

// Yeni, özellik bazlı klasör yolları
import 'package:mobil_flutter/presentation/features/settings/screens/ayarlar_ekrani_misafir.dart';
import 'package:mobil_flutter/presentation/features/map/screens/harita_ekrani.dart';
import 'package:mobil_flutter/presentation/features/discover/screens/kesfet_ekrani.dart';
import 'package:mobil_flutter/presentation/features/profil/screens/profil_sayfasi.dart';

import 'package:mobil_flutter/presentation/features/rotalar/screens/rotalar_ekrani.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

final seciliEkranIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Auth durumunu izle
    final authState = ref.watch(authProvider);
    final bool girisYapildi = authState == AuthStatus.girisYapildi;

    // Duruma göre sayfa listesini ve bottom bar item'larını belirle
    final List<Widget> pages;
    final List<BottomNavigationBarItem> items;

    if (girisYapildi) {
      // GİRİŞ YAPMIŞ KULLANICI İÇİN
      pages = const [
        KesfetEkrani(),
        HaritaEkrani(),
        Scaffold(
          body: Center(child: Text("Rotalar (Yapım Aşamasında)")),
        ), // Rotalar
        ProfilSayfasi(), // Kendi profilini gösterir
      ];
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Keşfet',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Harita',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.route_outlined),
          label: 'Rotalar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profilim',
        ),
      ];
    } else {
      // MİSAFİR KULLANICI İÇİN
      pages = const [
        KesfetEkrani(),
        HaritaEkrani(),
        Scaffold(body: Center(child: Text("Rotalar (Yapım Aşamasında)"))),
        MisafirEkrani(), // Profilim yerine Giriş Yap ekranını gösterir
      ];
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Keşfet',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Harita',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.route_outlined),
          label: 'Rotalar',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Diğer'),
      ];
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Seçili olmayan item'ların da label'ını göstermek için
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
