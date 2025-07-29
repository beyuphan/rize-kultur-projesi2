// lib/presentation/features/auth/screens/misafir_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/features/auth/screens/giris_ekrani.dart';
import 'package:mobil_flutter/presentation/features/auth/screens/kayit_ol_ekrani.dart';
import 'package:mobil_flutter/presentation/features/settings/screens/ayarlar_ekrani_misafir.dart';

class MisafirEkrani extends ConsumerWidget {
  const MisafirEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.explore,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.guestPromptTitle, // "Tüm özellikleri keşfedin!"
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.guestPromptSubtitle, // "Mekanları favorilere eklemek, yorum ve puan bırakmak için bir hesap oluşturun."
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GirisEkrani())),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(l10n.loginButton),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KayitEkrani())),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(l10n.registerButton),
            ),
            const SizedBox(height: 48),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AyarlarEkraniMisafir())),
            )
          ],
        ),
      ),
    );
  }
}