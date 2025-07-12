import 'package:flutter/material.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart'; // Puan göstergemizi burada da kullanacağız!

class YorumKarti extends StatelessWidget {
  const YorumKarti({
    super.key,
    required this.kullaniciAdi,
    required this.yorum,
    required this.puan,
    this.kullaniciImageUrl,
  });

  final String kullaniciAdi;
  final String yorum;
  final double puan;
  final String? kullaniciImageUrl; // Profil fotoğrafı (isteğe bağlı)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      // Yorumlar arasına ayırıcı bir çizgi koyuyoruz
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı Profil Fotoğrafı
          CircleAvatar(
            radius: 24,
            backgroundImage: kullaniciImageUrl != null
                ? NetworkImage(kullaniciImageUrl!)
                : null,
            // Eğer profil fotoğrafı yoksa, baş harflerini gösterelim
            child: kullaniciImageUrl == null
                ? Text(kullaniciAdi.isNotEmpty ? kullaniciAdi[0].toUpperCase() : 'K')
                : null,
          ),
          const SizedBox(width: 16),
          // Yorum İçeriği
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Adı ve Puan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      kullaniciAdi,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                    PuanGostergesi(puan: puan, iconSize: 16),
                  ],
                ),
                const SizedBox(height: 8),
                // Yorum Metni
                Text(
                  yorum,
                  style: theme.textTheme.bodyMedium,
                ),
                // İleride buraya yoruma eklenen fotoğraf da gelebilir
              ],
            ),
          ),
        ],
      ),
    );
  }
}
