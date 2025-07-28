// lib/presentation/features/auth/screens/giris_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/features/auth/screens/kayit_ol_ekrani.dart';

class GirisEkrani extends ConsumerStatefulWidget {
  const GirisEkrani({super.key});

  @override
  ConsumerState<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends ConsumerState<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // Bu fonksiyonun içindeki mantık zaten doğru, dokunmuyoruz.
    if (!_formKey.currentState!.validate()) return;

    final hataMesaji = await ref.read(authProvider.notifier).girisYap(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (hataMesaji != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hataMesaji), backgroundColor: Colors.red),
      );
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
          // ARKA PLAN GÖRSELİ
          Image.network(
            'https://celebiakbiyik.wordpress.com/wp-content/uploads/2020/12/hss.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5), // Resmi karart
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
                        l10n.loginTitle,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 48),

                      // E-POSTA ALANI
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                                                style: const TextStyle(color: Colors.white), // <-- YENİ EKLENEN SATIR
                        decoration: _buildInputDecoration(l10n.email, Icons.email_outlined),
                        validator: (value) => (value == null || !value.contains('@')) ? l10n.emailValidation : null,
                      ),
                      const SizedBox(height: 20),

                      // ŞİFRE ALANI
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                                                style: const TextStyle(color: Colors.white), // <-- YENİ EKLENEN SATIR
                        decoration: _buildInputDecoration(l10n.password, Icons.lock_outline),
                        validator: (value) => (value == null || value.trim().isEmpty) ? l10n.passwordValidation : null,
                      ),
                      const SizedBox(height: 32),

                      // GİRİŞ YAP BUTONU
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authState == AuthStatus.loading ? null : _signIn,
                          child: authState == AuthStatus.loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(l10n.loginButton),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // KAYIT OL EKRANINA YÖNLENDİRME
                      _buildRichTextNavigation(
                        context: context,
                        text1: "${l10n.dontHaveAccount} ",
                        text2: l10n.registerButton,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const KayitEkrani()),
                        ),
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