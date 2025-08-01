// lib/presentation/features/rotalar/widgets/rota_duraklari_tab.dart

import 'package:flutter/material.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

import 'package:mobil_flutter/presentation/features/rotalar/screens/rota_detay_ekrani.dart';
class RotaDuraklariTab extends StatelessWidget {
  final List<MekanModel> mekanlar;
  const RotaDuraklariTab({super.key, required this.mekanlar});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mekanlar.length,
      itemBuilder: (context, index) {
        final mekan = mekanlar[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(langCode == 'tr' ? mekan.isim.tr : mekan.isim.en, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(langCode == 'tr' ? mekan.aciklama.tr : mekan.aciklama.en, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => showMekanDetay(context, mekan, l10n, langCode),
          ),
        );
      },
    );
  }
}