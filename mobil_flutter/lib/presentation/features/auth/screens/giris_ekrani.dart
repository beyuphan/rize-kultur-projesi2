import 'dart:ui'; // BackdropFilter için gerekli
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/features/auth/screens/kayit_ol_ekrani.dart';
// Ortak widget'ları import ediyoruz
import 'package:mobil_flutter/presentation/features/auth/widgets/helper.dart';

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

    if (!mounted) return;

    if (hataMesaji == null) {
    // GİRİŞ BAŞARILI! Hata mesajı yok demektir.
    // Bu ekranı kapat ve alttaki ana ekrana dön.
    Navigator.of(context).pop();
  } else {
    // GİRİŞ BAŞARISIZ! Hata mesajını göster.
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
            'https://res.cloudinary.com/dafoavskw/image/upload/v1754548869/Gemini_Generated_Image_tslm08tslm08tslm_jk3dus.png', // Daha soyut bir görsel
            fit: BoxFit.cover,
          ),
          // BUZLU CAM EFEKTİ
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO
                        Image.asset(
                          'assets/images/logo.png', // Logo dosyanızın yolu
                          height: 80,
                        ),
                        const SizedBox(height: 24),
                        
                        // BAŞLIK
                        Text(
                          l10n.loginTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginSubtitle,
                          style: GoogleFonts.poppins(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // E-POSTA ALANI
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: buildAuthInputDecoration(label: l10n.email, icon: Icons.email_outlined),
                          validator: (value) => (value == null || !value.contains('@')) ? l10n.emailValidation : null,
                        ),
                        const SizedBox(height: 20),

                        // ŞİFRE ALANI
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: buildAuthInputDecoration(label: l10n.password, icon: Icons.lock_outline),
                          validator: (value) => (value == null || value.trim().isEmpty) ? l10n.passwordValidation : null,
                        ),
                        const SizedBox(height: 32),

                        // GİRİŞ YAP BUTONU
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: authState == AuthStatus.loading ? null : _signIn,
                            child: authState == AuthStatus.loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(l10n.loginButton, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // KAYIT OL EKRANINA YÖNLENDİRME
                        buildAuthRichTextNavigation(
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
          ),
        ],
      ),
    );
  }
}