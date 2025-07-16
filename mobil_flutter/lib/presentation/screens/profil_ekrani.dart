// lib/presentation/screens/profil_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

// Profil verisini getirmek için yeni bir FutureProvider
final userProfileProvider = FutureProvider((ref) {
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
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 240.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: theme.colorScheme.surface,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      kullanici.kullaniciAdi,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          // TODO: Dinamik profil resmi eklenecek
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
                      icon: const Icon(Icons.logout),
                      onPressed: () => ref.read(authProvider.notifier).cikisYap(),
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      tabs: [
                        Tab(text: l10n.reviews),
                        Tab(text: "favorites"),
                        Tab(text: l10n.settings),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                // Yaptığı Yorumlar Sekmesi
                const Center(child: Text('Kullanıcının yaptığı yorumlar burada listelenecek.')),
                // Beğendiği Yerler Sekmesi
                const Center(child: Text('Kullanıcının favori mekanları burada listelenecek.')),
                // Ayarlar Sekmesi
                _AyarlarListesi(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Ayarlar listesi için ayrı bir widget
class _AyarlarListesi extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text("duzenle"),
          onTap: () {
            // TODO: Profil düzenleme ekranına yönlendir
          },
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(l10n.appTheme),
          onTap: () {
            // TODO: Tema değiştirme diyaloğunu göster
          },
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(l10n.language),
          onTap: () {
            // TODO: Dil değiştirme diyaloğunu göster
          },
        ),
      ],
    );
  }
}

// TabBar'ı SliverAppBar içinde sabit tutmak için yardımcı bir sınıf
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
