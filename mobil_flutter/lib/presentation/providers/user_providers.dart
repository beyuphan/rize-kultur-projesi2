// lib/presentation/providers/user_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:mobil_flutter/data/services/auth_service.dart';
import 'package:mobil_flutter/data/services/api_service.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/providers/api_service_provider.dart';



final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel>>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel>> {
  UserProfileNotifier(this.ref) : super(const AsyncLoading()) {
    _fetchProfile();
  }
  final Ref ref;

  Future<void> _fetchProfile() async {
    state = const AsyncLoading();
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.getMyProfile();
      state = AsyncData(user);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> toggleFavorite(String mekanId) async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    final user = currentState.value!;
    // DÜZELTME: Artık standart olan apiServiceProvider'ı okuyoruz.
    final apiService = ref.read(apiServiceProvider);

    // İyimser (optimistic) güncelleme
    final isCurrentlyFavorite = user.favoriMekanlar.contains(mekanId);
    final newFavorites = List<String>.from(user.favoriMekanlar);
    if (isCurrentlyFavorite) {
      newFavorites.remove(mekanId);
    } else {
      newFavorites.add(mekanId);
    }
    state = AsyncData(user.copyWith(favoriMekanlar: newFavorites));
    
    try {
      // DÜZELTME: toggleFavorite metodunu apiService üzerinden çağırıyoruz.
      final sunucudanGelenFavoriler = await apiService.toggleFavorite(mekanId);
      // State'i sunucudan gelen en güncel liste ile tekrar güncelle
      // ÖNEMLİ: state'i güncellerken eski 'user' objesini değil, en güncel 'state.value'yu kullan.
      if (state is AsyncData) {
         state = AsyncData(state.value!.copyWith(favoriMekanlar: sunucudanGelenFavoriler));
      }
    } catch (e) {
      // Hata olursa, yaptığımız iyimser güncellemeyi geri al.
      state = currentState; 
    }
  }
}

// publicUserProfileProvider'ı bu dosyanın en altına taşıdık.
final publicUserProfileProvider = FutureProvider.family<UserModel, String>((ref, userId) {
  final apiService = ref.watch(apiServiceProvider); 
  return apiService.getPublicUserProfile(userId);
});