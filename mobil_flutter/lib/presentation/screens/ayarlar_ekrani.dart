
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/common/theme/app_themes.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/main.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/screens/profil_duzenle_ekrani.dart';

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
