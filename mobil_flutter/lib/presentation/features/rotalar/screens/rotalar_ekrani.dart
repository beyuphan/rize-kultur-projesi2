// lib/presentation/features/rotalar/screens/rotalar_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/features/rotalar/screens/rota_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/providers/rota_providers.dart';

class RotalarEkrani extends ConsumerWidget {
  const RotalarEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotalarAsync = ref.watch(rotalarProvider);
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discoverRoutesTitle),
        centerTitle: true,
      ),
      body: rotalarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
        print("!!! ROTALAR YÜKLENİRKEN HATA YAKALANDI !!!");
        print("HATA TÜRÜ: ${err.runtimeType}");
        print("HATA MESAJI: $err");
        print("STACK TRACE: $stack");
        return Center(child: Text(l10n.routeLoadingError));
      },
        data: (rotalar) {
          if (rotalar.isEmpty) {
            return Center(child: Text(l10n.routesNotFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: rotalar.length,
            itemBuilder: (context, index) {
              final rota = rotalar[index];
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => RotaDetayEkrani(rotaId: rota.id),
                  ));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.network(
                        rota.kapakFotografiUrl,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // DÜZELTME: Artık _translate yok, direkt modelden okuyoruz
                              langCode == 'tr' ? rota.ad.tr : rota.ad.en,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              langCode == 'tr' ? rota.aciklama.tr : rota.aciklama.en,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(langCode == 'tr' ? rota.tahminiSure.tr : rota.tahminiSure.en),
                                ]),
                                Row(children: [
                                  const Icon(Icons.hiking, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(langCode == 'tr' ? rota.zorlukSeviyesi.tr : rota.zorlukSeviyesi.en),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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