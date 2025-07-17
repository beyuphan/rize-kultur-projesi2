// lib/data/models/mekan_model.dart
import 'package:mobil_flutter/data/models/yorum_model.dart'; // YorumModel'i import et


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
  final String isim;
  final String aciklama;
  final String kategori;
  final Konum konum;
  final List<String> fotograflar;
  final double ortalamaPuan;
  final List<YorumModel> yorumlar;

  MekanModel({
    required this.id,
    required this.isim,
    required this.aciklama,
    required this.kategori,
    required this.konum,
    required this.fotograflar,
    required this.ortalamaPuan,
    required this.yorumlar, 
  });

   factory MekanModel.fromDetailJson(Map<String, dynamic> json) {
    var yorumListesi = <YorumModel>[];
    if (json['yorumlar'] != null) {
      json['yorumlar'].forEach((v) {
        yorumListesi.add(YorumModel.fromJson(v));
      });
    }

    final mekanJson = json['mekan'];
    
    return MekanModel(
      // DÜZELTME: Artık tüm verileri `json` yerine `mekanJson`'dan okuyoruz.
      id: mekanJson['_id'] ?? '',
      isim: mekanJson['isim'] ?? 'İsim Yok',
      aciklama: mekanJson['aciklama'] ?? 'Açıklama Yok',
      kategori: mekanJson['kategori'] ?? 'Kategorisiz',
      konum: mekanJson['konum'] != null
          ? Konum.fromJson(mekanJson['konum'])
          : Konum(enlem: 0.0, boylam: 0.0),
      fotograflar: List<String>.from(mekanJson['fotograflar'] ?? []),
      ortalamaPuan: (mekanJson['ortalamaPuan'] ?? 0.0).toDouble(),
      yorumlar: yorumListesi,
    );
  }

  // YENİ EKLENDİ: Ana listedeki mekanları (yorumlar olmadan) parse eden basit factory
  factory MekanModel.fromListJson(Map<String, dynamic> json) {
    return MekanModel(
      id: json['_id'] ?? '',
      isim: json['isim'] ?? 'İsim Yok',
      aciklama: json['aciklama'] ?? 'Açıklama Yok',
      kategori: json['kategori'] ?? 'Kategorisiz',
      konum: json['konum'] != null
          ? Konum.fromJson(json['konum'])
          : Konum(enlem: 0.0, boylam: 0.0),
      fotograflar: List<String>.from(json['fotograflar'] ?? []),
      ortalamaPuan: (json['ortalamaPuan'] ?? 0.0).toDouble(),
      yorumlar: [], // Liste görünümünde yorumlar boş gelir.
    );
  }
}