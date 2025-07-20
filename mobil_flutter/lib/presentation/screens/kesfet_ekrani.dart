// lib/presentation/screens/kesfet_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mobil_flutter/presentation/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';

class Category {
  final String key;
  final IconData icon;

  Category({required this.key, required this.icon});
}

class KesfetEkrani extends ConsumerWidget {
  const KesfetEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final langCode = locale.languageCode;
    final theme = Theme.of(context);
    final seciliKategoriKey = ref.watch(seciliKategoriProvider);

    final mekanlarAsyncValue = ref.watch(nihaiMekanlarProvider(locale));

    final List<Category> categories = [
      Category(key: 'categoryAll', icon: Icons.public),
      Category(key: 'categoryPlateaus', icon: Icons.terrain),
      Category(key: 'categoryWaterfalls', icon: Icons.waterfall_chart),
      Category(key: 'categoryRestaurants', icon: Icons.restaurant),
      Category(key: 'categoryHistorical', icon: Icons.account_balance),
    ];

    String getTranslatedCategory(String key) {
      switch (key) {
        case 'categoryAll':
          return l10n.categoryAll;
        case 'categoryPlateaus':
          return l10n.categoryPlateaus;
        case 'categoryWaterfalls':
          return l10n.categoryWaterfalls;
        case 'categoryRestaurants':
          return l10n.categoryRestaurants;
        case 'categoryHistorical':
          return l10n.categoryHistorical;
        default:
          return key;
      }
    }

    final List<String> bannerImages = [
      'https://www.tourturka.com/images/blog/medium/wc3nsc/wc3nsc_830.webp',
      'https://www.ribiad.com/tema/ribiad/uploads/sayfalar/rize.jpg',
      'https://www.doka.org.tr/dosyalar/page_109/1554895355_1.png',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.welcome, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  TextField(
                    onChanged: (sorgu) {
                      ref.read(aramaSorgusuProvider.notifier).state = sorgu;
                    },
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
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CarouselSlider(
              options: CarouselOptions(
                height: 150.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: bannerImages
                  .map(
                    (image) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader(context, l10n.categories, l10n.seeAll),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryIcon(
                        icon: category.icon,
                        label: getTranslatedCategory(category.key),
                        isActive: seciliKategoriKey == category.key,
                        onTap: () {
                          ref.read(seciliKategoriProvider.notifier).state =
                              category.key;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader(context, l10n.popularVenues, l10n.seeAll),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: mekanlarAsyncValue.when(
                loading: () => _buildLoadingSkeleton(),
                error: (err, stack) => Center(child: Text('Hata: $err')),
                data: (List<MekanModel> mekanlar) {
                  if (mekanlar.isEmpty) {
                    return Center(
                      child: Text(l10n.noVenuesFound), // l10n kullanımı
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 0, right: 20),
                    itemCount: mekanlar.length,
                    itemBuilder: (context, index) {
                      final mekan = mekanlar[index];
                      return MekanKarti(
                        isim: (langCode == 'tr' ? mekan.isim.tr : mekan.isim.en),
                        kategori: getTranslatedCategory(mekan.kategori),
                        puan: mekan.ortalamaPuan,
                        imageUrl: mekan.fotograflar.isNotEmpty
                            ? mekan.fotograflar[0]
                            : 'https://placehold.co/600x400/EEE/31343C?text=Foto%C4%9Fraf\\nYok',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MekanDetayEkrani(mekanId: mekan.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String seeAllText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(
            seeAllText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
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
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
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

Widget _buildLoadingSkeleton() {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.only(left: 20),
    itemCount: 3,
    itemBuilder: (context, index) {
      return Container(
        width: 220,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
        ),
      );
    },
  );
}
