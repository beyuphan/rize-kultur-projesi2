// lib/data/models/mekan_model.dart (TAM VE DÜZELTİLMİŞ HALİ)

import 'package:mobil_flutter/data/models/yorum_model.dart';

// YARDIMCI SINIF
class CokDilliMetin {
  final String tr;
  final String en;

  CokDilliMetin({required this.tr, required this.en});

  // DÜZELTME BURADA: Map<String, dynamic> olarak değiştirildi.
  factory CokDilliMetin.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CokDilliMetin(tr: 'Veri Yok', en: 'No Data');
    }
    return CokDilliMetin(
      tr: json['tr'] ?? 'Çeviri Yok',
      en: json['en'] ?? 'No Translation',
    );
  }
}

// YARDIMCI SINIF
class Konum {
  final double enlem;
  final double boylam;

  Konum({required this.enlem, required this.boylam});

  factory Konum.fromJson(Map<String, dynamic> json) {
    return Konum(
      enlem: (json['enlem'] ?? 0.0).toDouble(),
      boylam: (json['boylam'] ?? 0.0).toDouble(),
    );
  }
}

// ANA MODEL
class MekanModel {
  final String id;
  final CokDilliMetin isim;
  final CokDilliMetin aciklama;
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
      id: mekanJson['_id'] ?? '',
      isim: CokDilliMetin.fromJson(mekanJson['isim']),
      aciklama: CokDilliMetin.fromJson(mekanJson['aciklama']),
      kategori: mekanJson['kategori'] ?? 'Kategorisiz',
      konum: mekanJson['konum'] != null
          ? Konum.fromJson(mekanJson['konum'])
          : Konum(enlem: 0.0, boylam: 0.0),
      fotograflar: List<String>.from(mekanJson['fotograflar'] ?? []),
      ortalamaPuan: (mekanJson['ortalamaPuan'] ?? 0.0).toDouble(),
      yorumlar: yorumListesi,
    );
  }

  factory MekanModel.fromListJson(Map<String, dynamic> json) {
    return MekanModel(
      id: json['_id'] ?? '',
      isim: CokDilliMetin.fromJson(json['isim']),
      aciklama: CokDilliMetin.fromJson(json['aciklama']),
      kategori: json['kategori'] ?? 'Kategorisiz',
      konum: json['konum'] != null
          ? Konum.fromJson(json['konum'])
          : Konum(enlem: 0.0, boylam: 0.0),
      fotograflar: List<String>.from(json['fotograflar'] ?? []),
      ortalamaPuan: (json['ortalamaPuan'] ?? 0.0).toDouble(),
      yorumlar: [],
    );
  }
}