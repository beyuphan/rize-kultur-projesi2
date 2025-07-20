import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';

class YorumKarti extends StatelessWidget {
  final String kullaniciAdi;
  final String? kullaniciImageUrl;
  final double? puan;
  final String? yorum;
  final DateTime? yorumTarihi;

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
        border: Border.all(color: tema.dividerColor.withOpacity(0.1))
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
                    if (yorumTarihi != null)
                      Text(
                        DateFormat.yMMMMd('tr_TR').format(yorumTarihi!),
                        style: tema.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (puan != null) PuanGostergesi(puan: puan!, iconSize: 16),
            ],
          ),
          if (yorum != null && yorum!.trim().isNotEmpty) ...[
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