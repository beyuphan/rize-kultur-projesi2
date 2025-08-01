import 'package:flutter/material.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/features/rotalar/screens/rota_detay_ekrani.dart';

class RotaMekanlarTab extends StatelessWidget {
  final List<MekanModel> mekanlar;
  const RotaMekanlarTab({super.key, required this.mekanlar});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: mekanlar.length,
      itemBuilder: (context, index) {
        final mekan = mekanlar[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => showMekanDetay(context, mekan, l10n, langCode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: Image.network(mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : 'https://placehold.co/600x400', fit: BoxFit.cover)),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
