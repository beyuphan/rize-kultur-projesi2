import 'package:mobil_flutter/data/models/rota_model.dart';

class MockRotaService {
  final List<Rota> _sahteRotalar = [
    Rota(
      id: 'rota1',
      adKey: 'firtinaVadisiName',
      aciklamaKey: 'firtinaVadisiDescription',
      kapakFotografiUrl: 'https://i.ytimg.com/vi/Hgd6bA1n1kE/maxresdefault.jpg',
      tahminiSureKey: 'firtinaVadisiDuration',
      zorlukSeviyesiKey: 'firtinaVadisiDifficulty',
      mekanIdleri: ['mekan_zil_kalesi', 'mekan_palovit_selalesi'],
    ),
    Rota(
      id: 'rota2',
      adKey: 'kackarlarZirveName',
      aciklamaKey: 'kackarlarZirveDescription',
      kapakFotografiUrl:
          'https://www.resimle.net/data/media/13/ayder_yaylasi.jpg',
      tahminiSureKey: 'kackarlarZirveDuration',
      zorlukSeviyesiKey: 'kackarlarZirveDifficulty',
      mekanIdleri: [
        'mekan_ayder_yaylasi',
        'mekan_gito_yaylasi',
        'mekan_kavrun_yaylasi',
      ],
    ),
    Rota(
      id: 'rota3',
      adKey: 'cayBahceleriName',
      aciklamaKey: 'cayBahceleriDescription',
      kapakFotografiUrl:
          'https://www.caykur.gov.tr/kurumlar/caykur.gov.tr/CK-BANNER/Bannerrrr.jpg',
      tahminiSureKey: 'cayBahceleriDuration',
      zorlukSeviyesiKey: 'cayBahceleriDifficulty',
      mekanIdleri: ['mekan_ziraat_botanik_cayi'],
    ),
  ];

  Future<List<Rota>> getRotalar() async {
    await Future.delayed(const Duration(seconds: 1));
    return _sahteRotalar;
  }
}
