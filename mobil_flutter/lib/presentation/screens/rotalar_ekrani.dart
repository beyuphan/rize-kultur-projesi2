import 'package:flutter/material.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart'; // 1. Dil dosyasını import et


class RotalarEkrani extends StatelessWidget {
  const RotalarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 2. Çeviri nesnesini al

    return Scaffold(
      body: Center(
        // 4. İçerik metnini de şimdilik dinamik yapıyoruz
        child: Text(l10n.routes),
      ),
    );
  }
}