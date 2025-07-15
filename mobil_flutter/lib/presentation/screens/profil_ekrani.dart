import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
// --- KULLANICI MODELİ ---
// Bu sınıfın lib/data/models/user_model.dart dosyasında olduğundan emin olun.

// --- PROVIDER TANIMI ---
// Giriş yapmış kullanıcının profilini getiren provider.
final userProfileProvider = FutureProvider.autoDispose<UserModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  final user = authService.getMyProfile();
  return Future.value(user);
});

// --- WIDGET ---
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userProfileProvider'ı dinliyoruz.
    final userProfileAsyncValue = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              ref.read(authProvider.notifier).cikisYap();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: userProfileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          // Hata mesajını daha detaylı göstermek için
          debugPrintStack(stackTrace: stack);
          return Center(
            child: Text(
              'Profil bilgileri yüklenemedi:\n$err',
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (user) {
          // Kullanıcı verisi başarıyla geldi, şimdi arayüzü oluşturalım.
          return RefreshIndicator(
            onRefresh: () => ref.refresh(userProfileProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.kullaniciAdi,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Profili Düzenle'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bu özellik yakında eklenecektir.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
