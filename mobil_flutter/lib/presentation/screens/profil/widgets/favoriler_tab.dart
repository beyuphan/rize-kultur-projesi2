// lib/presentation/screens/profil/widgets/favoriler_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';

// DÜZELTME: Bu widget da artık "aptal". Veriyi dışarıdan alıyor.
class FavorilerTab extends ConsumerWidget {
  final List<MekanModel> favoriMekanlar;
  const FavorilerTab({super.key, required this.favoriMekanlar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    if (favoriMekanlar.isEmpty) {
      return Center(child: Text(l10n.noFavoritesYet));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: favoriMekanlar.length,
      itemBuilder: (context, index) {
        final mekan = favoriMekanlar[index];
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
    );
  }
}