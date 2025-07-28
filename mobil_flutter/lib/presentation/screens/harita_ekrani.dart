// lib/presentation/screens/harita_ekrani.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/presentation/providers/api_service_provider.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';


// --- Provider'lar ---
// Bu provider'lar bu ekrana hizmet eder, burada kalmaları temiz bir yapı sağlar.

// 1. Konum servislerini ve izinlerini yöneten provider
final konumProvider = FutureProvider.autoDispose<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Lütfen konum servislerini açın.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Konum izni verilmedi.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Konum izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.');
  }
  return await Geolocator.getCurrentPosition();
});

// 2. Haritanın durumunu ve mekanları yöneten StateNotifier
final haritaProvider = StateNotifierProvider.autoDispose<HaritaNotifier, AsyncValue<List<MekanModel>>>((ref) {
  return HaritaNotifier(ref);
});

class HaritaNotifier extends StateNotifier<AsyncValue<List<MekanModel>>> {
  HaritaNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }
  final Ref ref;

  // Başlangıçta kullanıcının konumuna göre mekanları getirir
  Future<void> _init() async {
    try {
      final position = await ref.read(konumProvider.future);
      await fetchYakindakiMekanlar(enlem: position.latitude, boylam: position.longitude);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // Belirli bir konuma göre mekanları getiren fonksiyon
  Future<void> fetchYakindakiMekanlar({required double enlem, required double boylam}) async {
    state = const AsyncLoading();
    try {
      final mesafe = ref.read(mesafeCapiProvider);
      final apiService = ref.read(apiServiceProvider);
      final mekanlar = await apiService.getYakindakiMekanlar(enlem: enlem, boylam: boylam, mesafe: mesafe);
      state = AsyncData(mekanlar);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

// --- Ana Arayüz Widget'ı ---
class HaritaEkrani extends ConsumerStatefulWidget {
  const HaritaEkrani({super.key});

  @override
  ConsumerState<HaritaEkrani> createState() => _HaritaEkraniState();
}

class _HaritaEkraniState extends ConsumerState<HaritaEkrani> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _haritaMerkezi;
  bool _aramaButonuGoster = false;

  @override
  Widget build(BuildContext context) {
    final konumAsync = ref.watch(konumProvider);
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar'ı kaldırıp, geri butonunu Stack içine ekleyerek tam ekran hissi veriyoruz
      body: konumAsync.when(
        loading: () => const Center(child: Text("Konum alınıyor...")),
        error: (err, stack) => Center(child: Text('Konum alınamadı: $err')),
        data: (position) {
          _haritaMerkezi ??= LatLng(position.latitude, position.longitude);

          return Stack(
            children: [
              // KATMAN 1: HARİTA
              _buildGoogleMap(),

              // KATMAN 2: ÜST KONTROL PANELİ (SLIDER)
              _buildTopControlPanel(theme),

              // KATMAN 3: ORTADAKİ ARAMA BUTONU
              if (_aramaButonuGoster) _buildCenterSearchButton(),

              // KATMAN 4: ALT SONUÇ PANELİ
              _buildBottomResultsPanel(context, theme),
              
              // KATMAN 5: GERİ BUTONU
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoogleMap() {
    final mekanlarAsync = ref.watch(haritaProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final seciliMesafe = ref.watch(mesafeCapiProvider);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _haritaMerkezi!, zoom: 11),
      onMapCreated: (controller) {
        if (!_mapController.isCompleted) _mapController.complete(controller);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false, // Kendi butonumuzu kullanacağız
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(top: 140, bottom: 200),
      markers: mekanlarAsync.maybeWhen(
        data: (mekanlar) => mekanlar.map((mekan) => Marker(
              markerId: MarkerId(mekan.id),
              position: LatLng(mekan.konum.enlem, mekan.konum.boylam),
              infoWindow: InfoWindow(
                title: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MekanDetayEkrani(mekanId: mekan.id))),
              ),
            )).toSet(),
        orElse: () => {},
      ),
      onCameraMove: (pos) => _haritaMerkezi = pos.target,
      onCameraIdle: () => setState(() => _aramaButonuGoster = true),
      circles: {
        Circle(
          circleId: const CircleId('arama_capi_id'),
          center: _haritaMerkezi!,
          radius: seciliMesafe,
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 1,
        ),
      },
    );
  }

  Widget _buildTopControlPanel(ThemeData theme) {
    final seciliMesafe = ref.watch(mesafeCapiProvider);
    
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text("Arama Yarıçapı: ${(seciliMesafe / 1000).toStringAsFixed(1)} km", style: theme.textTheme.labelLarge),
            Slider(
              value: seciliMesafe,
              min: 1000, max: 50000,
              divisions: 49,
              label: "${(seciliMesafe / 1000).round()} km",
              onChanged: (yeniDeger) => ref.read(mesafeCapiProvider.notifier).state = yeniDeger,
              onChangeEnd: (yeniDeger) { // Slider bırakılınca otomatik ara
                if (_haritaMerkezi != null) {
                  ref.read(haritaProvider.notifier).fetchYakindakiMekanlar(
                        enlem: _haritaMerkezi!.latitude,
                        boylam: _haritaMerkezi!.longitude,
                      );
                  setState(() => _aramaButonuGoster = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCenterSearchButton() {
     final seciliMesafe = ref.watch(mesafeCapiProvider);
     return Center(
       child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          // BUTONUN ÜZERİNDE NE KADARLIK ALANDA ARAYACAĞI YAZIYOR
          label: Text("Bu Alanda Ara (${(seciliMesafe / 1000).toStringAsFixed(0)} km)"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: const StadiumBorder(),
          ),
          onPressed: () {
            if (_haritaMerkezi != null) {
              ref.read(haritaProvider.notifier).fetchYakindakiMekanlar(
                enlem: _haritaMerkezi!.latitude,
                boylam: _haritaMerkezi!.longitude,
              );
              setState(() => _aramaButonuGoster = false);
            }
          },
        ),
     );
  }

  Widget _buildBottomResultsPanel(BuildContext context, ThemeData theme) {
    final mekanlarAsync = ref.watch(haritaProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor.withOpacity(0),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: mekanlarAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e,s) => Center(child: Text("Hata: $e")),
          data: (mekanlar) => mekanlar.isEmpty
              ? const Center(child: Text("Yakınlarda mekan bulunamadı."))
              : PageView.builder(
                  itemCount: mekanlar.length,
                  itemBuilder: (context, index) {
                    final mekan = mekanlar[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MekanDetayEkrani(mekanId: mekan.id))),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Image.network(
                                  mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : 'https://placehold.co/600x400',
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                       Text(
                                        langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Mesafe: [Hesaplanacak] km", // İleride eklenebilir
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}