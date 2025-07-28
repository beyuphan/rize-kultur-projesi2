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
  final CokDilliMetin? tarihce; // YENİ
  final List<String>? etiketler; // YENİ

  MekanModel({
    required this.id,
    required this.isim,
    required this.aciklama,
    required this.kategori,
    required this.konum,
    required this.fotograflar,
    required this.ortalamaPuan,
    required this.yorumlar,
    this.tarihce, // YENİ
    this.etiketler, // YENİ
  });

// HATA AYIKLAMA İÇİN ÖZEL OLARAK YAZILMIŞTIR
factory MekanModel.fromDetailJson(Map<String, dynamic> json) {
  try {
    print("--- fromDetailJson BAŞLADI ---");

    var yorumListesi = <YorumModel>[];
    if (json['yorumlar'] != null) {
      print("[+] Yorumlar parse ediliyor...");
      (json['yorumlar'] as List).forEach((v) {
        try {
          yorumListesi.add(YorumModel.fromJson(v));
        } catch (e, s) {
          print("!!! BİR YORUM PARSE EDİLİRKEN HATA !!!");
          print("Hata: $e");
          print("Sorunlu Yorum JSON'ı: $v");
          // Bu hatayı görmezden gelip devam et, belki sadece bir yorum bozuktur.
        }
      });
      print("[+] Yorumlar bitti.");
    }

    final mekanJson = json['mekan'];
    if (mekanJson == null) {
      print("!!! KRİTİK HATA: JSON içinde 'mekan' anahtarı bulunamadı! ---");
      throw Exception("JSON'da 'mekan' anahtarı yok.");
    }
    print("[+] 'mekan' anahtarı bulundu, içi parse ediliyor...");

    print("  [1] 'isim' parse ediliyor...");
    final isim = CokDilliMetin.fromJson(mekanJson['isim']);

    print("  [2] 'aciklama' parse ediliyor...");
    final aciklama = CokDilliMetin.fromJson(mekanJson['aciklama']);

    print("  [3] 'kategori' alınıyor...");
    final kategori = mekanJson['kategori']?.toString() ?? 'Kategorisiz';

    print("  [4] 'konum' parse ediliyor...");
    final konum = mekanJson['konum'] != null
        ? Konum.fromJson(mekanJson['konum'])
        : Konum(enlem: 0.0, boylam: 0.0);

    print("  [5] 'fotograflar' alınıyor...");
    final fotograflar = List<String>.from(mekanJson['fotograflar'] ?? []);

    print("  [6] 'ortalamaPuan' alınıyor...");
    final ortalamaPuan = (mekanJson['ortalamaPuan'] ?? 0.0).toDouble();

    print("  [7] MekanModel'in kendisi oluşturuluyor...");
    final model = MekanModel(
      id: mekanJson['_id'] ?? '',
      isim: isim,
      aciklama: aciklama,
      kategori: kategori,
      konum: konum,
      fotograflar: fotograflar,
      ortalamaPuan: ortalamaPuan,
      yorumlar: yorumListesi,
      tarihce: CokDilliMetin.fromJson(mekanJson['tarihce']), // YENİ
      etiketler: List<String>.from(mekanJson['etiketler'] ?? []), // YEN
    );

    print("--- fromDetailJson BAŞARIYLA BİTTİ ---");
    return model;

  } catch (e, s) {
    print("!!! MekanModel.fromDetailJson İÇİNDE BÜYÜK BİR HATA YAKALANDI !!!");
    print("HATA TÜRÜ: ${e.runtimeType}");
    print("HATA MESAJI: $e");
    print("GELEN TOPLAM JSON: $json");
    print("STACK TRACE: $s");
    // Hatayı yukarı fırlat ki uygulama bilsin.
    rethrow;
  }
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
      tarihce: CokDilliMetin.fromJson(json['tarihce']), // YENİ
      etiketler: List<String>.from(json['etiketler'] ?? []), 
    );
  }
}