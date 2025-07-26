// lib/presentation/providers/mekan_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/data/services/api_service.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/providers/api_service_provider.dart';

// --- UI'ın Durumunu Tutan Provider'lar ---
final seciliKategoriProvider = StateProvider<String>((ref) => 'categoryAll');
final aramaSorgusuProvider = StateProvider<String>((ref) => '');
final mesafeCapiProvider = StateProvider<double>((ref) => 10000.0);

// YENİ: Provider'a birden fazla parametre geçmek için kullanılan yardımcı sınıf.
class MekanFiltresi {
  final String? kategori;
  final String? aramaSorgusu;
  final String? sortBy;
  final int sayfa;

  MekanFiltresi({
    this.kategori,
    this.aramaSorgusu,
    this.sortBy,
    this.sayfa = 1,
  });

  // Provider.family'nin aynı filtreyi tekrar tekrar çalıştırmaması için
  // bu metotları eklemek iyi bir pratiktir.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MekanFiltresi &&
          runtimeType == other.runtimeType &&
          kategori == other.kategori &&
          aramaSorgusu == other.aramaSorgusu &&
          sortBy == other.sortBy &&
          sayfa == other.sayfa;

  @override
  int get hashCode => kategori.hashCode ^ aramaSorgusu.hashCode ^ sortBy.hashCode ^ sayfa.hashCode;
}

// YENİ: Tüm dinamik listelemeler için ana provider'ımız.
final mekanListesiProvider = FutureProvider.family<MekanlarResponse, MekanFiltresi>((ref, filtre) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMekanlar(
    kategori: filtre.kategori,
    aramaSorgusu: filtre.aramaSorgusu,
    sortBy: filtre.sortBy,
    sayfa: filtre.sayfa,
  );
});

// YENİ: Keşfet ekranındaki "vitrin" için özel provider.
final populerMekanlarProvider = FutureProvider.autoDispose<MekanlarResponse>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMekanlar(sortBy: 'puan', limit: 10);
});


// --- DETAY VE KULLANICIYA ÖZEL PROVIDER'LAR ---

final mekanDetayProvider = FutureProvider.family<MekanModel, String>((ref, mekanId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMekanDetay(mekanId);
});

final yorumSubmitProvider = StateNotifierProvider.autoDispose<YorumSubmitNotifier, AsyncValue<void>>((ref) {
  return YorumSubmitNotifier(ref);
});

class YorumSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  YorumSubmitNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> gonder({required String mekanId, String? icerik, double? puan}) async {
    if ((icerik == null || icerik.isEmpty) && puan == null) return;
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.addYorum(mekanId: mekanId, icerik: icerik, puan: puan);
      
      ref.invalidate(mekanDetayProvider(mekanId));
      ref.invalidate(kullaniciYorumlariProvider);
      ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final kullaniciYorumlariProvider = FutureProvider.autoDispose<List<YorumModel>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMyYorumlar();
});

final favoriMekanlarProvider = FutureProvider.autoDispose<List<MekanModel>>((ref) async {
  final userAsyncValue = ref.watch(userProfileProvider);
  
  return userAsyncValue.when(
    data: (user) async {
      if (user.favoriMekanlar.isEmpty) return [];
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getMekanlarByIds(user.favoriMekanlar);
    },
    loading: () => [], 
    error: (e, s) => throw e,
  );
});