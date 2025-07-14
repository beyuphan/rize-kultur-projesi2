import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/services/auth_service.dart';

// 1. Auth durumunu tutacak olan enum
enum AuthStatus { bilinmiyor, girisYapilmadi, girisYapildi }

// 2. Auth durumunu yöneten StateNotifier
class AuthNotifier extends StateNotifier<AuthStatus> {
  AuthNotifier(this.ref) : super(AuthStatus.bilinmiyor) {
    _girisDurumunuKontrolEt();
  }

  final Ref ref;
  // AuthService'i başka bir provider'dan okuyarak bağımlılıkları yönetiyoruz
  late final AuthService _authService = ref.read(authServiceProvider);

  Future<void> _girisDurumunuKontrolEt() async {
    final token = await _authService.tokenAl();
    if (token != null) {
      state = AuthStatus.girisYapildi;
    } else {
      state = AuthStatus.girisYapilmadi;
    }
  }

  Future<String?> kayitOl(
    String kullaniciAdi,
    String email,
    String sifre,
  ) async {
    final hataMesaji = await _authService.kayitOl(kullaniciAdi, email, sifre);
    if (hataMesaji == null) {
      state = AuthStatus.girisYapildi; // Durumu güncelle
    }
    return hataMesaji;
  }

  Future<String?> girisYap(String email, String sifre) async {
    final hataMesaji = await _authService.girisYap(email, sifre);
    if (hataMesaji == null) {
      state = AuthStatus.girisYapildi; // Durumu güncelle
    }
    return hataMesaji;
  }

  Future<void> cikisYap() async {
    await _authService.cikisYap();
    state = AuthStatus.girisYapilmadi;
  }
}

// 3. AuthService için basit bir Provider (tek bir instance oluşmasını sağlar)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 4. AuthNotifier'ı uygulama genelinde erişilebilir kılan StateNotifierProvider
final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier(ref);
});
