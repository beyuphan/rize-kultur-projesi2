import 'package:flutter/material.dart';
// Yeni puan göstergemizi import ediyoruz
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';

class MekanKarti extends StatelessWidget {
  const MekanKarti({
    super.key,
    required this.isim,
    required this.kategori,
    required this.puan,
    required this.imageUrl,
    this.onTap,
  });

  final String isim;
  final String kategori;
  final double puan;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
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
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: theme.colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kategori,
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  
                  // ESKİ PUAN SİSTEMİNİ SİLİP YENİSİNİ KOYUYORUZ
                  Row(
                    children: [
                      PuanGostergesi(puan: puan), // İşte yeni sistemimiz!
                      const SizedBox(width: 8),
                      Text(
                        puan.toStringAsFixed(1), // 4.8 gibi sayıyı yine de yanında gösterelim
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