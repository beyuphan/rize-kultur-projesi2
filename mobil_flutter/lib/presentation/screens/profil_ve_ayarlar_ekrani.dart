// lib/presentation/screens/profil_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/main.dart'; // Tema ve dil provider'ları için
import 'package:mobil_flutter/common/theme/app_themes.dart';

// Profil verisini getirmek için yeni bir FutureProvider
final userProfileProvider = FutureProvider((ref) {
  // authServiceProvider'ı direkt kullanıyoruz, bu zaten projemizde var.
  final authService = ref.watch(authServiceProvider);
  return authService.getMyProfile();
});

class ProfilEkrani extends ConsumerWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Profil yüklenemedi: $err')),
        data: (kullanici) {
          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 240.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: theme.colorScheme.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 50),
                      title: Text(
                        kullanici.kullaniciAdi,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      ),
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            kullanici.email,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: l10n.settings,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AyarlarEkrani()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: l10n.logout,
                        onPressed: () => ref.read(authProvider.notifier).cikisYap(),
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        tabs: [
                          Tab(text: l10n.reviews),
                          Tab(text: l10n.favorites),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  const Center(child: Text('Kullanıcının yaptığı yorumlar burada listelenecek.')),
                  const Center(child: Text('Kullanıcının favori mekanları burada listelenecek.')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// AYARLAR EKRANI (ÇALIŞAN KODUNLA ENTEGRE EDİLDİ)
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.editProfile),
            onTap: () {
              // TODO: Profil düzenleme ekranına yönlendir
            },
          ),
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
        ],
      ),
    );
  }
}

// TabBar'ı SliverAppBar içinde sabit tutmak için yardımcı bir sınıf (Değişiklik yok)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
