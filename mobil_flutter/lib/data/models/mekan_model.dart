// lib/data/models/mekan_model.dart

// 1. Konum verisini tutacak sınıf (Null kontrolü eklendi)
class Konum {
  final double enlem;
  final double boylam;

  Konum({required this.enlem, required this.boylam});

  factory Konum.fromJson(Map<String, dynamic> json) {
    return Konum(
      // ?? 0.0 ile null gelirse varsayılan değer atıyoruz.
      enlem: (json['enlem'] ?? 0.0).toDouble(),
      boylam: (json['boylam'] ?? 0.0).toDouble(),
    );
  }
}

// 2. Mekan sınıfı (Null kontrolleri ile daha güvenli hale getirildi)
class MekanModel {
  final String id;
  final Map<String, String> isim;
  final Map<String, String> aciklama;
  final String kategori;
  final Konum konum;
  final List<String> fotograflar;
  final double ortalamaPuan;

  MekanModel({
    required this.id,
    required this.isim,
    required this.aciklama,
    required this.kategori,
    required this.konum,
    required this.fotograflar,
    required this.ortalamaPuan,
  });

  factory MekanModel.fromJson(Map<String, dynamic> json) {
    return MekanModel(
      // Diğer alanların da null gelme ihtimaline karşı varsayılan değerler atıyoruz.
      id: json['_id'] ?? '',
      isim: json['isim'] is Map
          ? Map<String, String>.from(json['isim'])
          : {'tr': 'İsim Yok', 'en': 'No Name'},
      aciklama: json['aciklama'] is Map
          ? Map<String, String>.from(json['aciklama'])
          : {'tr': 'Açıklama Yok', 'en': 'No Description'},
      kategori: json['kategori'] ?? 'Kategorisiz',

      // EN ÖNEMLİ DÜZELTME: 'konum' objesinin kendisinin null olup olmadığını kontrol ediyoruz.
      konum: json['konum'] != null
          ? Konum.fromJson(json['konum'])
          : Konum(
              enlem: 0.0,
              boylam: 0.0,
            ), // Eğer konum null ise, varsayılan bir Konum nesnesi oluştur.

      fotograflar: List<String>.from(json['fotograflar'] ?? []),
      ortalamaPuan: (json['ortalamaPuan'] ?? 0.0).toDouble(),
    );
  }
}
