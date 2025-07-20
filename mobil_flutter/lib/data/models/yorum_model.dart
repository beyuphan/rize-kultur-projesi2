import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';

class YorumModel {
  final String id;
  final String? icerik;
  final double? puan;
  final UserModel yazar;
  final DateTime yorumTarihi;
  final MekanModel? mekan;

  YorumModel({
    required this.id,
    this.icerik,
    this.puan,
    required this.yazar,
    required this.yorumTarihi,
    this.mekan,
  });

  // --- ANA DÜZELTME BU FONKSİYONDA ---
  factory YorumModel.fromJson(Map<String, dynamic> json) {
    MekanModel? parsedMekan;

    // ADIM 1: 'mekan' alanının tipini kontrol et.
    // Bu, 'String' bir ID mi yoksa 'Map' bir obje mi diye bakar.
    if (json['mekan'] != null && json['mekan'] is Map<String, dynamic>) {
      // Eğer bir obje ise, MekanModel'e çevir.
      parsedMekan = MekanModel.fromListJson(json['mekan']);
    }
    // Eğer String veya null ise, parsedMekan null olarak kalır ve uygulama ÇÖKMEZ.

    return YorumModel(
      id: json['_id'],
      icerik: json['icerik'],
      // Küçük iyileştirme: puan'ı daha güvenli parse etme
      puan: (json['puan'] as num?)?.toDouble(),
      // 'yazar' alanının her zaman dolu bir obje geldiğini loglardan biliyoruz.
      yazar: UserModel.fromJson(json['yazar']),
      yorumTarihi: DateTime.parse(json['yorumTarihi']),
      // ADIM 2: Akıllıca parse edilmiş veya null bırakılmış mekanı ata.
      mekan: parsedMekan,
    );
  }

  // --- BU METODU DAHA TEMİZ HALE GETİRİYORUZ ---
  // Artık bu ayrı metoda gerek yok, ana metodu çağırması yeterli.
  factory YorumModel.fromJsonWithMekan(Map<String, dynamic> json) {
    return YorumModel.fromJson(json);
  }
}