// lib/presentation/screens/profil/profil_sayfasi.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/screens/ayarlar_ekrani.dart';
import 'package:mobil_flutter/presentation/widgets/sliver_tab_bar_delegate.dart';
import 'widgets/favoriler_tab.dart';
import 'widgets/istatistik_widget.dart';
import 'widgets/yorumlar_tab.dart';

// DÜZELTME: Sınıf adı daha genel ve dinamik ID alabilen bir yapıya dönüştü.
class ProfilSayfasi extends ConsumerWidget {
  final String? userId;
  const ProfilSayfasi({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedInUser = ref.watch(userProfileProvider).value;
    final isMyProfile = userId == null || userId == loggedInUser?.id;

    final providerToWatch = isMyProfile ? userProfileProvider : publicUserProfileProvider(userId!);
    final userProfileAsync = ref.watch(providerToWatch);
    
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Profil yüklenemedi: $err')),
        data: (kullanici) {
          final favorilerData = isMyProfile ? ref.watch(favoriMekanlarProvider).value ?? [] : <MekanModel>[];

          return DefaultTabController(
            length: isMyProfile ? 2 : 1,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    floating: false,
                    backgroundColor: theme.colorScheme.surface,
                    iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                    title: innerBoxIsScrolled ? Text(kullanici.kullaniciAdi) : null,
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary.withOpacity(0.6), theme.colorScheme.surface],
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
                                  backgroundImage: (kullanici.profilFotoUrl != null && kullanici.profilFotoUrl!.isNotEmpty)
                                      ? NetworkImage(kullanici.profilFotoUrl!)
                                      : null,
                                  child: (kullanici.profilFotoUrl == null || kullanici.profilFotoUrl!.isEmpty)
                                      ? Icon(Icons.person, size: 50)
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(kullanici.kullaniciAdi, style: theme.textTheme.headlineSmall),
                                const SizedBox(height: 8),
                                if (isMyProfile) Text(kullanici.email, style: theme.textTheme.bodyLarge),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    StatWidget(count: kullanici.yorumlar.length, label: l10n.reviews),
                                    if (isMyProfile) ...[
                                      const SizedBox(width: 32),
                                      StatWidget(count: kullanici.favoriMekanlar.length, label: l10n.favorites),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: isMyProfile ? [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AyarlarEkrani())),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => ref.read(authProvider.notifier).cikisYap(),
                      ),
                    ] : null,
                  ),
                  SliverPersistentHeader(
                    delegate: SliverAppBarDelegate(
                      TabBar(
                        tabs: isMyProfile
                            ? [Tab(text: l10n.reviews), Tab(text: l10n.favorites)]
                            : [Tab(text: l10n.reviews)],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: isMyProfile
                    ? [YorumlarTab(yorumlar: kullanici.yorumlar), FavorilerTab(favoriMekanlar: favorilerData)]
                    : [YorumlarTab(yorumlar: kullanici.yorumlar)],
              ),
            ),
          );
        },
      ),
    );
  }
}