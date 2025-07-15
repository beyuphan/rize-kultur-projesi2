// lib/data/models/mekan_model.dart

// 1. Konum verisini tutacak yeni sınıfımızı oluşturuyoruz.
class Konum {
  final double enlem;
  final double boylam;

  Konum({required this.enlem, required this.boylam});

  factory Konum.fromJson(Map<String, dynamic> json) {
    return Konum(
      enlem: (json['enlem'] as num).toDouble(),
      boylam: (json['boylam'] as num).toDouble(),
    );
  }
}

// 2. Mekan sınıfımızı yeni Konum sınıfını içerecek şekilde güncelliyoruz.
class Mekan {
  final String id;
  final String isim;
  final String aciklama;
  final String kategori;
  final Konum konum; // Artık burası bir Konum nesnesi
  final List<String> fotograflar;
  final double ortalamaPuan;

  Mekan({
    required this.id,
    required this.isim,
    required this.aciklama,
    required this.kategori,
    required this.konum, // constructor'a ekledik
    required this.fotograflar,
    required this.ortalamaPuan,
  });

  factory Mekan.fromJson(Map<String, dynamic> json) {
    return Mekan(
      id: json['_id'],
      isim: json['isim'],
      aciklama: json['aciklama'],
      kategori: json['kategori'],
      // Gelen 'konum' JSON objesini Konum.fromJson ile nesneye çeviriyoruz.
      konum: Konum.fromJson(json['konum']),
      fotograflar: List<String>.from(json['fotograflar'] ?? []),
      ortalamaPuan: (json['ortalamaPuan'] as num).toDouble(),
    );
  }
}