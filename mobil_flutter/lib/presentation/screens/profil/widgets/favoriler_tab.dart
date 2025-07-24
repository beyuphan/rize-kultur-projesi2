// lib/presentation/screens/profil/widgets/favoriler_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';

class FavorilerTab extends ConsumerWidget {
  const FavorilerTab({super.key}); // const constructor ekledik

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorilerAsync = ref.watch(favoriMekanlarProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return favorilerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Favoriler yüklenemedi: $err')),
      data: (mekanlar) => mekanlar.isEmpty
          ? Center(child: Text(l10n.noFavoritesYet))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: mekanlar.length,
              itemBuilder: (context, index) {
                final mekan = mekanlar[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MekanDetayEkrani(mekanId: mekan.id)),
                    );
                  },
                  child: MekanKarti(
                    isim: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                    kategori: mekan.kategori,
                    puan: mekan.ortalamaPuan,
                    imageUrl: mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : null,
                  ),
                );
              },
            ),
    );
  }
}
