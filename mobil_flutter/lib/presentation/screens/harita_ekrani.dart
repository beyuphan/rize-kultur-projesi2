// lib/presentation/screens/harita_ekrani.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/presentation/providers/api_service_provider.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'mekan_detay_ekrani.dart';

// 1. Konum provider'ı
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

// 2. Harita Notifier ve Provider'ı
final haritaProvider = StateNotifierProvider.autoDispose<HaritaNotifier, AsyncValue<List<MekanModel>>>((ref) {
  return HaritaNotifier(ref);
});

class HaritaNotifier extends StateNotifier<AsyncValue<List<MekanModel>>> {
  HaritaNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }
  final Ref ref;

  Future<void> _init() async {
    try {
      final position = await ref.read(konumProvider.future);
      await fetchYakindakiMekanlar(enlem: position.latitude, boylam: position.longitude);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> fetchYakindakiMekanlar({required double enlem, required double boylam}) async {
    state = const AsyncLoading();
    try {
      // DÜZELTME: Doğru provider isimlerini kullanıyoruz
      final mesafe = ref.read(mesafeCapiProvider);
      final apiService = ref.read(apiServiceProvider); 
      final mekanlar = await apiService.getYakindakiMekanlar(enlem: enlem, boylam: boylam, mesafe: mesafe);
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
  // Harita her hareket ettiğinde sürekli arama yapmamak için bir bayrak
  bool _aramaButonuGoster = false;

  @override
  Widget build(BuildContext context) {
    final konumAsync = ref.watch(konumProvider);
    final mekanlarAsync = ref.watch(haritaProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final seciliMesafe = ref.watch(mesafeCapiProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Harita")), // Sayfaya bir başlık eklemek daha iyi olur
      body: konumAsync.when(
        loading: () => const Center(child: Text("Konum alınıyor...")),
        error: (err, stack) => Center(child: Text('Konum alınamadı: $err')),
        data: (position) {
          _haritaMerkezi ??= LatLng(position.latitude, position.longitude);

          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(target: _haritaMerkezi!, zoom: 11),
                      onMapCreated: (GoogleMapController controller) {
                        if (!_controller.isCompleted) _controller.complete(controller);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
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
                      onCameraMove: (CameraPosition position) {
                        setState(() {
                           _haritaMerkezi = position.target;
                           _aramaButonuGoster = true; // Harita hareket edince butonu göster
                        });
                      },
                      onCameraIdle: () {
                        // Kamera durduğunda yapılacaklar (istenirse)
                      },
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
                    ),
                    if (_aramaButonuGoster) // Sadece harita hareket ettiğinde butonu göster
                      Positioned(
                        top: 16,
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
                                setState(() => _aramaButonuGoster = false); // Aramadan sonra butonu gizle
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        children: [
                          Text("Arama Yarıçapı: ${(seciliMesafe / 1000).toStringAsFixed(1)} km"),
                          Slider(
                            value: seciliMesafe,
                            min: 1000,
                            max: 50000,
                            divisions: 49,
                            label: "${(seciliMesafe / 1000).round()} km",
                            onChanged: (yeniDeger) {
                              ref.read(mesafeCapiProvider.notifier).state = yeniDeger;
                            },
                            // Sadece kullanıcı slider'ı bıraktığında arama yap, sürekli değil
                            onChangeEnd: (yeniDeger) {
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
                    Expanded(
                      child: mekanlarAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Center(child: Text('Mekanlar yüklenemedi: $e')),
                        data: (mekanlar) => mekanlar.isEmpty
                            ? const Center(child: Text("Bu alanda mekan bulunamadı."))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(10),
                                itemCount: mekanlar.length,
                                itemBuilder: (context, index) {
                                  return _buildMekanKarti(context, mekanlar[index]);
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