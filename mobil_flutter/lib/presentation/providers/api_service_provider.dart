
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/services/api_service.dart';

// ApiService sınıfının bir örneğini (instance) oluşturan ve
// uygulamanın her yerinden erişilmesini sağlayan provider.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});