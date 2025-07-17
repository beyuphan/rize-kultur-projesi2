import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/data/services/auth_service.dart'; // Token almak için AuthService'e ihtiyacımız var

class ApiService {
  final String _baseUrl = 'https://rize-kultur-api.onrender.com/api';
  // AuthService'i private bir değişken olarak tutalım.
  // Bu, her seferinde yeni bir instance oluşturmak yerine var olanı kullanmamızı sağlar.
  final AuthService _authService = AuthService();

  // Bu fonksiyon aynı kalabilir, sadece daha güvenli hale getirelim.
  Future<List<MekanModel>> getMekanlar({String kategori = 'categoryAll'}) async {
    String url = '$_baseUrl/mekanlar';
    if (kategori != 'categoryAll') {
      url += '?kategori=$kategori';
    }

    final response = await http.get(Uri.parse(url));

     if (response.statusCode == 200) {
      final List<dynamic> mekanlarJson = json.decode(utf8.decode(response.bodyBytes));
      // DÜZELTME: Artık UnimplementedError yerine yeni factory metodumuzu kullanıyoruz.
      return mekanlarJson.map((json) => MekanModel.fromListJson(json)).toList();
    } else {
      throw Exception('Mekanlar yüklenemedi. Hata Kodu: ${response.statusCode}');
    }
  }

  // BU FONKSİYONU ÇOK DAHA VERİMLİ HALE GETİRİYORUZ
  Future<MekanModel> getMekanDetay(String mekanId) async {
    final url = '$_baseUrl/mekanlar/$mekanId';
    print('Mekan detayı isteniyor: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(utf8.decode(response.bodyBytes));
      // Backend artık mekan ve yorumları tek bir pakette gönderiyor.
      // Bunu parse edecek olan yeni factory metodumuzu kullanıyoruz.
      return MekanModel.fromDetailJson(responseJson);
    } else {
      throw Exception('Mekan detayı yüklenemedi. Hata Kodu: ${response.statusCode}');
    }
  }

  // YENİ FONKSİYON: FAVORİLERE EKLEME/ÇIKARMA
  Future<List<String>> toggleFavorite(String mekanId) async {
    final token = await _authService.tokenAl();
    if (token == null) throw Exception('Favoriye eklemek için giriş yapmalısınız.');
    
    // DİKKAT: Bu route'u biz /api/auth altında tanımlamıştık.
    final url = 'https://rize-kultur-api.onrender.com/api/auth/favorites/$mekanId';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Backend güncel favori listesini [String] olarak dönüyor.
      final List<dynamic> favorilerJson = json.decode(response.body);
      return favorilerJson.map((id) => id.toString()).toList();
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['msg'] ?? 'Favori işlemi başarısız.');
    }
  }


  // YENİ FONKSİYON: YORUM VE/VEYA PUAN EKLEME
  Future<YorumModel> addYorum({
    required String mekanId,
    String? icerik,
    double? puan,
  }) async {
    final token = await _authService.tokenAl();
    if (token == null) throw Exception('Yorum yapmak için giriş yapmalısınız.');

    final body = <String, dynamic>{};
    if (icerik != null && icerik.trim().isNotEmpty) {
      body['icerik'] = icerik.trim();
    }
    if (puan != null) {
      body['puan'] = puan;
    }
    
    if (body.isEmpty) {
      throw Exception('Yorum veya puan girmelisiniz.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/yorumlar/$mekanId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final responseBody = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return YorumModel.fromJson(responseBody);
    } else {
      throw Exception(responseBody['msg'] ?? 'Yorum gönderilemedi');
    }
  }
}