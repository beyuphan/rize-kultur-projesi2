import 'package:flutter/material.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart'; // YENİ: l10n import'u eklendi

class MekanKarti extends StatelessWidget {
  final String isim;
  final String kategoriKey; // DÜZELTME: Artık çevrilmemiş anahtarı alacak (kategori -> kategoriKey)
    final double puan;
  final String? imageUrl;
  final VoidCallback? onTap;
    final AppLocalizations l10n; // YENİ: Çeviri yapabilmesi için l10n objesini alacak

  const MekanKarti({
    super.key,
    required this.isim,
    required this.kategoriKey,
    required this.puan,
        required this.l10n,       // YENİ
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // YENİ: Çeviri mantığı artık kartın kendi içinde
    String getTranslatedCategory(String key) {
      switch (key) {
        case 'categoryAll':
          return l10n.categoryAll;
        case 'categoryPlateaus':
          return l10n.categoryPlateaus;
        case 'categoryWaterfalls':
          return l10n.categoryWaterfalls;
        case 'categoryRestaurants':
          return l10n.categoryRestaurants;
        case 'categoryHistorical':
          return l10n.categoryHistorical;
        default:
          return key; // Bilinmeyen bir key gelirse, olduğu gibi göster
      }
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim Alanı
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                // --- İŞTE DÜZELTME BURADA ---
                child: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? Image.network(
                        imageUrl!.trim(), // Artık '!' ile güvenli
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 140,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('MekanKarti Resim Hatası: $error');
                          return const SizedBox(
                            height: 140,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey,
                              size: 60,
                            ),
                          );
                        },
                      )
                    : Container( // imageUrl null ise bunu göster
                        height: 140,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey[400],
                            size: 50,
                          ),
                        ),
                      ),
              ),
            ),
            // Yazı Alanı
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isim,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(getTranslatedCategory(kategoriKey), style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      PuanGostergesi(puan: puan, iconSize: 16),
                      const SizedBox(width: 8),
                      Text(
                        puan.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}