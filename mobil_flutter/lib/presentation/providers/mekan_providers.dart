// lib/presentation/providers/mekan_providers.dart (BİRLEŞTİRİLMİŞ HALİ)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
// İSİM DEĞİŞİKLİĞİ: Artık ApiService yerine MekanService kullanıyoruz.
// Bu yüzden kendi projende de dosya adını ve sınıf adını değiştirmeyi unutma.
import 'package:mobil_flutter/data/services/api_service.dart';
import 'package:flutter/material.dart';

// --- SERVİS PROVIDER ---
// İSİM DEĞİŞİKLİĞİ: Provider'ın adını da servisle uyumlu hale getiriyoruz.
final mekanServiceProvider = Provider<ApiService>((ref) => ApiService());


final mesafeCapiProvider = StateProvider<double>((ref) => 5000.0);

// --- YORUM/PUAN GÖNDERME İÇİN YENİ PROVIDER ---
// YENİ EKLENDİ: Yorum/Puan gönderme işleminin durumunu (yükleniyor, başarılı, hata) yönetmek için.
final yorumSubmitProvider =
    StateNotifierProvider.autoDispose<YorumSubmitNotifier, AsyncValue<void>>((
      ref,
    ) {
      return YorumSubmitNotifier(ref);
    });

class YorumSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  YorumSubmitNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> gonder({
    required String mekanId,
    String? icerik,
    double? puan,
  }) async {
    // Eğer içerik ve puan boşsa işlem yapma
    if ((icerik == null || icerik.isEmpty) && puan == null) return;

    state = const AsyncValue.loading();
    try {
      // mekanServiceProvider'dan servisi okuyoruz.
      final mekanService = ref.read(mekanServiceProvider);
      await mekanService.addYorum(mekanId: mekanId, icerik: icerik, puan: puan);

      // ÇOK ÖNEMLİ: İşlem başarılı olunca, detay sayfasının provider'ını geçersiz kılıp
      // yeniden yüklenmesini ve yeni veriyi (yeni yorum/puan) göstermesini sağlıyoruz.
      ref.invalidate(mekanDetayProvider(mekanId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// --- MEVCUT PROVIDER'LARIN GÜNCELLENMİŞ HALLERİ ---

// MEVCUT: Kategori filtresini tutan provider'ın. Değişiklik yok, harika çalışıyor.
final seciliKategoriProvider = StateProvider<String>((ref) => 'categoryAll');
final aramaSorgusuProvider = StateProvider<String>((ref) => '');

// MEVCUT & GÜNCELLENDİ: Artık apiServiceProvider yerine mekanServiceProvider'dan okuyor.
final filtrelenmisMekanlarProvider =
    FutureProvider.family<List<MekanModel>, String>((ref, kategoriKey) async {
      // mekanServiceProvider'ı okuyup, getMekanlar fonksiyonunu kategoriKey ile çağırıyoruz.
      return ref.read(mekanServiceProvider).getMekanlar(kategori: kategoriKey);
    });


final nihaiMekanlarProvider = Provider.autoDispose
    .family<AsyncValue<List<MekanModel>>, Locale>((ref, locale) {
  // Mevcut dil kodunu alıyoruz ('tr' veya 'en').
  final langCode = locale.languageCode;

  final seciliKategoriKey = ref.watch(seciliKategoriProvider);
  final mekanlarAsyncValue = ref.watch(
    filtrelenmisMekanlarProvider(seciliKategoriKey),
  );
  final aramaSorgusu = ref.watch(aramaSorgusuProvider);

  // Veri henüz gelmediyse veya hata varsa, o durumu direkt döndür.
  if (!mekanlarAsyncValue.hasValue || mekanlarAsyncValue.isLoading) {
    return mekanlarAsyncValue;
  }

  final mekanlar = mekanlarAsyncValue.value!;
  
  // Arama sorgusu boşsa, tüm listeyi döndür.
  if (aramaSorgusu.isEmpty) {
    return AsyncData(mekanlar);
  }

  // Arama sorgusu doluysa, filtreleme yap.
  final filtrelenmis = mekanlar.where((mekan) {
    // --- İŞTE DÜZELTME BURADA ---
    // 'mekan.isim' nesnesinin özelliklerine köşeli parantez yerine nokta ile erişiyoruz.
    final mekanIsmi = (langCode == 'tr') ? mekan.isim.tr : mekan.isim.en;
    final sorguLower = aramaSorgusu.toLowerCase();

    return mekanIsmi.toLowerCase().contains(sorguLower);
  }).toList();

  return AsyncData(filtrelenmis);
});
//-----------------------------------------------------------------------------

// 4. Mekan Detayı
final mekanDetayProvider = FutureProvider.family<MekanModel, String>((
  ref,
  mekanId,
) {
  // watch kullanmak burada daha doğru olabilir, çünkü servis değişirse (pek olası değil ama)
  // bu provider da güncellenir. Ama read de sorunsuz çalışır.
  return ref.watch(mekanServiceProvider).getMekanDetay(mekanId);
});
