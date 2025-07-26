// lib/presentation/screens/kesfet_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/widgets/mekan_karti.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/screens/mekan_listesi_ekrani.dart';

// Kategori verilerini tutmak için basit bir sınıf
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
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    
    // VİTRİN İÇİN VERİYİ ÇEKİYORUZ
    final populerMekanlarAsync = ref.watch(populerMekanlarProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // --- BAŞLIK VE ARAMA ÇUBUĞU ---
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 150.0,
            floating: false,
            pinned: true, // Arama çubuğunun yukarıda kalmasını sağlar
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              centerTitle: true,
              title: TextField(
                onSubmitted: (sorgu) {
                  if (sorgu.trim().isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MekanListesiEkrani(
                        sayfaBasligi: "'$sorgu' ${l10n.searchResults}",
                        ilkFiltre: MekanFiltresi(aramaSorgusu: sorgu.trim()),
                      ),
                    ));
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              background: Padding(
                padding: const EdgeInsets.only(bottom: 56.0, left: 16, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.welcome, style: theme.textTheme.headlineMedium),
                  ],
                ),
              ),
            ),
          ),

          // --- BANNER SLIDER ---
          _BannerSlider(),

          // --- KATEGORİLER ---
          _buildSectionHeader(context, l10n.categories),
          SliverToBoxAdapter(child: _CategoryList()),

          // --- POPÜLER MEKANLAR ---
          _buildSectionHeader(context, l10n.popularVenues, onTapSeeAll: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MekanListesiEkrani(
                sayfaBasligi: l10n.popularVenues,
                ilkFiltre: MekanFiltresi(sortBy: 'puan'),
              ),
            ));
          }),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: populerMekanlarAsync.when(
                loading: () => _buildLoadingSkeleton(),
                error: (err, stack) => Center(child: Text('Hata: $err')),
                data: (response) {
                  final mekanlar = response.mekanlar;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: mekanlar.length,
                    itemBuilder: (context, index) {
                      final mekan = mekanlar[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 220,
                          child: MekanKarti(
                            isim: langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                            kategori: mekan.kategori,
                            puan: mekan.ortalamaPuan,
                            imageUrl: mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : null,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MekanDetayEkrani(mekanId: mekan.id),
                            )),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // Gelecekte buraya "Yeni Eklenenler" gibi yeni bölümler ekleyebilirsin
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // Bölüm başlığı için yardımcı widget
  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onTapSeeAll}) {
    final l10n = AppLocalizations.of(context)!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (onTapSeeAll != null)
              InkWell(
                onTap: onTapSeeAll,
                child: Text(
                  l10n.seeAll,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Banner Slider için ayrı bir widget
class _BannerSlider extends StatelessWidget {
  final List<String> bannerImages = const [
    'https://www.tourturka.com/images/blog/medium/wc3nsc/wc3nsc_830.webp',
    'https://www.ribiad.com/tema/ribiad/uploads/sayfalar/rize.jpg',
    'https://www.doka.org.tr/dosyalar/page_109/1554895355_1.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CarouselSlider.builder(
        itemCount: bannerImages.length,
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(bannerImages[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 150.0,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
        ),
      ),
    );
  }
}

// Kategorileri ve mantığını kendi widget'ına ayırmak daha temizdir
class _CategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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

    return SizedBox(
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
            // Kategori seçme mantığı artık direkt yönlendirme yapıyor
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MekanListesiEkrani(
                  sayfaBasligi: getTranslatedCategory(category.key),
                  ilkFiltre: MekanFiltresi(kategori: category.key),
                ),
              ));
            },
          );
        },
      ),
    );
  }
}

// Kategori ikonu için ayrı widget
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
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

// Yüklenme iskeleti için yardımcı widget
Widget _buildLoadingSkeleton() {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    itemCount: 3,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    },
  );
}