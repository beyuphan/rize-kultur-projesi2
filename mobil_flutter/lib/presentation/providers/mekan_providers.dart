// lib/presentation/providers/mekan_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart'; // Mekan modelini import et
import 'package:mobil_flutter/data/services/api_service.dart'; // ApiService'i import et

// ApiService için bir provider (eğer henüz yoksa)
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Mekanları getirecek FutureProvider
final mekanlarProvider = FutureProvider<List<Mekan>>((ref) async {
final apiService = ref.watch(apiServiceProvider);
return await apiService.getMekanlar();
});