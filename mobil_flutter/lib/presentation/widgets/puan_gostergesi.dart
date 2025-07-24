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
    const cayYapragiIkonu = Icons.eco;
    final tema = Theme.of(context);
    final aktifRenk = tema.colorScheme.secondary;
    final pasifRenk = tema.dividerColor.withOpacity(0.5);

    // Tek bir ikon sırası oluşturan yardımcı bir fonksiyon
    Row buildIconRow(Color renk) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxPuan, (index) {
          return Icon(
            cayYapragiIkonu,
            color: renk,
            size: iconSize,
          );
        }),
      );
    }

    return Stack(
      children: [
        // 1. Katman: Alttaki boş ikonlar
        buildIconRow(pasifRenk),
        // 2. Katman: Kırpılmış dolu ikonlar
        ClipRect(
          clipper: _PuanClipper(puan: puan, maxPuan: maxPuan),
          child: buildIconRow(aktifRenk),
        ),
      ],
    );
  }
}

// Bu yardımcı sınıf, üstteki widget'ı doğru oranda kırpmamızı sağlar
class _PuanClipper extends CustomClipper<Rect> {
  _PuanClipper({required this.puan, required this.maxPuan});
  
  final double puan;
  final int maxPuan;

  @override
  Rect getClip(Size size) {
    // Toplam genişliğin ne kadarının gösterileceğini hesapla
    final double dolulukOrani = (puan / maxPuan).clamp(0.0, 1.0);
    return Rect.fromLTRB(0, 0, size.width * dolulukOrani, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    // Puan değiştiğinde kırpma işleminin yeniden yapılmasını sağlar
    return oldClipper is _PuanClipper && oldClipper.puan != puan;
  }
}
