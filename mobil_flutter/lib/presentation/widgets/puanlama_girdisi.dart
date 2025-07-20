// lib/presentation/widgets/puanlama_girdisi.dart

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
    // Eğer parent widget'tan gelen 'baslangicPuani' değiştiyse,
    // bizim içimizdeki '_mevcutPuan'ı da bu yeni değerle güncelleyelim.
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
            _mevcutPuan > index ? cayYapragiDolu : cayYapragiBos,
            color: tema.colorScheme.secondary,
            size: widget.iconBoyutu,
          ),
          onPressed: () {
            final yeniPuan = index + 1.0;
            setState(() {
              _mevcutPuan = yeniPuan;
            });
            widget.onPuanDegisti(yeniPuan);
          },
        );
      }),
    );
  }
}