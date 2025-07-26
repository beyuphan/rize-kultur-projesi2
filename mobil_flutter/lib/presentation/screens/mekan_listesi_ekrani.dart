// lib/presentation/screens/mekan_listesi_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';
import 'mekan_detay_ekrani.dart';

class MekanListesiEkrani extends ConsumerWidget {
  final String sayfaBasligi;
  final MekanFiltresi ilkFiltre;

  const MekanListesiEkrani({
    super.key,
    required this.sayfaBasligi,
    required this.ilkFiltre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gelen ilk filtre ile mekan listesi provider'ını izliyoruz.
    final mekanlarAsync = ref.watch(mekanListesiProvider(ilkFiltre));
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(sayfaBasligi),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: mekanlarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Mekanlar yüklenemedi: $err')),
        data: (response) {
          final mekanlar = response.mekanlar;
          if (mekanlar.isEmpty) {
            return Center(child: Text(l10n.noVenuesFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: mekanlar.length,
            itemBuilder: (context, index) {
              final mekan = mekanlar[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  height: 280,
                  child: MekanKarti(
                    isim: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                    kategori: mekan.kategori,
                    puan: mekan.ortalamaPuan,
                    imageUrl: mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : null,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MekanDetayEkrani(mekanId: mekan.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}