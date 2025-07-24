import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/widgets/sliver_tab_bar_delegate.dart';
import 'package:mobil_flutter/presentation/screens/ayarlar_ekrani.dart';
import 'widgets/yorumlar_tab.dart';
import 'widgets/favoriler_tab.dart';
import 'widgets/istatistik_widget.dart';

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
                    expandedHeight: 300.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: theme.colorScheme.surface,
                    iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                    title: innerBoxIsScrolled ? Text(kullanici.kullaniciAdi) : null,
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.6),
                              theme.colorScheme.surface,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  backgroundImage: (kullanici.profilFotoUrl != null && kullanici.profilFotoUrl!.isNotEmpty)
                                      ? NetworkImage(kullanici.profilFotoUrl!)
                                      : null,
                                  child: (kullanici.profilFotoUrl == null || kullanici.profilFotoUrl!.isEmpty)
                                      ? Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimaryContainer)
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  kullanici.kullaniciAdi,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  kullanici.email,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Consumer(builder: (context, ref, _) {
                                      final yorumlarAsync = ref.watch(kullaniciYorumlariProvider);
                                      return yorumlarAsync.when(
                                        data: (yorumlar) => StatWidget(count: yorumlar.length, label: l10n.reviews),
                                        loading: () => StatWidget(count: 0, label: l10n.reviews),
                                        error: (e,s) => StatWidget(count: 0, label: l10n.reviews),
                                      );
                                    }),
                                    const SizedBox(width: 32),
                                    StatWidget(count: kullanici.favoriMekanlar.length, label: l10n.favorites),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
                    delegate: SliverAppBarDelegate(
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
              body: const TabBarView(
                children: [
                  YorumlarTab(),
                  FavorilerTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


