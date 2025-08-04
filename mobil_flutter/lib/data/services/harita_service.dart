// lib/data/services/harita_service.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobil_flutter/data/models/rota_model.dart'; // Kendi RotaModel importun

class HaritaService {

  // Bu fonksiyon, bir rotanın tüm duraklarını içeren Google Maps navigasyonunu başlatır.
  Future<void> launchGoogleMapsNavigation(BuildContext context, RotaModel rota) async {
    // Rota boşsa veya tek duraklıysa bir şey yapma
    if (rota.duraklar.isEmpty) {
      _showSnackbar(context, "Bu rotada hiç durak yok.");
      return;
    }
    
    _showSnackbar(context, "Konumunuz alınıyor, lütfen bekleyin...");
    
    try {
      // --- 1. Konum İznini Kontrol Et ve Al ---
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackbar(context, "Rota başlatmak için konum izni gereklidir.");
          return;
        }
      }

      // --- 2. Kullanıcının Anlık Konumunu Çek ---
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // 10 saniyede bulamazsa hata ver
      );
      String origin = "${userPosition.latitude},${userPosition.longitude}";

      // --- 3. Rotanın Duraklarını Ayarla ---
      final destinationStop = rota.duraklar.last.mekan;
      String destination = "${destinationStop.konum.enlem},${destinationStop.konum.boylam}";
      
      List<String> waypoints = [];
      if (rota.duraklar.length > 1) {
        waypoints = rota.duraklar
            .sublist(0, rota.duraklar.length - 1)
            .map((durak) => "${durak.mekan.konum.enlem},${durak.mekan.konum.boylam}")
            .toList();
      }

      // --- 4. Google Maps Linkini Oluştur ---
      final uri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'origin': origin,
        'destination': destination,
        'waypoints': waypoints.join('|'),
        'travelmode': 'driving',
      });

      // --- 5. Linki Aç ---
      if (!await launchUrl(uri)) {
        throw 'Harita uygulaması açılamadı.';
      }

    } on LocationServiceDisabledException {
       _showSnackbar(context, "Lütfen cihazınızın konum servislerini (GPS) açın.");
    } catch (e) {
       _showSnackbar(context, "Bir hata oluştu: ${e.toString()}");
    }
  }

  // Kullanıcıya bilgi vermek için yardımcı bir fonksiyon
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Önceki snackbar'ı kaldır
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}