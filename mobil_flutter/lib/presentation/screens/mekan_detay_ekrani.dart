import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/widgets/ana_detay_sayfasi.dart';
import 'package:mobil_flutter/presentation/widgets/yorumlar_sayfasi.dart';




//--- ANA WIDGET: SAYFA GEÇİŞİNİ YÖNETİR ---
class MekanDetayEkrani extends ConsumerStatefulWidget {
  final String mekanId;
  const MekanDetayEkrani({super.key, required this.mekanId});

  @override
  ConsumerState<MekanDetayEkrani> createState() => _MekanDetayEkraniState();
}

class _MekanDetayEkraniState extends ConsumerState<MekanDetayEkrani> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncMekan = ref.watch(mekanDetayProvider(widget.mekanId));

    return Scaffold(
      body: asyncMekan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(child: Text('Mekan yüklenemedi: $err')),
          ),
        ),
        data: (mekan) {
          return Stack(
            children: [
              PageView(
                controller: _pageController,
                children: [
                  AnaDetaySayfasi(mekan: mekan),
                  YorumlarSayfasi(mekan: mekan),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

