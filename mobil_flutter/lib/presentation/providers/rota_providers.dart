// lib/presentation/providers/rota_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/rota_model.dart';
import 'package:mobil_flutter/presentation/providers/api_service_provider.dart';

// Tüm rotaların listesini getiren provider
final rotalarProvider = FutureProvider.autoDispose<List<RotaModel>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getRotalar();
});

// ID ile tek bir rotanın detayını getiren provider
final rotaDetayProvider = FutureProvider.family.autoDispose<RotaModel, String>((ref, rotaId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getRotaDetay(rotaId);
});