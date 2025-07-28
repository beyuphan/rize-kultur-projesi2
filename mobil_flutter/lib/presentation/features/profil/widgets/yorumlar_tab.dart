// lib/presentation/screens/profil/widgets/yorumlar_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/features/venue/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
import 'package:intl/intl.dart';

// DÜZELTME: Bu widget artık "aptal". Veriyi dışarıdan parametre olarak alıyor.
class YorumlarTab extends ConsumerWidget {
  final List<YorumModel> yorumlar;
  const YorumlarTab({super.key, required this.yorumlar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (yorumlar.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noCommentsYet));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: yorumlar.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final yorum = yorumlar[index];
        return _ProfilYorumKarti(yorum: yorum);
      },
    );
  }
}

class _ProfilYorumKarti extends StatelessWidget {
  const _ProfilYorumKarti({required this.yorum});
  final YorumModel yorum;

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final bool mekanMevcut = yorum.mekan != null;
    final formattedDate = DateFormat.yMMMMd(langCode).format(yorum.yorumTarihi);

    return Card(
      color: mekanMevcut ? null : theme.disabledColor.withOpacity(0.1),
      elevation: mekanMevcut ? 1 : 0,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              mekanMevcut && yorum.mekan!.fotograflar.isNotEmpty
                  ? yorum.mekan!.fotograflar[0]
                  : 'https://placehold.co/100x100/EEE/31343C?text=...',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.location_off),
            ),
          ),
        ),
        title: Text(
          langCode == 'tr' ? yorum.mekan?.isim.tr ?? 'Mekan Silinmiş' : yorum.mekan?.isim.en ?? 'Deleted Place',
          style: TextStyle(fontWeight: FontWeight.bold, color: mekanMevcut ? null : theme.disabledColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(yorum.icerik ?? "(Sadece puan verildi)", maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        trailing: yorum.puan != null
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                PuanGostergesi(puan: yorum.puan!, iconSize: 14),
                const SizedBox(width: 4),
                Text(yorum.puan!.toStringAsFixed(1), style: theme.textTheme.bodySmall),
              ])
            : null,
        onTap: mekanMevcut
            ? () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MekanDetayEkrani(mekanId: yorum.mekan!.id)))
            : null,
      ),
    );
  }
}