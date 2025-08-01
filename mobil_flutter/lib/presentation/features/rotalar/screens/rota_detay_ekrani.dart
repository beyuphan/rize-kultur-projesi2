import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/rota_providers.dart';
import 'package:mobil_flutter/presentation/features/venue/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/widgets/sliver_tab_bar_delegate.dart';

// Yeni oluşturduğumuz widget'ları import ediyoruz
import '../widgets/rota_bilgi_karti.dart';
import '../widgets/rota_duraklari_tab.dart';
import '../widgets/rota_mekanlar_tab.dart';
import '../widgets/rota_bilgiler_tab.dart';

class RotaDetayEkrani extends ConsumerWidget {
  final String rotaId;
  const RotaDetayEkrani({super.key, required this.rotaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotaDetayAsync = ref.watch(rotaDetayProvider(rotaId));
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: rotaDetayAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Rota yüklenemedi: $err")),
        data: (rota) {
          return DefaultTabController(
            length: 3,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(Localizations.localeOf(context).languageCode == 'tr' ? rota.ad.tr : rota.ad.en),
                    background: Image.network(rota.kapakFotografiUrl, fit: BoxFit.cover),
                  ),
                  actions: [ /* Favori, Paylaş butonları */ ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RotaBilgiKarti(rota: rota),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      tabs: [
                        Tab(icon: const Icon(Icons.map_outlined), text: l10n.route),
                        Tab(icon: const Icon(Icons.place_outlined), text: l10n.places),
                        Tab(icon: const Icon(Icons.info_outline), text: l10n.information),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      RotaDuraklariTab(mekanlar: rota.mekanlar),
                      RotaMekanlarTab(mekanlar: rota.mekanlar),
                      const RotaBilgilerTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartRouteDialog(context, l10n),
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.startRoute),
      ),
    );
  }
}

// --- BU DOSYADA KALMASI GEREKEN YARDIMCI FONKSİYONLAR ---

// showMekanDetay fonksiyonunu public (alt çizgisiz) yapıyoruz
void showMekanDetay(BuildContext context, MekanModel mekan, AppLocalizations l10n, String langCode) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : 'https://placehold.co/600x400',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    langCode == 'tr' ? mekan.aciklama.tr : mekan.aciklama.en,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: Text("Tüm Detayları Gör"),
                      onPressed: () {
                        Navigator.pop(context); // Önce paneli kapat
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => MekanDetayEkrani(mekanId: mekan.id)));
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showStartRouteDialog(BuildContext context, AppLocalizations l10n) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.startRoute),
      content: Text(l10n.startRouteConfirmation),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rota başlatılıyor... GPS açılıyor.')));
          },
          child: const Text('Başlat'),
        ),
      ],
    ),
  );
}

// Bu yardımcı widget'ı genel widgets klasörüne taşımak en iyisi
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverTabBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}