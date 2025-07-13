import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/services/api_service.dart';

// API servisimizin bir örneğini oluşturan basit bir provider.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// KULLANICININ SEÇTİĞİ KATEGORİNİN ANAHTARINI TUTAN PROVIDER
// Başlangıç değeri 'categoryAll' (Tümü)
final seciliKategoriProvider = StateProvider<String>((ref) => 'categoryAll');

// FİLTRELENMİŞ MEKANLARI GETİREN YENİ VE AKILLI PROVIDER'IMIZ
// DÜZELTME: Bunu, bir parametre (String türünde bir kategori anahtarı) alabilen
// ve bu parametreye göre sonuç üreten bir FutureProvider.family'e çeviriyoruz.
final filtrelenmisMekanlarProvider = FutureProvider.family<List<Mekan>, String>((ref, kategoriKey) async {
  // Artık başka bir provider'ı izlemesine gerek yok, parametreyi doğrudan kullanıyor.
  return ref.read(apiServiceProvider).getMekanlar(kategori: kategoriKey);
});
