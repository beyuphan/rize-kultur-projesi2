import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/presentation/providers/api_service_provider.dart';
import 'package:mobil_flutter/presentation/features/venue/screens/mekan_detay_ekrani.dart';

// --- PROVIDER'LAR ---

final konumProvider = FutureProvider.autoDispose<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Lütfen konum servislerini açın.');

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

// YENİ: Arama yarıçapını (metre cinsinden) tutan provider
final searchRadiusProvider = StateProvider<double>((ref) => 10000.0); // Varsayılan 10km

final haritaProvider = StateNotifierProvider.autoDispose<HaritaNotifier, AsyncValue<List<MekanModel>>>((ref) {
  return HaritaNotifier(ref);
});

class HaritaNotifier extends StateNotifier<AsyncValue<List<MekanModel>>> {
  HaritaNotifier(this.ref) : super(const AsyncData([]));
  final Ref ref;
  bool _isFetching = false;

  Future<void> fetchMekanlar(LatLng merkez) async {
    if (_isFetching) return;
    _isFetching = true;
    state = AsyncLoading<List<MekanModel>>().copyWithPrevious(state);
    try {
      final apiService = ref.read(apiServiceProvider);
      final radius = ref.read(searchRadiusProvider);
      final mekanlar = await apiService.getYakindakiMekanlar(
        enlem: merkez.latitude,
        boylam: merkez.longitude,
        mesafe: radius,
      );
      state = AsyncData(mekanlar);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    } finally {
      _isFetching = false;
    }
  }
}

// --- ANA ARAYÜZ WIDGET'I ---
class HaritaEkrani extends ConsumerStatefulWidget {
  const HaritaEkrani({super.key});

  @override
  ConsumerState<HaritaEkrani> createState() => _HaritaEkraniState();
}

class _HaritaEkraniState extends ConsumerState<HaritaEkrani> {
  final Completer<GoogleMapController> _mapController = Completer();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  Set<Marker> _markers = {};
  int _selectedIndex = -1;
  Timer? _debounce;
  bool _isProgrammaticMove = false;
  LatLng _currentMapCenter = const LatLng(41.0201, 40.5235);

