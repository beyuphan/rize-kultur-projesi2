// Bu sınıf, API'den gelen tek bir mekan verisini temsil eder.
class Mekan {
  final String id;
  final String isim;
  final String aciklama;
  final String kategori;
  final List<String> fotograflar;
  final double ortalamaPuan;
  
  Mekan({
    required this.id,
    required this.isim,
    required this.aciklama,
    required this.kategori,
    required this.fotograflar,
    required this.ortalamaPuan,
  });

  // Bu factory constructor, JSON verisini bizim Mekan nesnemize dönüştürür.
  factory Mekan.fromJson(Map<String, dynamic> json) {
    return Mekan(
      id: json['_id'],
      isim: json['isim'],
      aciklama: json['aciklama'],
      kategori: json['kategori'],
      fotograflar: List<String>.from(json['fotograflar'] ?? []),
      ortalamaPuan: (json['ortalamaPuan'] as num).toDouble(),
    );
  }
}
