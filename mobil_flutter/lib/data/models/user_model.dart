class UserModel {
  final String id;
  final String kullaniciAdi;
  final String email;
  final String? profilFotoUrl; // YENİ: Null olabilir
  final List<String> favoriMekanlar; // FAVORİ LİSTESİ ALANI

  UserModel({
    required this.id,
    required this.kullaniciAdi,
    required this.email,
    this.profilFotoUrl,
        required this.favoriMekanlar, // CONSTRUCTOR'A EKLENDİ
  });

  // Backend'den gelen JSON verisinden model oluşturmak için
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '', // Backend'den gelen ID'ye göre ayarlayın
      kullaniciAdi: json['kullaniciAdi'] ?? 'İsimsiz',
      email: json['email'] ?? 'E-posta yok',
      profilFotoUrl: json['profilFotoUrl'], // YENİ
            favoriMekanlar: List<String>.from(json['favoriMekanlar'] ?? []),
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