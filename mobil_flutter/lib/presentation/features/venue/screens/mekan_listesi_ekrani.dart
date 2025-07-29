// lib/presentation/screens/mekan_listesi_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';
import 'package:mobil_flutter/presentation/features/venue/screens/mekan_detay_ekrani.dart';

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
    final mekanlarAsync = ref.watch(mekanListesiProvider(ilkFiltre));
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // DÜZELTME: Standart AppBar yerine SliverAppBar
          SliverAppBar(
            title: Text(sayfaBasligi),
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          
          mekanlarAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Mekanlar yüklenemedi: $err')),
            ),
            data: (response) {
              final mekanlar = response.mekanlar;
              if (mekanlar.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text(l10n.noVenuesFound)),
                );
              }

              // DÜZELTME: ListView.builder'ı SliverList'e çeviriyoruz
              return SliverPadding(
                // DÜZELTME: Simetrik boşluklar için padding'i burada veriyoruz
                padding: const EdgeInsets.only(left: 0, right: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final mekan = mekanlar[index];
                      return Padding(
                        // Her kartın altına boşluk bırakıyoruz
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          height: 300, // Yüksekliği biraz artırdık
                          child: MekanKarti(
                            isim: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                            kategoriKey: mekan.kategori, // Bu key'in çevrilmesi için l10n objesini de paslamalıyız
                            l10n: l10n,
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
                    childCount: mekanlar.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}