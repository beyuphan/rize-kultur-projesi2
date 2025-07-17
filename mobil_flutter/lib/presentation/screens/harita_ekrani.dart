import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Kendi projenizdeki doğru yolları import edin

import 'package:mobil_flutter/data/models/mekan_model.dart'; // Doğru yol
import 'package:mobil_flutter/data/services/api_service.dart'; // Doğru yol
// import 'package:provider/provider.dart'; // Eğer Provider kullanıyorsanız

class HaritaEkrani extends StatefulWidget {
  const HaritaEkrani({super.key});

  @override
  State<HaritaEkrani> createState() => _HaritaEkraniState();
}

class _HaritaEkraniState extends State<HaritaEkrani> {
  // Durum değişkenleri
  bool _isLoading = true;
  String? _errorMessage;
  List<MekanModel> _yakinMekanlar = [];

  // Servisin bir örneğini oluşturalım (veya Provider ile alalım)
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadNearbyVenues();
  }

  // Yakındaki mekanları yükleyen ana fonksiyon
  Future<void> _loadNearbyVenues() async {
    try {
      // 1. Konum iznini kontrol et ve kullanıcı konumunu al
      Position userPosition = await _getCurrentLocation();
      print(
        'Kullanıcının konumu: ${userPosition.latitude}, ${userPosition.longitude}',
      );

      // 2. API'den tüm mekanları çek
      // Bu kısmı kendi API servis metodunuzla değiştirin
      final List<MekanModel> tumMekanlar = await _apiService.getMekanlar();
      print('Mekanlar yüklendi: ${tumMekanlar.length} adet mekan bulundu.');

      // 3. Mekanları filtrele
      _yakinMekanlar = _filterVenuesByDistance(tumMekanlar, userPosition);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kullanıcının mevcut konumunu alan yardımcı fonksiyon
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisleri kapalı.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izinleri reddedildi.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Konum izinleri kalıcı olarak reddedildi, izinleri uygulama ayarlarından açın.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  // Mekanları mesafeye göre filtreleyen yardımcı fonksiyon
  List<MekanModel> _filterVenuesByDistance(
    List<MekanModel> venues,
    Position position,
  ) {
    List<MekanModel> nearbyVenues = [];
    const double maxDistanceInMeters = 500000; // Örnek: 5 KM yarıçap

    for (var mekan in venues) {
      // Mekan modelinizde latitude ve longitude olduğunu varsayıyoruz
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        mekan.konum.enlem, // mekan.latitude'i kendi modelinize göre güncelleyin
        mekan
            .konum
            .boylam, // mekan.longitude'u kendi modelinize göre güncelleyin
      );

      print(
        'Mekan: ${mekan.isim}, Konumu: (${mekan.konum.enlem}, ${mekan.konum.boylam}), Hesaplanan Mesafe: ${distance.round()} metre',
      );
      if (distance <= maxDistanceInMeters) {
        nearbyVenues.add(mekan);
      }
    }
    return nearbyVenues;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar'ı isteğe bağlı ekleyebilirsiniz
      // appBar: AppBar(title: Text("Harita")),
      body: Column(
        children: [
          _buildNearbyVenuesBanner(),
          Expanded(
            child: Center(
              // Buraya Google Maps veya başka bir harita widget'ı gelecek
              child: Text('Harita Alanı'),
            ),
          ),
        ],
      ),
    );
  }

  // Yakındaki mekanlar banner'ını oluşturan widget
  Widget _buildNearbyVenuesBanner() {
    return Container(
      height: 150, // Banner yüksekliği
      width: double.infinity,
      color: Colors.grey[200],
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Hata: $_errorMessage'))
          : _yakinMekanlar.isEmpty
          ? Center(child: Text('Yakınınızda mekan bulunamadı.'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _yakinMekanlar.length,
              itemBuilder: (context, index) {
                final mekan = _yakinMekanlar[index];
                return _buildMekanKarti(mekan);
              },
            ),
    );
  }

  // Her bir mekan için kart oluşturan widget
   Widget _buildMekanKarti(MekanModel mekan) {
    // DİL KODUNU ALMAK İÇİN YENİ BİR YÖNTEM KULLANACAĞIZ
    final dilKodu = Localizations.localeOf(context).languageCode;

    return Container(
      width: 120,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_pin,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                // --- DÜZELTME BURADA ---
                // Köşeli parantez yerine nokta ile erişim
                dilKodu == 'tr' ? mekan.isim.tr : mekan.isim.en,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
