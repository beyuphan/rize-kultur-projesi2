import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/presentation/features/profil/screens//profil_sayfasi.dart'; 
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';

class YorumKarti extends StatelessWidget {
  final YorumModel yorum;

  const YorumKarti({
    super.key,
    required this.yorum,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    // DİL KODUNU BURADA ALALIM
    final langCode = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: tema.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: tema.dividerColor.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // YENİ: Yazar bilgisi alanını tıklanabilir yapmak için InkWell
          InkWell(
            onTap: () {
              // Tıklandığında yazarın profil sayfasına git
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfilSayfasi(userId: yorum.yazar.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8), // Tıklama efektinin şekli
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // DÜZELTME: Profil fotoğrafını yorum.yazar'dan al
                  CircleAvatar(
                    backgroundImage: (yorum.yazar.profilFotoUrl != null &&
                            yorum.yazar.profilFotoUrl!.isNotEmpty)
                        ? NetworkImage(yorum.yazar.profilFotoUrl!)
                        : null,
                    child: (yorum.yazar.profilFotoUrl == null ||
                            yorum.yazar.profilFotoUrl!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DÜZELTME: Kullanıcı adını yorum.yazar'dan al
                        Text(
                          yorum.yazar.kullaniciAdi,
                          style: tema.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // DÜZELTME: Tarihi yorum'dan al ve formatla
                        Text(
                          DateFormat.yMMMMd(langCode)
                              .format(yorum.yorumTarihi),
                          style: tema.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // DÜZELTME: Puanı yorum'dan al
                  if (yorum.puan != null)
                    PuanGostergesi(puan: yorum.puan!, iconSize: 16),
                ],
              ),
            ),
          ),
          // DÜZELTME: Yorum içeriğini yorum.icerik'ten al
          if (yorum.icerik != null && yorum.icerik!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              yorum.icerik!,
              style: tema.textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}