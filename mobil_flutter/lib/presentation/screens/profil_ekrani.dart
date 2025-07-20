import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/common/theme/app_themes.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/main.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/screens/profil_duzenle_ekrani.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';


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
                                        data: (yorumlar) => _StatWidget(count: yorumlar.length, label: l10n.reviews),
                                        loading: () => _StatWidget(count: 0, label: l10n.reviews),
                                        error: (e,s) => _StatWidget(count: 0, label: l10n.reviews),
                                      );
                                    }),
                                    const SizedBox(width: 32),
                                    _StatWidget(count: kullanici.favoriMekanlar.length, label: l10n.favorites),
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
                children: const [
                  _DinamikYorumlarListesi(),
                  _DinamikFavorilerListesi(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DinamikYorumlarListesi extends ConsumerWidget {
  const _DinamikYorumlarListesi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yorumlarAsync = ref.watch(kullaniciYorumlariProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    return yorumlarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Yorumlar yüklenemedi: $err')),
      data: (yorumlar) => yorumlar.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noCommentsYet))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: yorumlar.length,
              itemBuilder: (context, index) {
                final yorum = yorumlar[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      langCode == 'tr' ? yorum.mekan?.isim.tr ?? 'Mekan Silinmiş' : yorum.mekan?.isim.en ?? 'Deleted Place',
                    ),
                    subtitle: Text(
                      yorum.icerik ?? "(Sadece puan verildi)",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: yorum.puan != null
                        ? Text("★ ${yorum.puan!.toStringAsFixed(1)}", style: const TextStyle(fontSize: 16, color: Colors.amber))
                        : null,
                    onTap: () {
                      if (yorum.mekan != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MekanDetayEkrani(mekanId: yorum.mekan!.id)),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _DinamikFavorilerListesi extends ConsumerWidget {
  const _DinamikFavorilerListesi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorilerAsync = ref.watch(favoriMekanlarProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return favorilerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Favoriler yüklenemedi: $err')),
      data: (mekanlar) => mekanlar.isEmpty
          ? Center(child: Text(l10n.noFavoritesYet))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: mekanlar.length,
              itemBuilder: (context, index) {
                final mekan = mekanlar[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MekanDetayEkrani(mekanId: mekan.id)),
                    );
                  },
                  child: MekanKarti(
                    isim: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                    kategori: mekan.kategori,
                    puan: mekan.ortalamaPuan,
                    imageUrl: mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : null,
                  ),
                );
              },
            ),
    );
  }
}

// Profildeki istatistikleri göstermek için küçük bir widget
class _StatWidget extends StatelessWidget {
  final int count;
  final String label;
  const _StatWidget({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// --- AYARLAR EKRANI ---
class AyarlarEkrani extends ConsumerWidget {
  const AyarlarEkrani({super.key});

  void _temaSecimiGoster(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mevcutTema = ref.watch(themeProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectThemeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppTheme>(
                title: Text(l10n.themeFirtinaYesili),
                value: AppTheme.firtinaYesili,
                groupValue: mevcutTema,
                onChanged: (AppTheme? value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).state = value;
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<AppTheme>(
                title: Text(l10n.themeKackarSisi),
                value: AppTheme.kackarSisi,
                groupValue: mevcutTema,
                onChanged: (AppTheme? value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).state = value;
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _dilSecimiGoster(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mevcutDil = ref.watch(localeProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectLanguageTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: Text(l10n.turkish),
                value: const Locale('tr'),
                groupValue: mevcutDil,
                onChanged: (Locale? value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).state = value;
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<Locale>(
                title: Text(l10n.english),
                value: const Locale('en'),
                groupValue: mevcutDil,
                onChanged: (Locale? value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).state = value;
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userProfileAsync = ref.watch(userProfileProvider);
    final mevcutTema = ref.watch(themeProvider);
    final mevcutDil = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, "HESAP"),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.editProfile),
                  onTap: () {
                    if (userProfileAsync.hasValue && !userProfileAsync.isLoading) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfilDuzenleEkrani(
                            mevcutKullanici: userProfileAsync.value!,
                          ),
                        ),
                      );
                    }
                  },
                  enabled: userProfileAsync.hasValue,
                ),
              ],
            ),
          ),
          _buildSectionHeader(context, "UYGULAMA"),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n.appTheme),
                  subtitle: Text(
                    mevcutTema == AppTheme.firtinaYesili ? l10n.themeFirtinaYesili : l10n.themeKackarSisi,
                  ),
                  onTap: () => _temaSecimiGoster(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.language),
                  subtitle: Text(
                    mevcutDil.languageCode == 'tr' ? l10n.turkish : l10n.english,
                  ),
                  onTap: () => _dilSecimiGoster(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TabBar'ı SliverAppBar içinde sabit tutmak için yardımcı sınıf
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}