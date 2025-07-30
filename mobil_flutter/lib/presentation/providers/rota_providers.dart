// lib/presentation/providers/rota_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/rota_model.dart';
import 'package:mobil_flutter/presentation/providers/api_service_provider.dart';

// --- YENİ VE DAHA SAĞLAM YAPI: StateNotifier ---

// 1. Rota listesinin durumunu yönetecek olan Notifier sınıfı
class RotaListNotifier extends StateNotifier<AsyncValue<List<RotaModel>>> {
  RotaListNotifier(this.ref) : super(const AsyncLoading()) {
    fetchRotalar(); // Notifier oluşturulur oluşturulmaz veriyi çekmeye başla
  }
  final Ref ref;

  // Rotaları API'den çeken metot
  Future<void> fetchRotalar() async {
    // İşlemin başladığını belirtmek için durumu 'loading' yap
    state = const AsyncLoading();
    try {
      // ApiService'i provider'dan oku
      final apiService = ref.read(apiServiceProvider);
      // Rotaları çek
      final rotalar = await apiService.getRotalar();
      // Veri başarıyla geldiyse, durumu 'data' yap ve veriyi içine koy
      state = AsyncData(rotalar);
    } catch (e, stack) {
      // Herhangi bir hata olursa, durumu 'error' yap ve hatayı içine koy
      state = AsyncError(e, stack);
    }
  }
}

// 2. RotaListNotifier'ı ve onun durumunu UI'a sunan provider
// ESKİ FutureProvider'ın YERİNE BU GELECEK
final rotalarProvider = StateNotifierProvider.autoDispose<RotaListNotifier, AsyncValue<List<RotaModel>>>((ref) {
  return RotaListNotifier(ref);
});


// --- ROTA DETAYI İÇİN MEVCUT PROVIDER AYNI KALIYOR ---
// Bu zaten iyi çalışıyor, dokunmuyoruz.
final rotaDetayProvider = FutureProvider.family.autoDispose<RotaModel, String>((ref, rotaId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getRotaDetay(rotaId);
});