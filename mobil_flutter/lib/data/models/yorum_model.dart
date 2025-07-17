// lib/data/models/yorum_model.dart dosyasının TAMAMI BU OLMALI

import 'package:mobil_flutter/data/models/user_model.dart';

class YorumModel {
  final String id;
  final String? icerik;
  final double? puan;
  final UserModel yazar;
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
      yazar: UserModel.fromJson(json['yazar']),
      yorumTarihi: DateTime.parse(json['yorumTarihi']),
    );
  }
}