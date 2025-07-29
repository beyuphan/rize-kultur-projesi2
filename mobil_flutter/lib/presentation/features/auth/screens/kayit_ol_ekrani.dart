// lib/presentation/features/auth/screens/kayit_ol_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';

// Giriş ekranından kopyaladığımız yardımcı metotları buraya da ekleyebiliriz
// veya ortak bir dosyaya taşıyabiliriz. Şimdilik buraya ekliyorum.
import 'giris_ekrani.dart'; 

class KayitEkrani extends ConsumerStatefulWidget {
  const KayitEkrani({super.key});

  @override
  ConsumerState<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends ConsumerState<KayitEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _kullaniciAdiController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _kayitOl() async {
    // Bu fonksiyonun içindeki mantık zaten doğru, dokunmuyoruz.
    if (_formKey.currentState?.validate() ?? false) {
      final hataMesaji = await ref.read(authProvider.notifier).kayitOl(
            _kullaniciAdiController.text.trim(),
            _emailController.text.trim(),
            _sifreController.text.trim(),
          );

      if (mounted && hataMesaji != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hataMesaji)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // AYNI ARKA PLAN GÖRSELİ
          Image.network(
            'https://celebiakbiyik.wordpress.com/wp-content/uploads/2020/12/hss.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // BAŞLIK
                      Text(
                        l10n.registerTitle,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.registerSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // KULLANICI ADI ALANI
                      TextFormField(
                        controller: _kullaniciAdiController,
                                                style: const TextStyle(color: Colors.white), // <-- YENİ EKLENEN SATIR
                        decoration: _buildInputDecoration(l10n.username, Icons.person_outline),
                        validator: (value) => (value == null || value.trim().isEmpty) ? l10n.usernameValidation : null,
                      ),
                      const SizedBox(height: 20),
                      
                      // E-POSTA ALANI
                      TextFormField(
                        controller: _emailController,
                                                style: const TextStyle(color: Colors.white), // <-- YENİ EKLENEN SATIR
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(l10n.email, Icons.email_outlined),
                        validator: (value) => (value == null || !value.contains('@')) ? l10n.emailValidation : null,
                      ),
                      const SizedBox(height: 20),

                      // ŞİFRE ALANI
                      TextFormField(
                        controller: _sifreController,
                                                style: const TextStyle(color: Colors.white), // <-- YENİ EKLENEN SATIR
                        obscureText: true,
                        decoration: _buildInputDecoration(l10n.password, Icons.lock_outline),
                        validator: (value) => (value == null || value.length < 6) ? l10n.passwordLengthValidation : null,
                      ),
                      const SizedBox(height: 32),

                      // KAYIT OL BUTONU
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authState == AuthStatus.loading  ? null : _kayitOl,
                          child: authState == AuthStatus.loading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(l10n.registerButton),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // GİRİŞ YAP EKRANINA YÖNLENDİRME
                      _buildRichTextNavigation(
                        context: context,
                        text1: "${l10n.alreadyHaveAccount} ",
                        text2: l10n.loginButton,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// --- YARDIMCI METOTLAR ---
// Bu metotları sınıfın dışına veya içine koyabilirsin.

InputDecoration _buildInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.white),
    labelStyle: const TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.black.withOpacity(0.2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

Widget _buildRichTextNavigation({
  required BuildContext context,
  required String text1,
  required String text2,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: onTap,
    child: RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        children: [
          TextSpan(text: text1),
          TextSpan(
            text: text2,
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}