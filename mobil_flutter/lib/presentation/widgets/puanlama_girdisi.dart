// lib/presentation/widgets/puanlama_girdisi.dart (DÜZELTİLMİŞ TAM KOD)

import 'package:flutter/material.dart';

class PuanlamaGirdisi extends StatefulWidget {
  final Function(double) onPuanDegisti;
  final double baslangicPuani;
  final double iconBoyutu;

  const PuanlamaGirdisi({
    super.key,
    required this.onPuanDegisti,
    this.baslangicPuani = 0.0,
    this.iconBoyutu = 32.0,
  });

  @override
  State<PuanlamaGirdisi> createState() => _PuanlamaGirdisiState();
}

class _PuanlamaGirdisiState extends State<PuanlamaGirdisi> {
  late double _mevcutPuan;

  @override
  void initState() {
    super.initState();
    _mevcutPuan = widget.baslangicPuani;
  }

  @override
  void didUpdateWidget(PuanlamaGirdisi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.baslangicPuani != oldWidget.baslangicPuani) {
      setState(() {
        _mevcutPuan = widget.baslangicPuani;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const cayYapragiDolu = Icons.eco;
    const cayYapragiBos = Icons.eco_outlined;
    final tema = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            // Görünüm mantığı doğru, dokunmuyoruz.
            _mevcutPuan > index ? cayYapragiDolu : cayYapragiBos,
            color: tema.colorScheme.primary, // secondary yerine primary daha iyi olabilir
            size: widget.iconBoyutu,
          ),
          onPressed: () {
            // --- DÜZELTME BURADA BAŞLIYOR ---
            
            // Kullanıcının tıkladığı ikonun puan değerini hesapla
            double tiklananPuan = index + 1.0;

            // Eğer kullanıcı mevcut puana eşit olan ikona tekrar tıkladıysa,
            // puanı sıfırla. Aksi halde, yeni puanı ata.
            if (_mevcutPuan == tiklananPuan) {
              tiklananPuan = 0.0;
            }

            // State'i ve dışarıyı yeni hesaplanan puanla bilgilendir
            setState(() {
              _mevcutPuan = tiklananPuan;
            });
            widget.onPuanDegisti(tiklananPuan);
            
            // --- DÜZELTME BİTTİ ---
          },
        );
      }),
    );
  }
}