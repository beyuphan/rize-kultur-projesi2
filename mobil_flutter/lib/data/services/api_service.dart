import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/data/services/auth_service.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:mobil_flutter/data/models/rota_model.dart';


// YENİ YARDIMCI SINIF: API'den gelen cevabı (mekan listesi + sayfa bilgisi) bir arada tutar.
class MekanlarResponse {
  final List<MekanModel> mekanlar;
  final int toplamSayfa;
  final int mevcutSayfa;

  MekanlarResponse({
    required this.mekanlar,
    required this.toplamSayfa,
    required this.mevcutSayfa,
  });
}

class ApiService {
  final String _baseUrl = 'https://rize-kultur-api.onrender.com/api';
  final AuthService _authService = AuthService();

  // --- ESKİ getMekanlar FONKSİYONUNUN YERİNE GELEN GÜNCELLENMİŞ VERSİYON ---
  Future<MekanlarResponse> getMekanlar({
    String? kategori,
    String? aramaSorgusu,
    String? sortBy,
    int sayfa = 1, // Sayfalama için 'page' parametresi
      int? limit, // <-- YENİ: limit parametresini ekle
  }) async {
    // 1. Parametreler için boş bir Map oluştur.
    final Map<String, String> queryParameters = {
      'page': sayfa.toString(),
    };

    // 2. Sadece dolu olan parametreleri Map'e ekle.
    if (kategori != null && kategori != 'categoryAll') {
      queryParameters['kategori'] = kategori;
    }
    if (aramaSorgusu != null && aramaSorgusu.isNotEmpty) {
      queryParameters['arama'] = aramaSorgusu;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParameters['sortBy'] = sortBy;
    }

    // 3. Uri'yi bu Map ile güvenli bir şekilde oluştur.
    final uri = Uri.https(
      'rize-kultur-api.onrender.com',
      '/api/mekanlar',
      queryParameters,
    );

    debugPrint('API İsteği Gönderiliyor: $uri'); // Hata ayıklama için isteği yazdır

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Sunucudan boş yanıt geldi.');
      }

      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      final List<dynamic> mekanlarJson = responseJson['mekanlar'];
      final mekanlarListesi = mekanlarJson.map((json) => MekanModel.fromListJson(json)).toList();

      return MekanlarResponse(
        mekanlar: mekanlarListesi,
        toplamSayfa: responseJson['toplamSayfa'] ?? 1,
        mevcutSayfa: responseJson['mevcutSayfa'] ?? 1,
      );
    } else {
      throw Exception('Mekanlar yüklenemedi. Hata Kodu: ${response.statusCode}');
    }
  }
  // --- GÜNCELLEME BİTTİ ---

  //
  // --- DİĞER FONKSİYONLARIN AYNI ŞEKİLDE KALIYOR ---
  //
  
  Future<MekanModel> getMekanDetay(String mekanId) async {
    final url = '$_baseUrl/mekanlar/$mekanId';
    debugPrint('Mekan detayı isteniyor: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(utf8.decode(response.bodyBytes));
      return MekanModel.fromDetailJson(responseJson);
    } else {
      throw Exception('Mekan detayı yüklenemedi. Hata Kodu: ${response.statusCode}');
    }
  }

  Future<List<String>> toggleFavorite(String mekanId) async {
    final token = await _authService.tokenAl();
    if (token == null) throw Exception('Favoriye eklemek için giriş yapmalısınız.');
    
    final url = 'https://rize-kultur-api.onrender.com/api/auth/favorites/$mekanId';

    final response = await http.put(
      Uri.parse(url),
      headers: { 'Authorization': 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      final List<dynamic> favorilerJson = json.decode(response.body);
      return favorilerJson.map((id) => id.toString()).toList();
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['msg'] ?? 'Favori işlemi başarısız.');
    }
  }

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

  Future<List<MekanModel>> getYakindakiMekanlar({
    required double enlem,
    required double boylam,
    double mesafe = 500000,
  }) async {
    // Bu fonksiyon da Uri.https kullanacak şekilde güncellenebilir ama şimdilik bırakıyorum.
    final url = '$_baseUrl/mekanlar/yakinimdakiler?enlem=$enlem&boylam=$boylam&mesafe=${mesafe.toInt()}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> mekanlarJson = json.decode(utf8.decode(response.bodyBytes));
      return mekanlarJson.map((json) => MekanModel.fromListJson(json)).toList();
    } else {
      throw Exception('Yakındaki mekanlar yüklenemedi.');
    }
  }

  Future<List<YorumModel>> getMyYorumlar() async {
    final token = await _authService.tokenAl();
    if (token == null) throw Exception('Yorumları getirmek için giriş yapmalısınız.');
    
    final url = '$_baseUrl/yorumlar/kullanici/me';
    final response = await http.get(
      Uri.parse(url),
      headers: { 'Authorization': 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      final List<dynamic> yorumlarJson = json.decode(utf8.decode(response.bodyBytes));
      return yorumlarJson.map((json) => YorumModel.fromJson(json)).toList();
    } else {
      throw Exception('Yorumlar yüklenemedi.');
    }
  }

  Future<List<MekanModel>> getMekanlarByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    final url = '$_baseUrl/mekanlar/by-ids';
    final response = await http.post(
      Uri.parse(url),
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: jsonEncode({ 'ids': ids }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> mekanlarJson = json.decode(utf8.decode(response.bodyBytes));
      return mekanlarJson.map((json) => MekanModel.fromListJson(json)).toList();
    } else {
      throw Exception('Favori mekanlar yüklenemedi.');
    }
  }

  Future<UserModel> getPublicUserProfile(String userId) async {
    final url = '$_baseUrl/users/$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final userJson = responseJson['kullanici'];
      final yorumlarJson = responseJson['yorumlar'] as List;
      return UserModel.fromPublicProfileJson(userJson, yorumlarJson);
    } else {
      throw Exception('Kullanıcı profili yüklenemedi. Hata Kodu: ${response.statusCode}');
    }
  }

 // Tüm rotaların listesini çeker
  Future<List<RotaModel>> getRotalar() async {
    final uri = Uri.https('rize-kultur-api.onrender.com', '/api/rotalar');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      // Her bir JSON objesini RotaModel.fromJson ile RotaModel'e çevirir
      return jsonList.map((json) => RotaModel.fromJson(json)).toList();
    } else {
      throw Exception('Rotalar yüklenemedi.');
    }
  }

  // ID'ye göre tek bir rotanın tüm detaylarını çeker
  Future<RotaModel> getRotaDetay(String rotaId) async {
    final uri = Uri.https('rize-kultur-api.onrender.com', '/api/rotalar/$rotaId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(utf8.decode(response.bodyBytes));
      // JSON objesini RotaModel.fromDetailJson ile RotaModel'e çevirir
      return RotaModel.fromDetailJson(jsonMap);
    } else {
      throw Exception('Rota detayı yüklenemedi.');
    }
  }
}