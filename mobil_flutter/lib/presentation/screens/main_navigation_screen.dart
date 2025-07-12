import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/screens/ayarlar_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/harita_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/kesfet_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/rotalar_ekrani.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart'; // DİL DOSYASINI IMPORT EDİYORUZ

// Hangi sekmenin seçili olduğunu tutacak olan basit bir provider.
final seciliEkranIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seciliIndex = ref.watch(seciliEkranIndexProvider);
    final l10n = AppLocalizations.of(context)!; // Çeviri nesnesini alıyoruz

    final ekranlar = [
      const KesfetEkrani(),
      const HaritaEkrani(),
      const RotalarEkrani(),
      const AyarlarEkrani(),
    ];

    return Scaffold(
      body: ekranlar[seciliIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: seciliIndex,
        onTap: (index) {
          ref.read(seciliEkranIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        // ARTIK LABELLAR SABİT DEĞİL, DİNAMİK VE ÇEVİRİLEBİLİR!
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: l10n.explore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.map,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_outlined),
            activeIcon: const Icon(Icons.directions),
            label: l10n.routes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
