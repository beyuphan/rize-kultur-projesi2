import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/main.dart'; // Tema ve dil provider'ları için
import 'package:mobil_flutter/common/theme/app_themes.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

// Widget'ı StatefulWidget yerine ConsumerWidget yapıyoruz.
class ProfilVeAyarlarEkrani extends ConsumerWidget {
  const ProfilVeAyarlarEkrani({super.key});

  // Tema seçimi için diyalog penceresini gösteren fonksiyon
  void _temaSecimiGoster(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(l10n.selectThemeTitle),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                ref.read(themeProvider.notifier).state = AppTheme.firtinaYesili;
                Navigator.pop(context);
              },
              child: Text(l10n.themeFirtinaYesili),
            ),
            SimpleDialogOption(
              onPressed: () {
                ref.read(themeProvider.notifier).state = AppTheme.kackarSisi;
                Navigator.pop(context);
              },
              child: Text(l10n.themeKackarSisi),
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

    // Sekmeli yapı için DefaultTabController kullanıyoruz
    return DefaultTabController(
      length: 3, // 3 adet sekmemiz olacak
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profilim'),
          // AppBar'ın altına TabBar'ı ekliyoruz
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.article_outlined), text: "Gönderilerim"),
              Tab(icon: Icon(Icons.favorite_border), text: "Favorilerim"),
              Tab(icon: Icon(Icons.settings_outlined), text: "Ayarlar"),
            ],
          ),
          actions: [
            // Çıkış yap butonu
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Çıkış Yap',
              // YENİ: Artık AuthNotifier'daki cikisYap fonksiyonunu çağırıyoruz.
              onPressed: () => ref.read(authProvider.notifier).cikisYap(),
            ),
          ],
        ),
        // TabBarView ile sekmelerin içeriğini belirliyoruz
        body: TabBarView(
          children: [
            // 1. Sekme: Gönderilerim
            const Center(
              child: Text('Kullanıcının gönderileri burada listelenecek.'),
            ),

            // 2. Sekme: Favorilerim
            const Center(
              child: Text('Kullanıcının favori mekanları burada listelenecek.'),
            ),

            // 3. Sekme: Ayarlar (Fonksiyonel hale getirildi)
            ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n.appTheme),
                  subtitle: Text(
                    mevcutTema == AppTheme.firtinaYesili
                        ? l10n.themeFirtinaYesili
                        : l10n.themeKackarSisi,
                  ),
                  onTap: () => _temaSecimiGoster(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.language),
                  subtitle: Text(
                    mevcutDil.languageCode == 'tr'
                        ? l10n.turkish
                        : l10n.english,
                  ),
                  onTap: () => _dilSecimiGoster(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Hesap Bilgileri'),
                  onTap: () {
                    // TODO: Ayrı bir hesap bilgileri ekranına yönlendirilebilir.
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
