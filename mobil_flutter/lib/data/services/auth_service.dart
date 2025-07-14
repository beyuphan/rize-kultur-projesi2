import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:3000/api/auth';

  Future<String?> kayitOl(String kullaniciAdi, String email, String sifre) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/kayit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'kullaniciAdi': kullaniciAdi,
          'email': email,
          'sifre': sifre,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        await _tokenKaydet(token);
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['msg'] ?? 'Bilinmeyen bir hata oluştu.';
      }
    } catch (e) {
      return 'Sunucuya bağlanılamadı: $e';
    }
  }

  Future<String?> girisYap(String email, String sifre) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/giris'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'sifre': sifre,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        await _tokenKaydet(token);
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['msg'] ?? 'Geçersiz kullanıcı bilgileri.';
      }
    } catch (e) {
      return 'Sunucuya bağlanılamadı: $e';
    }
  }

  Future<void> cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> _tokenKaydet(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> tokenAl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
