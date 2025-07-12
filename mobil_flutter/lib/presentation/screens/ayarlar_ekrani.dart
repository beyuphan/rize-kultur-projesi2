import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/common/theme/app_themes.dart';
import 'package:mobil_flutter/main.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

class AyarlarEkrani extends ConsumerWidget {
  const AyarlarEkrani({super.key});

  // Tema seçimi için diyalog penceresini gösteren fonksiyon
  void _temaSecimiGoster(BuildContext context, WidgetRef ref) {
    // Çeviri nesnesini fonksiyon içinde alıyoruz
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(l10n.selectThemeTitle), // Dinamik başlık
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                ref.read(themeProvider.notifier).state = AppTheme.yaylaYesili;
                Navigator.pop(context);
              },
              child: Text(l10n.yaylaGreen), // Dinamik metin
            ),
            SimpleDialogOption(
              onPressed: () {
                ref.read(themeProvider.notifier).state = AppTheme.sisBulutu;
                Navigator.pop(context);
              },
              child: Text(l10n.fogCloud), // Dinamik metin
            ),
          ],
        );
      },
    );
  }

  // Dil seçimi için diyalog penceresini gösteren fonksiyon
  void _dilSecimiGoster(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(l10n.selectLanguageTitle), // Dinamik başlık
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                ref.read(localeProvider.notifier).state = const Locale('tr');
                Navigator.pop(context);
              },
              child: Text(l10n.turkish), // Dinamik metin
            ),
            SimpleDialogOption(
              onPressed: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(context);
              },
              child: Text(l10n.english), // Dinamik metin
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Çeviri nesnesini build metodunun başında alıyoruz
    final l10n = AppLocalizations.of(context)!;
    final mevcutTema = ref.watch(themeProvider);
    final mevcutDil = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle), // Dinamik başlık
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.appTheme), // Dinamik metin
            subtitle: Text(mevcutTema == AppTheme.yaylaYesili
                ? l10n.yaylaGreen
                : l10n.fogCloud),
            onTap: () => _temaSecimiGoster(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language), // Dinamik metin
            subtitle: Text(mevcutDil.languageCode == 'tr' ? l10n.turkish : l10n.english),
            onTap: () => _dilSecimiGoster(context, ref),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
