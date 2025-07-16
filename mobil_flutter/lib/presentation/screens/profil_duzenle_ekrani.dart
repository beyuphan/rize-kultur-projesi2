// lib/presentation/screens/profil_duzenle_ekrani.dart (YENİ DOSYA)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart'; // Ana provider'lar
import 'package:mobil_flutter/presentation/screens/profil_ekrani.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

// --- Yeni StateNotifier ve Provider ---
// Sadece profil güncelleme işleminin durumunu yönetmek için (loading, error, success)
final profileUpdateProvider = StateNotifierProvider.autoDispose<ProfileUpdateNotifier, AsyncValue<void>>((ref) {
  return ProfileUpdateNotifier(ref);
});

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileUpdateNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> updateProfile({required String kullaniciAdi, required String email}) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfile(kullaniciAdi: kullaniciAdi, email: email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
// --- Bitiş: Yeni StateNotifier ve Provider ---

class ProfilDuzenleEkrani extends ConsumerStatefulWidget {
  final UserModel mevcutKullanici;

  const ProfilDuzenleEkrani({
    super.key,
    required this.mevcutKullanici,
  });

  @override
  ConsumerState<ProfilDuzenleEkrani> createState() => _ProfilDuzenleEkraniState();
}

class _ProfilDuzenleEkraniState extends ConsumerState<ProfilDuzenleEkrani> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kullaniciAdiController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _kullaniciAdiController = TextEditingController(text: widget.mevcutKullanici.kullaniciAdi);
    _emailController = TextEditingController(text: widget.mevcutKullanici.email);
  }

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(profileUpdateProvider.notifier).updateProfile(
            kullaniciAdi: _kullaniciAdiController.text,
            email: _emailController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Güncelleme işleminin durumunu dinle
    ref.listen<AsyncValue<void>>(profileUpdateProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${state.error}')),
        );
      }
      if (state is AsyncData && !state.isLoading) {
        // Başarılı olunca profil verisini yenile ve geri git
        ref.invalidate(userProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
        );
        Navigator.of(context).pop();
      }
    });

    final updateState = ref.watch(profileUpdateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kullaniciAdiController,
                decoration: InputDecoration(
                  labelText: l10n.username,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.usernameCannotBeEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return l10n.enterAValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium,
                ),
                // Yükleme durumundaysa butonu devre dışı bırak
                onPressed: updateState.isLoading ? null : _kaydet,
                child: updateState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}