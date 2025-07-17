// lib/presentation/providers/mekan_providers.dart (BİRLEŞTİRİLMİŞ HALİ)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
// İSİM DEĞİŞİKLİĞİ: Artık ApiService yerine MekanService kullanıyoruz.
// Bu yüzden kendi projende de dosya adını ve sınıf adını değiştirmeyi unutma.
import 'package:mobil_flutter/data/services/api_service.dart';

// --- SERVİS PROVIDER ---
// İSİM DEĞİŞİKLİĞİ: Provider'ın adını da servisle uyumlu hale getiriyoruz.
final mekanServiceProvider = Provider<ApiService>((ref) => ApiService());


// --- YORUM/PUAN GÖNDERME İÇİN YENİ PROVIDER ---
// YENİ EKLENDİ: Yorum/Puan gönderme işleminin durumunu (yükleniyor, başarılı, hata) yönetmek için.
final yorumSubmitProvider = StateNotifierProvider.autoDispose<YorumSubmitNotifier, AsyncValue<void>>((ref) {
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


// MEVCUT & GÜNCELLENDİ: Artık apiServiceProvider yerine mekanServiceProvider'dan okuyor.
final filtrelenmisMekanlarProvider =
    FutureProvider.family<List<MekanModel>, String>((ref, kategoriKey) async {
  // mekanServiceProvider'ı okuyup, getMekanlar fonksiyonunu kategoriKey ile çağırıyoruz.
  return ref.read(mekanServiceProvider).getMekanlar(kategori: kategoriKey);
});


// MEVCUT & GÜNCELLENDİ: Bu da artık mekanServiceProvider'dan okuyor.
final mekanDetayProvider = FutureProvider.family<MekanModel, String>((
  ref,
  mekanId,
) {
  // watch kullanmak burada daha doğru olabilir, çünkü servis değişirse (pek olası değil ama)
  // bu provider da güncellenir. Ama read de sorunsuz çalışır.
  return ref.watch(mekanServiceProvider).getMekanDetay(mekanId);
});