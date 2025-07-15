import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/services/api_service.dart';

// API servisimizin bir örneğini oluşturan basit bir provider.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Tüm mekanları getiren ve durumu (yükleniyor, hata, başarılı) yöneten FutureProvider.
// Arayüzümüz sadece bu provider'ı dinleyecek.


final seciliKategoriProvider = StateProvider<String>((ref) => 'categoryAll');

final filtrelenmisMekanlarProvider = FutureProvider.family<List<Mekan>, String>((ref, kategoriKey) async {
  // API servis provider'ını okuyup, getMekanlar fonksiyonunu kategoriKey ile çağırıyoruz.
  return ref.read(apiServiceProvider).getMekanlar(kategori: kategoriKey);
});

final mekanDetayProvider = FutureProvider.family<Mekan, String>((ref, mekanId) {
  // apiServiceProvider'ı okuyup, getMekanDetay fonksiyonunu mekanId ile çağırıyoruz.
  return ref.watch(apiServiceProvider).getMekanDetay(mekanId);
});
