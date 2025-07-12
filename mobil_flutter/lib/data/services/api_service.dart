import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_flutter/data/models/mekan_model.dart';

class ApiService {
  // Sunucumuzun ana adresi.
  final String _baseUrl = 'http://192.168.1.149:3000/api';

  // Tüm mekanları getiren fonksiyon
  Future<List<Mekan>> getMekanlar() async { // Burada 'Mekan' tipini kullanıyorsun
    final response = await http.get(Uri.parse('$_baseUrl/mekanlar'));

    if (response.statusCode == 200) {
      // Gelen cevabı UTF-8 olarak çözüyoruz, Türkçe karakter sorunu olmasın.
      final List<dynamic> mekanlarJson = json.decode(utf8.decode(response.bodyBytes));
      // Her bir JSON objesini Mekan modeline dönüştürüp bir liste yapıyoruz.
      return mekanlarJson.map((json) => Mekan.fromJson(json)).toList(); // Burada da 'Mekan.fromJson' kullanıyorsun
    } else {
      throw Exception('Mekanlar yüklenemedi');
    }
  }

  // TODO: Tek bir mekanı, yorumları vb. getiren fonksiyonlar buraya eklenecek.
}
