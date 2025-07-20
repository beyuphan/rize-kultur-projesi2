// lib/presentation/screens/harita_ekrani.dart (NİHAİ VE İNTERAKTİF KOD)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';

// 1. Konum servislerini ve izinlerini yönetecek provider
final konumProvider = FutureProvider.autoDispose<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Konum servisleri kapalı.');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Konum izinleri reddedildi.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Konum izinleri kalıcı olarak reddedildi, uygulama ayarlarından açın.');
  }
  return await Geolocator.getCurrentPosition();
});

// 2. Haritanın durumunu ve mekanları yönetecek olan ana provider'ımız
final haritaProvider = StateNotifierProvider.autoDispose<HaritaNotifier, AsyncValue<List<MekanModel>>>((ref) {
  return HaritaNotifier(ref);
});

class HaritaNotifier extends StateNotifier<AsyncValue<List<MekanModel>>> {
  HaritaNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }
  final Ref ref;

  // Başlangıçta kullanıcının konumuna göre mekanları getir
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
      final apiService = ref.read(mekanServiceProvider);
      final mekanlar = await apiService.getYakindakiMekanlar(enlem: enlem, boylam: boylam, mesafe:mesafe,);
      state = AsyncData(mekanlar);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

// 3. Ana Arayüz Widget'ı
class HaritaEkrani extends ConsumerStatefulWidget {
  const HaritaEkrani({super.key});

  @override
  ConsumerState<HaritaEkrani> createState() => _HaritaEkraniState();
}
class _HaritaEkraniState extends ConsumerState<HaritaEkrani> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _haritaMerkezi;

  @override
  Widget build(BuildContext context) {
    final konumAsync = ref.watch(konumProvider);
    final mekanlarAsync = ref.watch(haritaProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final seciliMesafe = ref.watch(mesafeCapiProvider);
    
    return Scaffold(
      body: konumAsync.when(
        loading: () => const Center(child: Text("Konum alınıyor...")),
        error: (err, stack) => Center(child: Text('Konum alınamadı: $err')),
        data: (position) {
          _haritaMerkezi ??= LatLng(position.latitude, position.longitude);

          final Set<Circle> circles = {};
          if (_haritaMerkezi != null) {
            circles.add(
              Circle(
                circleId: const CircleId('arama_capi_id'), // Benzersiz bir ID
                center: _haritaMerkezi!, // Haritanın mevcut merkezi
                radius: seciliMesafe, // Slider'dan gelen mesafe (metre cinsinden)
                fillColor: Colors.blue.withOpacity(0.15), // İç dolgu rengi (şeffaf)
                strokeColor: Colors.blue.withOpacity(0.7), // Kenar çizgisi rengi
                strokeWidth: 1, // Kenar çizgisi kalınlığı
              ),
            );
          }

          return Column(
            children: [
              // HARİTA BÖLÜMÜ
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(target: _haritaMerkezi!, zoom: 14),
                      onMapCreated: (GoogleMapController controller) {
                        if (!_controller.isCompleted) {
                          _controller.complete(controller);
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: mekanlarAsync.maybeWhen(
                        data: (mekanlar) => mekanlar.map((mekan) => Marker(
                          markerId: MarkerId(mekan.id),
                          position: LatLng(mekan.konum.enlem, mekan.konum.boylam),
                          infoWindow: InfoWindow(title: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en),
                        )).toSet(),
                        orElse: () => {},
                      ),
                      onCameraMove: (CameraPosition position) {
                        _haritaMerkezi = position.target;
                      },
                    ),
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Bu Alanda Ara"),
                          onPressed: () {
                            if (_haritaMerkezi != null) {
                              ref.read(haritaProvider.notifier).fetchYakindakiMekanlar(
                                enlem: _haritaMerkezi!.latitude,
                                boylam: _haritaMerkezi!.longitude,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // FİLTRE VE LİSTE BÖLÜMÜ
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // YENİ EKLENDİ: MESAFE AYARLAMA SLIDER'I
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        children: [
                          Text("Mesafe: ${(seciliMesafe / 1000).toStringAsFixed(1)} km"),
                          Slider(
                            value: seciliMesafe,
                            min: 1000,
                            max: 50000,
                            divisions: 49,
                            label: "${(seciliMesafe / 1000).round()} km",
                            onChanged: (yeniDeger) {
                              ref.read(mesafeCapiProvider.notifier).state = yeniDeger;
                            },
                            onChangeEnd: (yeniDeger) {
                              if (_haritaMerkezi != null) {
                                ref.read(haritaProvider.notifier).fetchYakindakiMekanlar(
                                  enlem: _haritaMerkezi!.latitude,
                                  boylam: _haritaMerkezi!.longitude,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    // MEKAN LİSTESİ
                    Expanded(
                      child: mekanlarAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Center(child: Text('Mekanlar yüklenemedi: $e')),
                        data: (mekanlar) => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(10),
                          itemCount: mekanlar.length,
                          itemBuilder: (context, index) {
                            final mekan = mekanlar[index];
                            return _buildMekanKarti(context, mekan);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildMekanKarti(BuildContext context, MekanModel mekan) {
    final langCode = Localizations.localeOf(context).languageCode;
    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MekanDetayEkrani(mekanId: mekan.id),
              ),
            );
          },
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : 'https://placehold.co/600x400',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}