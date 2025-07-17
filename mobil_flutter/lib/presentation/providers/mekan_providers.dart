import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/services/api_service.dart';
import 'package:flutter/material.dart';

// 1. API Servisi
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// 2. Kategori ve Arama Durumları
final seciliKategoriProvider = StateProvider<String>((ref) => 'categoryAll');
final aramaSorgusuProvider = StateProvider<String>((ref) => '');

// 3. Veri Çekme ve Filtreleme Provider'ları
final filtrelenmisMekanlarProvider =
    FutureProvider.family<List<MekanModel>, String>((ref, kategoriKey) async {
      return ref.read(apiServiceProvider).getMekanlar(kategori: kategoriKey);
    });

// ⚙️ DÜZELTİLMİŞ NİHAİ PROVIDER
//-----------------------------------------------------------------------------
// Bu provider, artık bir liste değil, doğrudan bir AsyncValue döndürür.
// Bu sayede .when() metodu UI tarafında sorunsuz çalışır.
final nihaiMekanlarProvider = Provider.autoDispose
    .family<AsyncValue<List<MekanModel>>, Locale>((ref, locale) {
      // Mevcut dil kodunu alıyoruz ('tr' veya 'en').
      final langCode = locale.languageCode;

      final seciliKategoriKey = ref.watch(seciliKategoriProvider);
      final mekanlarAsyncValue = ref.watch(
        filtrelenmisMekanlarProvider(seciliKategoriKey),
      );
      final aramaSorgusu = ref.watch(aramaSorgusuProvider);

      if (!mekanlarAsyncValue.hasValue) {
        return mekanlarAsyncValue;
      }

      final mekanlar = mekanlarAsyncValue.value!;
      if (aramaSorgusu.isEmpty) {
        return AsyncData(mekanlar);
      }

      final filtrelenmis = mekanlar.where((mekan) {
        // ARAMA MANTIĞI GÜNCELLEMESİ:
        // 1. Mekanın ismini mevcut uygulama dilinde al.
        // 2. Eğer o dilde isim yoksa, varsayılan olarak Türkçe'yi kullan (fallback).
        final mekanIsmi = mekan.isim[langCode] ?? mekan.isim['tr'] ?? '';
        final sorguLower = aramaSorgusu.toLowerCase();

        return mekanIsmi.toLowerCase().contains(sorguLower);
      }).toList();

      return AsyncData(
        filtrelenmis,
      ); // Filtrelenmiş veriyi AsyncData olarak döndür.
    });
//-----------------------------------------------------------------------------

// 4. Mekan Detayı
final mekanDetayProvider = FutureProvider.family<MekanModel, String>((
  ref,
  mekanId,
) {
  return ref.watch(apiServiceProvider).getMekanDetay(mekanId);
});