  BitmapDescriptor? _markerIconDefault;
  BitmapDescriptor? _markerIconSelected;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    _markerIconDefault = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)), 'assets/images/marker_default.png');
    _markerIconSelected = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)), 'assets/images/marker_selected.png');
    setState(() {}); // İkonlar yüklenince marker'ları yeniden çizmek için
  }

  void _updateMarkers(List<MekanModel> mekanlar) {
    if (!mounted) return;
    final langCode = Localizations.localeOf(context).languageCode;
    final newMarkers = mekanlar.asMap().entries.map((entry) {
      final index = entry.key;
      final mekan = entry.value;
      return Marker(
        markerId: MarkerId(mekan.id),
        position: LatLng(mekan.konum.enlem, mekan.konum.boylam),
        icon: index == _selectedIndex ? (_markerIconSelected ?? BitmapDescriptor.defaultMarker) : (_markerIconDefault ?? BitmapDescriptor.defaultMarker),
        infoWindow: InfoWindow(title: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en),
        onTap: () {
          if (_selectedIndex != index) {
            _onMarkerTapped(index);
          }
        },
      );
    }).toSet();

    setState(() {
      _markers = newMarkers;
    });
  }

  void _onMarkerTapped(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
    _updateMarkers(ref.read(haritaProvider).value ?? []);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) async {
    if (_selectedIndex == index) return;

    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });

    _updateMarkers(ref.read(haritaProvider).value ?? []);

    _isProgrammaticMove = true;
    final controller = await _mapController.future;
    final mekan = ref.read(haritaProvider).value![index];
    controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(mekan.konum.enlem, mekan.konum.boylam)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _getOptimizedImageUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty || !originalUrl.contains('res.cloudinary.com')) {
      return 'https://placehold.co/600x400/CCCCCC/4f4f4f?text=G%C3%B6rsel+Yok';
    }
    const transformations = 'w_400,h_400,c_fill,q_auto,f_auto';
    final parts = originalUrl.split('upload/');
    if (parts.length != 2) return originalUrl;
    return '${parts[0]}upload/$transformations/${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final konumAsync = ref.watch(konumProvider);
     ref.listen<AsyncValue<List<MekanModel>>>(haritaProvider, (_, state) {
      state.whenOrNull(
        data: (mekanlar) => _updateMarkers(mekanlar),
        error: (e, s) => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("Mekanlar yüklenemedi: $e"))),
      );
    });
    
    return Scaffold(
      body: konumAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Konum hatası: $err')),
        data: (position) {
          return Stack(
            children: [
              _buildGoogleMap(position),
              _buildFilterButton(),
              _buildBottomResultsPanel(position),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoogleMap(Position initialPosition) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(initialPosition.latitude, initialPosition.longitude),
        zoom: 12.0,
      ),
      onMapCreated: (controller) async {
        if (!_mapController.isCompleted) {
          _mapController.complete(controller);
          try {
            String style = await rootBundle.loadString('assets/map_style.json');
            controller.setMapStyle(style);
          } catch (e) {
            print("Harita stili yüklenemedi: $e");
          }
          final center = LatLng(initialPosition.latitude, initialPosition.longitude);
          setState(() { _currentMapCenter = center; });
          ref.read(haritaProvider.notifier).fetchMekanlar(center);
        }
      },
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(bottom: 180, top: 100),
      onCameraMove: (position) {
        setState(() {
          _currentMapCenter = position.target;
        });
      },
      onCameraIdle: () {
        if (_isProgrammaticMove) {
          _isProgrammaticMove = false;
          return;
        }
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 1200), () {
          if (_currentMapCenter != null) {
            ref.read(haritaProvider.notifier).fetchMekanlar(_currentMapCenter!);
          }
        });
      },
    );
  }

  Widget _buildFilterButton() {
    return Positioned(
      top: 50,
      right: 16,
      child: FloatingActionButton.small(
        heroTag: 'filterButton', // Aynı ekranda birden fazla FAB varsa heroTag eklenmeli
        onPressed: _showFilterSheet,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 4,
        child: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final radius = ref.watch(searchRadiusProvider);
          return Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Arama Yarıçapı: ${(radius / 1000).toStringAsFixed(1)} km", style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  value: radius,
                  min: 1000, max: 50000,
                  divisions: 49,
                  label: "${(radius / 1000).round()} km",
                  onChanged: (yeniDeger) => ref.read(searchRadiusProvider.notifier).state = yeniDeger,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Bu Alanda Ara"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_currentMapCenter != null) {
                       ref.read(haritaProvider.notifier).fetchMekanlar(_currentMapCenter!);
                    }
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomResultsPanel(Position currentUserPosition) {
    final mekanlarAsync = ref.watch(haritaProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

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
              theme.scaffoldBackgroundColor.withOpacity(1),
              theme.scaffoldBackgroundColor.withOpacity(1),
              theme.scaffoldBackgroundColor.withOpacity(0),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: mekanlarAsync.when(
            loading: () => const Center(key: ValueKey('loading'), child: CircularProgressIndicator()),
            error: (e,s) => Center(key: const ValueKey('error'), child: Text("Hata: $e")),
            data: (mekanlar) => mekanlar.isEmpty
                ? Center(key: const ValueKey('empty'), child: Text("Bu alanda mekan bulunamadı.", style: theme.textTheme.bodyLarge))
                : PageView.builder(
                    key: const ValueKey('data'),
                    controller: _pageController,
                    itemCount: mekanlar.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final mekan = mekanlar[index];
                      final distance = Geolocator.distanceBetween(
                        _currentMapCenter?.latitude ?? currentUserPosition.latitude,
                        _currentMapCenter?.longitude ?? currentUserPosition.longitude,
                        mekan.konum.enlem,
                        mekan.konum.boylam,
                      );

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MekanDetayEkrani(mekanId: mekan.id))),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Image.network(
                                    _getOptimizedImageUrl(mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : null),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.social_distance_rounded, size: 16, color: theme.colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${(distance / 1000).toStringAsFixed(1)} km uzakta",
                                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                                            ),
                                          ],
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
      ),
    );
  }
}