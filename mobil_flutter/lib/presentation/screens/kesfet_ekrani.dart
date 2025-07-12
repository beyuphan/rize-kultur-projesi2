import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart'; // Yeni ekranı import et

// Kategori verilerini tutmak için basit bir model sınıfı
class Category {
  final String key; // .arb dosyasındaki anahtar
  final IconData icon;

  Category({required this.key, required this.icon});
}

// Seçili olan kategorinin index'ini tutacak olan provider
final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);

class KesfetEkrani extends ConsumerWidget {
  const KesfetEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedIndex = ref.watch(selectedCategoryIndexProvider);

    final List<Category> categories = [
      Category(key: 'categoryAll', icon: Icons.public),
      Category(key: 'categoryPlateaus', icon: Icons.terrain),
      Category(key: 'categoryWaterfalls', icon: Icons.waterfall_chart),
      Category(key: 'categoryRestaurants', icon: Icons.restaurant),
      Category(key: 'categoryHistorical', icon: Icons.account_balance),
      Category(key: 'categoryNature', icon: Icons.local_florist),
    ];

    String getTranslatedCategory(String key) {
      switch (key) {
        case 'categoryAll': return l10n.categoryAll;
        case 'categoryPlateaus': return l10n.categoryPlateaus;
        case 'categoryWaterfalls': return l10n.categoryWaterfalls;
        case 'categoryRestaurants': return l10n.categoryRestaurants;
        case 'categoryHistorical': return l10n.categoryHistorical;
        case 'categoryNature': return l10n.categoryNature;
        default: return '';
      }
    }

    // Örnek banner görselleri (Bunları sonra dinamik hale getirebiliriz)
    final List<String> bannerImages = [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8F4TyuflGd3x5a7D5vtj3xTo2RSwSDYZtlA&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSM-sYc2p3e7f_J1YRpTk4Z_IfXiSCd1TvY7A&sr',
      'https://iahbr.tmgrup.com.tr/album/2018/04/22/cumhurbaskani-erdoganin-istegi-uzerine-insaa-edilen-kibledag-camii-ziyaretci-akinina-ugruyor-1524391503895.jpg',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(l10n.welcome, style: theme.textTheme.headlineMedium),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Arama alanı ile banner arası boşluk

            // Slider Banner Alanı
            CarouselSlider(
              options: CarouselOptions(
                height: 150.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: bannerImages.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24), // Banner ile kategoriler arası boşluk

            _buildSectionHeader(context, l10n.categories, l10n.seeAll),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  // DÜZELTME: Burada listenin tamamı yerine, o anki index'teki elemanı alıyoruz.
                  final category = categories[index]; 
                  return _CategoryIcon(
                    icon: category.icon,
                    label: getTranslatedCategory(category.key),
                    isActive: selectedIndex == index,
                    onTap: () {
                      ref.read(selectedCategoryIndexProvider.notifier).state = index;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l10n.popularVenues, l10n.seeAll),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 20, left: 0),
                children: [
                  MekanKarti(
                    isim: 'Zil Kale',
                    kategori: getTranslatedCategory('categoryHistorical'),
                    puan: 4.9,
                    imageUrl: 'https://karadenizturlari.com.tr/uploads/2021/12/ayder-gezisi.jpg',
                    onTap: () {
                    // Kart'a tıklandığında yeni sayfayı açıyoruz
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MekanDetayEkrani()),
                    );
                  },
                  ),
                  MekanKarti(
                    isim: 'Palovit Şelalesi',
                    kategori: getTranslatedCategory('categoryWaterfalls'),
                    puan: 5.0,
                    imageUrl: 'https://karadenizturlari.com.tr/uploads/2021/12/ayder-gezisi.jpg',
                    onTap: () {
                    // Kart'a tıklandığında yeni sayfayı açıyoruz
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MekanDetayEkrani()),
                    );
                  },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String seeAllText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(seeAllText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Icon(
                icon,
                color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
