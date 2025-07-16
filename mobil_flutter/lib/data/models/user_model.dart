class UserModel {
  final String id;
  final String kullaniciAdi;
  final String email;
  final String? profilFotoUrl; // YENİ: Null olabilir

  UserModel({
    required this.id,
    required this.kullaniciAdi,
    required this.email,
    this.profilFotoUrl,
  });

  // Backend'den gelen JSON verisinden model oluşturmak için
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '', // Backend'den gelen ID'ye göre ayarlayın
      kullaniciAdi: json['kullaniciAdi'] ?? 'İsimsiz',
      email: json['email'] ?? 'E-posta yok',
      profilFotoUrl: json['profilFotoUrl'], // YENİ
    );
  }
}
