import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_flutter/data/models/mekan_model.dart';

class ApiService {
  // Sunucumuzun ana adresi.
  final String _baseUrl = 'https://rize-kultur-api.onrender.com/api';

  // Tüm mekanları getiren fonksiyon
  Future<List<Mekan>> getMekanlar({String kategori = 'categoryAll'}) async {
    // URL'yi başlangıçta ana adres olarak ayarlıyoruz.
    String url = '$_baseUrl/mekanlar';

    // Eğer gelen kategori 'Tümü' değilse, URL'nin sonuna sorgu parametresini ekliyoruz.
    if (kategori != 'categoryAll') {
      url += '?kategori=$kategori';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Gelen cevabı UTF-8 olarak çözüyoruz, Türkçe karakter sorunu olmasın.
      final List<dynamic> mekanlarJson = json.decode(
        utf8.decode(response.bodyBytes),
      );
      // Her bir JSON objesini Mekan modeline dönüştürüp bir liste yapıyoruz.
      return mekanlarJson.map((json) => Mekan.fromJson(json)).toList();
    } else {
      throw Exception(
        'Mekanlar yüklenemedi. Hata Kodu: ${response.statusCode}',
      );
    }
  }

  Future<Mekan> getMekanDetay(String mekanId) async {
    final url = '$_baseUrl/mekanlar/$mekanId';
    print('Mekan detayı isteniyor: $url'); // Debug için

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Gelen cevap tek bir JSON nesnesi olduğu için direkt decode ediyoruz.
      final Map<String, dynamic> mekanJson = json.decode(
        utf8.decode(response.bodyBytes),
      );
      // JSON'ı Mekan modeline dönüştürüp döndürüyoruz.
      return Mekan.fromJson(mekanJson);
    } else {
      throw Exception(
        'Mekan detayı yüklenemedi. Hata Kodu: ${response.statusCode}',
      );
    }
  }
}
