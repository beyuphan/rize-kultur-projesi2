// lib/data/models/durak_model.dart

import 'package:mobil_flutter/data/models/mekan_model.dart';

class DurakModel {
  final MekanModel mekan;
  final String? sonrakiDuragaMesafe; // Örn: "15.2 km"
  final String? sonrakiDuragaSure;   // Örn: "25 mins"

  DurakModel({
    required this.mekan,
    this.sonrakiDuragaMesafe,
    this.sonrakiDuragaSure,
  });

  // API'den gelen JSON objesini parse etmek için factory constructor
  factory DurakModel.fromJson(Map<String, dynamic> json) {
    
    // Gelen JSON'da 'mekanId' alanı populate edildiği için artık bir obje.
    // Bu objeyi MekanModel'e çeviriyoruz.
    final mekanData = json['mekanId'] != null 
        ? MekanModel.fromListJson(json['mekanId']) 
        : MekanModel.fromListJson({}); // Güvenlik için boş model oluştur

    return DurakModel(
      mekan: mekanData,
      sonrakiDuragaMesafe: json['sonrakiDuragaMesafe'], // Bu alan null olabilir
      sonrakiDuragaSure: json['sonrakiDuragaSure'],     // Bu alan null olabilir
    );
  }
}