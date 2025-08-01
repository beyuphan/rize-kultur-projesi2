// lib/presentation/features/rotalar/widgets/rota_duraklari_tab.dart

import 'package:flutter/material.dart';
import 'package:mobil_flutter/data/models/durak_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/features/rotalar/screens/rota_detay_ekrani.dart';

class RotaDuraklariTab extends StatelessWidget {
  // --- DEĞİŞİKLİK: Artık MekanModel değil, DurakModel listesi alıyoruz.
  final List<DurakModel> duraklar;
  const RotaDuraklariTab({super.key, required this.duraklar});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    if (duraklar.isEmpty) {
      return Center(child: Text("deneme")); // l10n.stopsNotFound eklemelisin
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: duraklar.length,
      itemBuilder: (context, index) {
        final durak = duraklar[index];
        final mekan = durak.mekan;
        final bool sonDurakMi = index == duraklar.length - 1;

        // Her bir durak ve altındaki mesafe bilgisi için Column kullanıyoruz
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Mekan Kartı
            Card(
              margin: const EdgeInsets.only(top: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(langCode == 'tr' ? mekan.isim.tr : mekan.isim.en, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(langCode == 'tr' ? mekan.aciklama.tr : mekan.aciklama.en, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => showMekanDetay(context, mekan, l10n, langCode),
              ),
            ),

            // 2. Mesafe Bilgisi (Eğer son durak değilse ve bilgi varsa)
            if (!sonDurakMi && durak.sonrakiDuragaMesafe != null)
              _buildDistanceInfo(
                context, 
                durak.sonrakiDuragaMesafe!, 
                durak.sonrakiDuragaSure!,
              ),
          ],
        );
      },
    );
  }

  // Duraklar arasındaki mesafeyi gösteren yardımcı widget
  Widget _buildDistanceInfo(BuildContext context, String mesafe, String sure) {
    return Container(
      padding: const EdgeInsets.only(left: 56, top: 12, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.directions_car, color: Colors.grey[700], size: 18),
          const SizedBox(width: 8),
          Text(mesafe, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Icon(Icons.timer_outlined, color: Colors.grey[700], size: 18),
          const SizedBox(width: 8),
          Text(sure, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}