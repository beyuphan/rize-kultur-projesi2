// lib/presentation/features/rotalar/widgets/rota_bilgi_karti.dart

import 'package:flutter/material.dart';
import 'package:mobil_flutter/data/models/rota_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

class RotaBilgiKarti extends StatelessWidget {
  final RotaModel rota;
  const RotaBilgiKarti({super.key, required this.rota});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(langCode == 'tr' ? rota.aciklama.tr : rota.aciklama.en, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(l10n: l10n, icon: Icons.timer_outlined, label: l10n.duration, value: langCode == 'tr' ? rota.tahminiSure.tr : rota.tahminiSure.en, color: Colors.blue),
                _buildInfoChip(l10n: l10n, icon: Icons.hiking, label: l10n.difficulty, value: langCode == 'tr' ? rota.zorlukSeviyesi.tr : rota.zorlukSeviyesi.en, color: Colors.orange),
               _buildInfoChip(l10n: l10n, icon: Icons.location_on_outlined, label: l10n.stops, value: '${rota.mekanlar.length} ${l10n.stops}', color: Colors.green),         
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required AppLocalizations l10n, required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}