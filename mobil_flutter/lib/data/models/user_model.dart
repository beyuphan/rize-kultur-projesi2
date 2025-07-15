class UserModel {
  final String id;
  final String kullaniciAdi;
  final String email;
  // Diğer profil bilgileri buraya eklenebilir (örn: profilFotoUrl)

  UserModel({
    required this.id,
    required this.kullaniciAdi,
    required this.email,
  });

  // Backend'den gelen JSON verisinden model oluşturmak için
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '', // Backend'den gelen ID'ye göre ayarlayın
      kullaniciAdi: json['kullaniciAdi'] ?? 'İsimsiz',
      email: json['email'] ?? 'E-posta yok',
    );
  }
}
