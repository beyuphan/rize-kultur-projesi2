import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/features/auth/screens/kayit_ol_ekrani.dart'; // Kayıt Ol ekranını import ediyoruz

// 1. Widget'ı ConsumerStatefulWidget olarak değiştiriyoruz
class GirisEkrani extends ConsumerStatefulWidget {
  const GirisEkrani({super.key});

  @override
  ConsumerState<GirisEkrani> createState() => _GirisEkraniState();
}

// 2. State sınıfını ConsumerState olarak değiştiriyoruz
class _GirisEkraniState extends ConsumerState<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // 3. Giriş yapma fonksiyonunu AuthProvider'ı kullanacak şekilde güncelliyoruz
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // AuthNotifier'daki girisYap fonksiyonunu çağırıyoruz
    final hataMesaji = await ref
        .read(authProvider.notifier)
        .girisYap(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    // Eğer bir hata mesajı döndüyse, kullanıcıya göster
    if (hataMesaji != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hataMesaji), backgroundColor: Colors.red),
      );
    }
    // Başarılı olursa, AuthYonlendirici zaten bizi ana ekrana atacaktır.
    // Bu yüzden burada bir navigasyon koduna gerek yok.

    // İşlem bitince yükleniyor durumunu bitir
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giriş Yap")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // E-posta alanı
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Lütfen e-posta adresinizi girin.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Şifre alanı
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Lütfen şifrenizi girin.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Giriş Yap butonu
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Giriş Yap"),
                  ),
                ),
                const SizedBox(height: 16),
                // Kayıt Ol ekranına yönlendirme butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabınız yok mu?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const KayitEkrani(),
                          ),
                        );
                      },
                      child: const Text("Kayıt Ol"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
