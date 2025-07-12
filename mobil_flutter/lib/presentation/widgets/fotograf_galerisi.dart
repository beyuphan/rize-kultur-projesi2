import 'package:flutter/material.dart';

class FotografGalerisi extends StatelessWidget {
  const FotografGalerisi({
    super.key,
    required this.imageUrls,
  });

  final List<String> imageUrls;

  // Fotoğrafı tam ekran göstermek için yeni bir sayfa açan fonksiyon
  void _tamEkranGoster(BuildContext context, int baslangicIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TamEkranFotografSayfasi(
          imageUrls: imageUrls,
          baslangicIndex: baslangicIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Galerinin yüksekliği
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _tamEkranGoster(context, index),
            child: Container(
              width: 120, // Her bir fotoğrafın genişliği
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrls[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Tam ekran fotoğraf görüntüleyici için özel bir sayfa
class _TamEkranFotografSayfasi extends StatelessWidget {
  const _TamEkranFotografSayfasi({
    required this.imageUrls,
    required this.baslangicIndex,
  });

  final List<String> imageUrls;
  final int baslangicIndex;

  @override
  Widget build(BuildContext context) {
    // PageController ile başlangıç sayfasını ayarlıyoruz
    final pageController = PageController(initialPage: baslangicIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Geri butonu beyaz olsun
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer( // Yakınlaştırma ve kaydırma için
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
