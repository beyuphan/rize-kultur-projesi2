import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';



class YorumlarTab extends ConsumerWidget {
  const YorumlarTab({super.key}); // const constructor ekledik
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yorumlarAsync = ref.watch(kullaniciYorumlariProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    return yorumlarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Yorumlar yüklenemedi: $err')),
      data: (yorumlar) => yorumlar.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noCommentsYet))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: yorumlar.length,
              itemBuilder: (context, index) {
                final yorum = yorumlar[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      langCode == 'tr' ? yorum.mekan?.isim.tr ?? 'Mekan Silinmiş' : yorum.mekan?.isim.en ?? 'Deleted Place',
                    ),
                    subtitle: Text(
                      yorum.icerik ?? "(Sadece puan verildi)",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: yorum.puan != null
                        ? Text("★ ${yorum.puan!.toStringAsFixed(1)}", style: const TextStyle(fontSize: 16, color: Colors.amber))
                        : null,
                    onTap: () {
                      if (yorum.mekan != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MekanDetayEkrani(mekanId: yorum.mekan!.id)),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
