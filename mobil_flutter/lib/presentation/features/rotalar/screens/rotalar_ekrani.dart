import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart'; // DİL DOSYASINI IMPORT ET
import 'package:mobil_flutter/presentation/features/rotalar/screens/rota_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/providers/rota_providers.dart';

class RotalarEkrani extends ConsumerWidget {
  const RotalarEkrani({super.key});

  // Dinamik anahtarları metne çevirmek için bir yardımcı fonksiyon
  String _translate(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      // Rota Adları
      case 'firtinaVadisiName':
        return l10n.firtinaVadisiName;
      case 'kackarlarZirveName':
        return l10n.kackarlarZirveName;
      case 'cayBahceleriName':
        return l10n.cayBahceleriName;
      // Açıklamalar
      case 'firtinaVadisiDescription':
        return l10n.firtinaVadisiDescription;
      case 'kackarlarZirveDescription':
        return l10n.kackarlarZirveDescription;
      case 'cayBahceleriDescription':
        return l10n.cayBahceleriDescription;
      // Süreler
      case 'firtinaVadisiDuration':
        return l10n.firtinaVadisiDuration;
      case 'kackarlarZirveDuration':
        return l10n.kackarlarZirveDuration;
      case 'cayBahceleriDuration':
        return l10n.cayBahceleriDuration;
      // Zorluklar
      case 'firtinaVadisiDifficulty':
        return l10n.firtinaVadisiDifficulty;
      case 'kackarlarZirveDifficulty':
        return l10n.kackarlarZirveDifficulty;
      case 'cayBahceleriDifficulty':
        return l10n.cayBahceleriDifficulty;
      default:
        return 'Key Not Found';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotaProviderState = ref.watch(rotaProvider);
    final l10n = AppLocalizations.of(
      context,
    )!; // l10n değişkenini burada alalım

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discoverRoutesTitle), // <-- ÇEVİRİ KULLANILDI
        centerTitle: true,
      ),
      body: _buildBody(context, rotaProviderState, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RotaProvider provider,
    AppLocalizations l10n,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.hata != null) {
      return Center(
        child: Text(l10n.routeLoadingError),
      ); // <-- ÇEVİRİ KULLANILDI
    }
    if (provider.rotalar.isEmpty) {
      return Center(child: Text(l10n.routesNotFound)); // <-- ÇEVİRİ KULLANILDI
    }

    return ListView.builder(
      itemCount: provider.rotalar.length,
      itemBuilder: (context, index) {
        final rota = provider.rotalar[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RotaDetayEkrani(rota: rota),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // ... Card'ın diğer özellikleri aynı ...
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image.network aynı kalıyor...
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _translate(
                          context,
                          rota.adKey,
                        ), // <-- YARDIMCI FONKSİYON KULLANILDI
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _translate(
                          context,
                          rota.aciklamaKey,
                        ), // <-- YARDIMCI FONKSİYON KULLANILDI
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _translate(context, rota.tahminiSureKey),
                              ), // <-- YARDIMCI FONKSİYON KULLANILDI
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.hiking,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _translate(context, rota.zorlukSeviyesiKey),
                              ), // <-- YARDIMCI FONKSİYON KULLANILDI
                            ],
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
  }
}
