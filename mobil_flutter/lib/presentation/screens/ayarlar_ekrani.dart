import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/common/theme/app_themes.dart';
import 'package:mobil_flutter/main.dart'; // Provider'larımızın olduğu yer
import 'package:mobil_flutter/l10n/app_localizations.dart';

class AyarlarEkrani extends ConsumerWidget {
  const AyarlarEkrani({super.key});

  // Tema seçimi için diyalog penceresini gösteren fonksiyon
  void _temaSecimiGoster(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(l10n.selectThemeTitle),
          children: <Widget>[
            // DÜZELTME: Her seçenek artık doğru temayı ayarlıyor ve doğru metni gösteriyor.
            SimpleDialogOption(
              onPressed: () {
                ref.read(themeProvider.notifier).state = AppTheme.firtinaYesili;
                Navigator.pop(context);
              },
              child: Text(l10n.themeFirtinaYesili), // "Fırtına Yeşili"
            ),
            SimpleDialogOption(
              onPressed: () {
                ref.read(themeProvider.notifier).state = AppTheme.kackarSisi;
                Navigator.pop(context);
              },
              child: Text(l10n.themeKackarSisi), // "Kaçkar Sisi"
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
          title: Text(l10n.selectLanguageTitle),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                ref.read(localeProvider.notifier).state = const Locale('tr');
                Navigator.pop(context);
              },
              child: Text(l10n.turkish),
            ),
            SimpleDialogOption(
              onPressed: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(context);
              },
              child: Text(l10n.english),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mevcutTema = ref.watch(themeProvider);
    final mevcutDil = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.appTheme),
            // DÜZELTME: Artık mevcut temanın doğru ismini gösteriyor.
            subtitle: Text(mevcutTema == AppTheme.firtinaYesili
                ? l10n.themeFirtinaYesili
                : l10n.themeKackarSisi),
            onTap: () => _temaSecimiGoster(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            subtitle: Text(mevcutDil.languageCode == 'tr' ? l10n.turkish : l10n.english),
            onTap: () => _dilSecimiGoster(context, ref),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
