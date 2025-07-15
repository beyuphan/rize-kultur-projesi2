import 'package:flutter/material.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';

class YorumKarti extends StatelessWidget {
  final String kullaniciAdi;
  final String? kullaniciImageUrl;
  final double puan;
  final String yorum;

  const YorumKarti({
    super.key,
    required this.kullaniciAdi,
    this.kullaniciImageUrl,
    required this.puan,
    required this.yorum,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Kullanıcı Avatarı
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: kullaniciImageUrl != null
                    ? NetworkImage(kullaniciImageUrl!)
                    : null,
                child: kullaniciImageUrl == null
                    ? Text(
                        kullaniciAdi.isNotEmpty ? kullaniciAdi[0] : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Kullanıcı Adı ve Puan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kullaniciAdi,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    PuanGostergesi(puan: puan, iconSize: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Yorum Metni
          Text(
            yorum,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
