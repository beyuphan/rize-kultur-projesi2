import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
// Ortak widget'ları import ediyoruz
import 'package:mobil_flutter/presentation/features/auth/widgets/helper.dart';

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
                        
                        Text(
                          l10n.registerTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.registerSubtitle,
                          style: GoogleFonts.poppins(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // KULLANICI ADI ALANI
                        TextFormField(
                          controller: _kullaniciAdiController,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: buildAuthInputDecoration(label: l10n.username, icon: Icons.person_outline),
                          validator: (value) => (value == null || value.trim().isEmpty) ? l10n.usernameValidation : null,
                        ),
                        const SizedBox(height: 20),
                        
                        // E-POSTA ALANI
                        TextFormField(
                          controller: _emailController,
                           style: GoogleFonts.poppins(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: buildAuthInputDecoration(label: l10n.email, icon: Icons.email_outlined),
                          validator: (value) => (value == null || !value.contains('@')) ? l10n.emailValidation : null,
                        ),
                        const SizedBox(height: 20),

                        // ŞİFRE ALANI
                        TextFormField(
                          controller: _sifreController,
                           style: GoogleFonts.poppins(color: Colors.white),
                          obscureText: true,
                          decoration: buildAuthInputDecoration(label: l10n.password, icon: Icons.lock_outline),
                          validator: (value) => (value == null || value.length < 6) ? l10n.passwordLengthValidation : null,
                        ),
                        const SizedBox(height: 32),

                        // KAYIT OL BUTONU
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: authState == AuthStatus.loading ? null : _kayitOl,
                            child: authState == AuthStatus.loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(l10n.registerButton, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // GİRİŞ YAP EKRANINA YÖNLENDİRME
                        buildAuthRichTextNavigation(
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
          ),
        ],
      ),
    );
  }
}