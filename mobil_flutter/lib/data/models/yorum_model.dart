import 'package:mobil_flutter/data/models/user_model.dart'; // UserModel'ı import ediyoruz

class YorumModel {
  final String id;
  final String? icerik; // Artık null olabilir
  final double? puan;   // Artık null olabilir
  final UserModel yazar; // Yorumu yapan kişinin bilgileri
  final DateTime yorumTarihi;

  YorumModel({
    required this.id,
    this.icerik,
    this.puan,
    required this.yazar,
    required this.yorumTarihi,
  });

  factory YorumModel.fromJson(Map<String, dynamic> json) {
    return YorumModel(
      id: json['_id'],
      icerik: json['icerik'],
      puan: (json['puan'] != null) ? (json['puan'] as num).toDouble() : null,
      yazar: UserModel.fromJson(json['yazar']), // İç içe model parse etme
      yorumTarihi: DateTime.parse(json['yorumTarihi']),
    );
  }
}