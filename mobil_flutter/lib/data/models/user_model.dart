import 'package:mobil_flutter/data/models/yorum_model.dart';

class UserModel {
  final String id;
  final String kullaniciAdi;
  final String email;
  final String? profilFotoUrl; // YENİ: Null olabilir
  final List<String> favoriMekanlar; // FAVORİ LİSTESİ ALANI
    final List<YorumModel> yorumlar; // Bu alanı ekle

  UserModel({
    required this.id,
    required this.kullaniciAdi,
    required this.email,
    this.profilFotoUrl,
        required this.favoriMekanlar, // CONSTRUCTOR'A EKLENDİ
            this.yorumlar = const [], // Constructor'a ekle
  });

  // Backend'den gelen JSON verisinden model oluşturmak için
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '', // Backend'den gelen ID'ye göre ayarlayın
      kullaniciAdi: json['kullaniciAdi'] ?? 'İsimsiz',
      email: json['email'] ?? 'E-posta yok',
      profilFotoUrl: json['profilFotoUrl'], // YENİ
            favoriMekanlar: List<String>.from(json['favoriMekanlar'] ?? []),
      yorumlar: const [],     );
  }

  // YENİ VE EKSİK OLAN METOT: Halka açık profil verisini parse eder
  factory UserModel.fromPublicProfileJson(Map<String, dynamic> userJson, List<dynamic> yorumlarJson) {
    return UserModel(
      id: userJson['_id'],
      kullaniciAdi: userJson['kullaniciAdi'],
      profilFotoUrl: userJson['profilFotoUrl'],
      // Halka açık profilde bu bilgiler olmadığı için varsayılan değerler atanır
      email: '',
      favoriMekanlar: [],
      yorumlar: yorumlarJson.map((json) => YorumModel.fromJson(json)).toList(),
    );
  }

  // BU METODU SINIFIN İÇİNE EKLE
  UserModel copyWith({
    String? id,
    String? kullaniciAdi,
    String? email,
    String? profilFotoUrl,
    List<String>? favoriMekanlar,
  }) {
    return UserModel(
      id: id ?? this.id,
      kullaniciAdi: kullaniciAdi ?? this.kullaniciAdi,
      email: email ?? this.email,
      profilFotoUrl: profilFotoUrl ?? this.profilFotoUrl,
      favoriMekanlar: favoriMekanlar ?? this.favoriMekanlar,
    );
  }
}