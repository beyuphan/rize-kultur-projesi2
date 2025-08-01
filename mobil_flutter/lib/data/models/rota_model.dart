// lib/data/models/rota_model.dart
import 'package:mobil_flutter/data/models/durak_model.dart'; // YENİ IMPORT
import 'package:mobil_flutter/data/models/mekan_model.dart';

// Bu model, backend'deki Rota.js şemasıyla birebir uyumludur.
class RotaModel {
  final String id;
  final CokDilliMetin ad;
  final CokDilliMetin aciklama;
  final CokDilliMetin tahminiSure;
  final CokDilliMetin zorlukSeviyesi;
  final String kapakFotografiUrl;
  
  // Rota detayında bu liste dolu gelir, rota listesinde ise boştur.
  final List<DurakModel> duraklar;

  RotaModel({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.tahminiSure,
    required this.zorlukSeviyesi,
    required this.kapakFotografiUrl,
    required this.duraklar,
  });

  // Rotalar listesini (GET /api/rotalar) parse etmek için kullanılır.
  // Bu yanıtta mekan detayları gelmez.
  factory RotaModel.fromJson(Map<String, dynamic> json) {
    return RotaModel(
      id: json['_id'] ?? '',
      ad: CokDilliMetin.fromJson(json['ad']),
      aciklama: CokDilliMetin.fromJson(json['aciklama']),
      tahminiSure: CokDilliMetin.fromJson(json['tahminiSure']),
      zorlukSeviyesi: CokDilliMetin.fromJson(json['zorlukSeviyesi']),
      kapakFotografiUrl: json['kapakFotografiUrl'] ?? '',
      duraklar: const [], // Liste ekranında mekanlar boş gelir
    );
  }

  // Tek bir rota detayını (GET /api/rotalar/:id) parse etmek için kullanılır.
  // Bu yanıtta mekan detayları 'populate' edilmiş olarak gelir.
  factory RotaModel.fromDetailJson(Map<String, dynamic> json) {
    var durakListesi = <DurakModel>[];
        if (json['duraklar'] != null && json['duraklar'] is List) {
      (json['duraklar'] as List).forEach((durakJson) {
        
        // --- DÜZELTME BURADA ---
        // Önce durakJson'ın kendisinin null olup olmadığını kontrol et.
        if (durakJson != null && durakJson['mekanId'] != null) {
          // Sonra da içindeki mekanId'nin null olup olmadığını kontrol et.
          // Bu, veritabanında geçersiz bir mekan ID'si olsa bile uygulamanın çökmesini engeller.
          durakListesi.add(DurakModel.fromJson(durakJson));
        }
        // --- DÜZELTME BİTTİ ---

      });
    }

    return RotaModel(
      id: json['_id'] ?? '',
      ad: CokDilliMetin.fromJson(json['ad']),
      aciklama: CokDilliMetin.fromJson(json['aciklama']),
      tahminiSure: CokDilliMetin.fromJson(json['tahminiSure']),
      zorlukSeviyesi: CokDilliMetin.fromJson(json['zorlukSeviyesi']),
      kapakFotografiUrl: json['kapakFotografiUrl'] ?? '',
      duraklar: durakListesi, // Detay ekranında mekanlar dolu gelir
    );
  }

    List<MekanModel> get mekanlar => duraklar.map((d) => d.mekan).toList();
}
