import 'package:flutter/material.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
// Tarih formatlamak için intl paketini eklemek en iyisidir.
// Terminalde 'flutter pub add intl' komutunu çalıştır.
import 'package:intl/intl.dart';

class YorumKarti extends StatelessWidget {
  final String kullaniciAdi;
  final String? kullaniciImageUrl;
  final double? puan; // GÜNCELLENDİ: Artık null olabilir
  final String? yorum; // GÜNCELLENDİ: Artık null olabilir
  final DateTime? yorumTarihi; // YENİ: Tarih parametresi eklendi

  const YorumKarti({
    super.key,
    required this.kullaniciAdi,
    this.kullaniciImageUrl,
    this.puan,
    this.yorum,
    this.yorumTarihi,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: tema.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: (kullaniciImageUrl != null && kullaniciImageUrl!.isNotEmpty)
                    ? NetworkImage(kullaniciImageUrl!)
                    : null,
                child: (kullaniciImageUrl == null || kullaniciImageUrl!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kullaniciAdi,
                      style: tema.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // YENİ: Yorum tarihi varsa, formatlayıp gösterelim.
                    if (yorumTarihi != null)
                      Text(
                        DateFormat.yMMMMd('tr_TR').format(yorumTarihi!), // Ör: 17 Temmuz 2025
                        style: tema.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // GÜNCELLENDİ: Puan null değilse PuanGostergesi'ni göster.
              if (puan != null) PuanGostergesi(puan: puan!, iconSize: 16),
            ],
          ),
          // GÜNCELLENDİ: Yorum null veya boş değilse göster.
          if (yorum != null && yorum!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              yorum!,
              style: tema.textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}