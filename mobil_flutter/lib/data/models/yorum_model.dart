import 'package:mobil_flutter/data/models/user_model.dart'; // UserModel'ı import ediyoruz
import 'package:mobil_flutter/data/models/mekan_model.dart';

class YorumModel {
  final String id;
  final String? icerik; // Artık null olabilir
  final double? puan;   // Artık null olabilir
  final UserModel yazar; // Yorumu yapan kişinin bilgileri
  final DateTime yorumTarihi;
  final MekanModel? mekan; // Yorumun yapıldığı mekan

  YorumModel({
    required this.id,
    this.icerik,
    this.puan,
    required this.yazar,
    required this.yorumTarihi,
    this.mekan,
  });

  factory YorumModel.fromJson(Map<String, dynamic> json) {
    return YorumModel(
      id: json['_id'],
      icerik: json['icerik'],
      puan: (json['puan'] != null) ? (json['puan'] as num).toDouble() : null,
      yazar: UserModel.fromJson(json['yazar']), // İç içe model parse etme
      yorumTarihi: DateTime.parse(json['yorumTarihi']),
      mekan: json['mekan'] != null ? MekanModel.fromListJson(json['mekan']) : null,
    );
  }

  // --- BU METODU EKLE ---
  factory YorumModel.fromJsonWithMekan(Map<String, dynamic> json) {
    return YorumModel(
      id: json['_id'],
      icerik: json['icerik'],
      puan: (json['puan'] != null) ? (json['puan'] as num).toDouble() : null,
      yazar: UserModel.fromJson(json['yazar']),
      yorumTarihi: DateTime.parse(json['yorumTarihi']),
      mekan: json['mekan'] != null ? MekanModel.fromListJson(json['mekan']) : null,
    );
  }
}