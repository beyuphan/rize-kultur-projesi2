import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- HATA 1: EKSİK OLAN IMPORT
import 'package:mobil_flutter/data/models/rota_model.dart'; // <-- HATA 2: YOLU KONTROL ET
import 'package:mobil_flutter/data/services/mock_rota_service.dart'; // <-- HATA 3: DOĞRU YOL

// Riverpod importu eklendiği için bu satırdaki hata düzelecek.
final rotaProvider = ChangeNotifierProvider((ref) => RotaProvider());

class RotaProvider with ChangeNotifier {
  // Diğer importlar düzelince bu satırdaki hata da gidecek.
  final MockRotaService _rotaService = MockRotaService();

  // Rota modeli tanındığı için bu satırlardaki hatalar da gidecek.
  List<Rota> _rotalar = [];
  bool _isLoading = true;
  String? _hata;

  List<Rota> get rotalar => _rotalar;
  bool get isLoading => _isLoading;
  String? get hata => _hata;

  RotaProvider() {
    _rotalariGetir();
  }

  Future<void> _rotalariGetir() async {
    try {
      _rotalar = await _rotaService.getRotalar();
    } catch (e) {
      _hata = 'Rotalar yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
