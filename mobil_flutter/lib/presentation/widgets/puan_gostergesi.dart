import 'package:flutter/material.dart';

class PuanGostergesi extends StatelessWidget {
  const PuanGostergesi({
    super.key,
    required this.puan,
    this.iconSize = 20.0,
    this.maxPuan = 5,
  });

  final double puan;
  final double iconSize;
  final int maxPuan;

  @override
  Widget build(BuildContext context) {
    const cayYapragiIkonu = Icons.eco; // Kendi özel SVG ikonumuzu kullanana kadar...
    final tema = Theme.of(context);

    // Puanın, 0 ile 5 arasında olduğundan emin oluyoruz.
    final gecerliPuan = puan.clamp(0.0, maxPuan.toDouble());
    
    // Doluluk oranını hesaplıyoruz (ör: 4.8 puan -> 0.96)
    final dolulukOrani = gecerliPuan / maxPuan;

    return ShaderMask(
      // İşte sihir burada! Bu maske, altındaki widget'a bir gradyan uygular.
      shaderCallback: (Rect bounds) {
        // Sol alttan sağ üste giden bir gradyan oluşturuyoruz.
        return LinearGradient(
          // DÜZELTME: Eğimi biraz daha yatay yapmak için y eksenindeki değerleri küçültüyoruz.
          // Bu, dolumun 45 dereceden daha yumuşak bir açıyla olmasını sağlar.
          begin: const Alignment(-0.3, 0.6),
          end: const Alignment(0.9, -0.8),
          // Puanımıza göre gradyanın nerede başlayıp biteceğini hesaplıyoruz.
          // Dolu kısım temanın vurgu rengi, boş kısım şeffaf olacak.
          stops: [0.0, dolulukOrani, dolulukOrani],
          colors: [
            tema.colorScheme.secondary, // Başlangıç rengi (dolu)
            tema.colorScheme.secondary, // Bitiş rengi (dolu)
            tema.colorScheme.secondary.withOpacity(0.0) // Şeffaf (görünmez) kısım
          ],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxPuan, (index) {
          // Bu katman, her zaman 5 tane tam dolu, beyaz (veya herhangi bir renk)
          // ikon çizer. Üstteki ShaderMask, bunları doğru şekilde boyayacak.
          return Icon(
            cayYapragiIkonu,
            color: Colors.white, // Maskenin çalışması için burası dolu bir renk olmalı.
            size: iconSize,
          );
        }),
      ),
    );
  }
}
