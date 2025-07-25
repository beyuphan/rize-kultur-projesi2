// lib/presentation/providers/user_providers.dart (YENİ DOSYA)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:mobil_flutter/data/services/api_service.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';


final apiServiceProvider = Provider((ref) => ApiService());

// --- YENİ StateNotifier VE Provider ---
// ESKİ FutureProvider'ın YERİNİ BU ALACAK
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel>>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel>> {
  UserProfileNotifier(this.ref) : super(const AsyncLoading()) {
    _fetchProfile(); // Notifier oluşturulunca profili otomatik çek
  }
  final Ref ref;

  // Profil bilgisini ilk başta çeken metot
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

  // Favori durumunu değiştiren metot
  Future<void> toggleFavorite(String mekanId) async {
    final currentState = state;
    // Sadece mevcut state'imiz data ise (yani profil bilgisi başarıyla yüklendiyse) devam et
    if (currentState is! AsyncData) return;

    final user = currentState.value!;
    final mekanService = ref.read(mekanServiceProvider);

    // 1. Anlık UI güncellemesi için "iyimser" (optimistic) güncelleme yapalım
    final isCurrentlyFavorite = user.favoriMekanlar.contains(mekanId);
    final newFavorites = List<String>.from(user.favoriMekanlar);
    if (isCurrentlyFavorite) {
      newFavorites.remove(mekanId);
    } else {
      newFavorites.add(mekanId);
    }
    // State'i, sunucudan cevap beklemeden HEMEN güncelle. Arayüz anında değişsin.
    state = AsyncData(user.copyWith(favoriMekanlar: newFavorites));
    
    // 2. Şimdi de arka planda sunucuya isteği at
    try {
      // Sunucudaki favori listesini güncelle
      final sunucudanGelenFavoriler = await mekanService.toggleFavorite(mekanId);
      // Sunucudan gelen en güncel liste ile state'i tekrar güncelle (garanti olsun)
      state = AsyncData(user.copyWith(favoriMekanlar: sunucudanGelenFavoriler));
    } catch (e) {
      // 3. Hata olursa, yaptığımız iyimser güncellemeyi geri al ve eski hale dön.
      state = currentState; 
    }
  }

}

// --- DÜZELTME BURADA ---
// publicUserProfileProvider, UserProfileNotifier sınıfının DIŞINDA olmalı.
final publicUserProfileProvider = FutureProvider.family<UserModel, String>((ref, userId) {
  // ApiService provider'ını burada okuyup kullanıyoruz
  final apiService = ref.watch(apiServiceProvider); 
  return apiService.getPublicUserProfile(userId);
});