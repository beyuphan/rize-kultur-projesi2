import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';


class AuthService {
  final String _baseUrl = 'http://localhost:3000/api/auth';

  Future<String?> kayitOl(
    String kullaniciAdi,
    String email,
    String sifre,
  ) async {
    print('--- KAYIT OLMA İSTEĞİ BAŞLADI ---');
    try {
      final url = Uri.parse('$_baseUrl/kayit');
      final body = jsonEncode(<String, String>{
        'kullaniciAdi': kullaniciAdi,
        'email': email,
        'sifre': sifre,
      });

      print('İSTEK GÖNDERİLİYOR: $url');
      print('İSTEK BODY: $body');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      print('CEVAP GELDİ: Status Kodu = ${response.statusCode}');
      print('CEVAP BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        await _tokenKaydet(token);
        print('Token başarıyla kaydedildi.');
        print('--- KAYIT OLMA İSTEĞİ BAŞARIYLA BİTTİ ---');
        return null; // Başarılı, hata mesajı yok.
      } else {
        final responseBody = jsonDecode(response.body);
        final hataMesaji =
            responseBody['msg'] ?? 'Bilinmeyen bir sunucu hatası.';
        print('HATA MESAJI (from server): $hataMesaji');
        return hataMesaji;
      }
    } catch (e) {
      print('!!! HATA YAKALANDI (catch bloğu) !!!');
      print(e.toString());
      print('--- KAYIT OLMA İSTEĞİ HATAYLA BİTTİ ---');
      return 'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı ve sunucunun çalıştığını kontrol edin.';
    }
  }

  Future<String?> girisYap(String email, String sifre) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/giris'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email, 'sifre': sifre}),
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

  Future<UserModel> updateProfile({
    String? kullaniciAdi,
    XFile? profilFoto, // image_picker'dan gelen dosya
  }) async {
    final token = await tokenAl();
    if (token == null) throw Exception('Token bulunamadı.');

    final url = Uri.parse('$_baseUrl/profile');
    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Kullanıcı adı doluysa isteğe ekle
    if (kullaniciAdi != null && kullaniciAdi.isNotEmpty) {
      request.fields['kullaniciAdi'] = kullaniciAdi;
    }
    
    // Profil fotoğrafı seçildiyse isteğe ekle
    if (profilFoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilFoto', // Backend'de beklenen alan adı
          profilFoto.path,
          contentType: MediaType('image', 'jpeg'), // veya png
        ),
      );
    }
    
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromJson(responseBody);
      } else {
        throw Exception('Profil güncellenemedi: ${responseBody['msg']}');
      }
    } catch (e) {
      throw Exception('Profil güncellenirken bir hata oluştu: $e');
    }
  }

  // YENİ ŞİFRE DEĞİŞTİRME SERVİSİ
  Future<String> changePassword({
    required String eskiSifre,
    required String yeniSifre,
  }) async {
    final token = await tokenAl();
    if (token == null) throw Exception('Token bulunamadı.');

    final url = Uri.parse('$_baseUrl/change-password');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'eskiSifre': eskiSifre,
        'yeniSifre': yeniSifre,
      }),
    );
    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return responseBody['msg']; // Başarı mesajı
    } else {
      throw Exception(responseBody['msg']); // Hata mesajı
    }
  }

 
  Future<UserModel> getMyProfile() async {
    try {
      // Cihazda saklanan token'ı al
      final token = await tokenAl();
      if (token == null) {
        throw Exception('Giriş yapılmamış.');
      }

      // Backend'deki profil endpoint'inize token ile birlikte GET isteği atın
      // TODO: '/me' veya '/profile' gibi kendi endpoint'inizi buraya yazın
      final url = Uri.parse('$_baseUrl/me');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Token'ı header'a ekliyoruz
        },
      );

      if (response.statusCode == 200) {
        // Gelen JSON verisinden UserModel oluştur ve döndür
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        // Sunucudan hata geldiyse
        final body = jsonDecode(response.body);
        throw Exception('Profil bilgileri alınamadı: ${body['msg']}');
      }
    } catch (e) {
      // Genel bir hata durumunda
      throw Exception('Profil alınırken bir hata oluştu: $e');
    }
  }
}
