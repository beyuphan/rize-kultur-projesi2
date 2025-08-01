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
    // DİNAMİK YAPI: Artık veriyi provider'dan izliyoruz
    final rotalarAsync = ref.watch(rotalarProvider);
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discoverRoutesTitle),
        centerTitle: true,
      ),
      body: rotalarAsync.when(
        // Veri yüklenirken gösterilecek
        loading: () => const Center(child: CircularProgressIndicator()),
        // Hata durumunda gösterilecek
        error: (err, stack) => Center(child: Text(l10n.routeLoadingError)),
        // Veri başarıyla geldiğinde gösterilecek
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // DİNAMİK YAPI: Artık Rota objesini değil, sadece ID'sini gönderiyoruz
                      builder: (context) => RotaDetayEkrani(rotaId: rota.id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.network(
                        rota.kapakFotografiUrl,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // DİNAMİK YAPI: Çeviriyi artık doğrudan modelden okuyoruz
                              langCode == 'tr' ? rota.ad.tr : rota.ad.en,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              langCode == 'tr' ? rota.aciklama.tr : rota.aciklama.en,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoChip(
                                  icon: Icons.timer_outlined,
                                  text: langCode == 'tr' ? rota.tahminiSure.tr : rota.tahminiSure.en,
                                ),
                                _buildInfoChip(
                                  icon: Icons.hiking,
                                  text: langCode == 'tr' ? rota.zorlukSeviyesi.tr : rota.zorlukSeviyesi.en,
                                ),
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

  // Kart içindeki küçük bilgi ikonları için yardımcı widget
  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
      ],
    );
  }
}
