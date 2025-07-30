import 'package:mobil_flutter/data/models/mekan_model.dart';

class RotaModel {
  final String id;
  final CokDilliMetin ad;
  final CokDilliMetin aciklama;
  final CokDilliMetin tahminiSure;
  final CokDilliMetin zorlukSeviyesi;
  final String kapakFotografiUrl;
  final List<MekanModel> mekanlar; // Artık tam MekanModel listesi
  
  RotaModel({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.kapakFotografiUrl,
    required this.tahminiSure,
    required this.zorlukSeviyesi,
    required this.mekanlar,
  });

 // Rota listesi için (mekanlar ID olarak gelir)
  factory RotaModel.fromJson(Map<String, dynamic> json) {
    return RotaModel(
      id: json['_id'],
      ad: json['ad'],
      aciklama: json['aciklama'],
      tahminiSure: json['tahminiSure'],
      zorlukSeviyesi: json['zorlukSeviyesi'],
      kapakFotografiUrl: json['kapakFotografiUrl'],
      mekanlar: const[],
    );
  }

  // Rota detayı için (mekanlar dolu obje olarak gelir)
  factory RotaModel.fromDetailJson(Map<String, dynamic> json) {
    var mekanListesi = <MekanModel>[];
    if (json['mekanIdleri'] != null) {
      json['mekanIdleri'].forEach((v) {
        mekanListesi.add(MekanModel.fromListJson(v));
      });
    }

    return RotaModel(
      id: json['_id'],
      ad: json['ad'],
      aciklama: json['aciklama'],
      tahminiSure: json['tahminiSure'],
      zorlukSeviyesi: json['zorlukSeviyesi'],
      kapakFotografiUrl: json['kapakFotografiUrl'],
      mekanlar: mekanListesi,
    );
  }
}