import 'package:flutter/material.dart';

class PuanGostergesi extends StatelessWidget {
  const PuanGostergesi({
    super.key,
    required this.puan,
    this.iconSize = 20.0,
    this.maxPuan = 5,
    this.aktifRenk = const Color.fromARGB(115, 143, 125, 23), // <-- 1. YENİ PARAMETRE: Aktif ikonlar için isteğe bağlı renk
  });

  final double puan;
  final double iconSize;
  final int maxPuan;
  final Color? aktifRenk; // <-- Parametrenin tanımı

  @override
  Widget build(BuildContext context) {
    const cayYapragiIkonu = Icons.eco;
    final tema = Theme.of(context);

    // <-- 2. GÜNCELLEME: Rengi belirleme mantığı
    // Eğer dışarıdan bir `aktifRenk` verildiyse onu kullan, verilmediyse temadan al.
    final Color secilenAktifRenk = aktifRenk ?? tema.colorScheme.secondary;
    final Color pasifRenk = tema.dividerColor.withOpacity(0.5);

    // Tek bir ikon sırası oluşturan yardımcı bir fonksiyon
    Row buildIconRow(Color renk) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxPuan, (index) {
          return Icon(cayYapragiIkonu, color: renk, size: iconSize);
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
          // <-- 3. GÜNCELLEME: Seçilen rengi burada kullan
          child: buildIconRow(secilenAktifRenk),
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
