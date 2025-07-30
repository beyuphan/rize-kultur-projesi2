// lib/presentation/features/rotalar/screens/rota_detay_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/rota_providers.dart';
import 'package:mobil_flutter/presentation/features/venue/screens/mekan_detay_ekrani.dart';
import 'package:mobil_flutter/presentation/widgets/sliver_tab_bar_delegate.dart';
 import 'package:url_launcher/url_launcher.dart';

 
 Future<void> _haritayiAc(double lat, double lon) async {
    final Uri mapsUri = Uri.parse('geo:$lat,$lon');
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      }
    } catch (e) {
      debugPrint('Harita açılamadı: $e');
    }
  }

class RotaDetayEkrani extends ConsumerWidget {
  final String rotaId;

  const RotaDetayEkrani({super.key, required this.rotaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotaDetayAsync = ref.watch(rotaDetayProvider(rotaId));
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

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
                    title: Text(
                      langCode == 'tr' ? rota.ad.tr : rota.ad.en,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black54)],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          rota.kapakFotografiUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 50)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // TODO: Favori ve Paylaş butonları buraya eklenecek
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(langCode == 'tr' ? rota.aciklama.tr : rota.aciklama.en, style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoChip(
                                  icon: Icons.timer_outlined,
                                  label: l10n.duration,
                                  value: langCode == 'tr' ? rota.tahminiSure.tr : rota.tahminiSure.en,
                                  color: Colors.blue,
                                ),
                                _buildInfoChip(
                                  icon: Icons.hiking,
                                  label: l10n.difficulty,
                                  value: langCode == 'tr' ? rota.zorlukSeviyesi.tr : rota.zorlukSeviyesi.en,
                                  color: Colors.orange,
                                ),
                                _buildInfoChip(
                                  icon: Icons.location_on_outlined,
                                  label: l10n.stops,
                                  value: '${rota.mekanlar.length} ${l10n.stops}',
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
                      _buildRotaTab(context, rota.mekanlar, langCode),
                      _buildMekanlarTab(context, rota.mekanlar, langCode),
                      _buildBilgilerTab(context, l10n),
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

// --- YARDIMCI WIDGET'LAR VE FONKSİYONLAR ---

Widget _buildInfoChip({required IconData icon, required String label, required String value, required Color color}) {
  return Column(
    children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    ],
  );
}

Widget _buildRotaTab(BuildContext context, List<MekanModel> mekanlar, String langCode) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: mekanlar.length,
    itemBuilder: (context, index) {
      final mekan = mekanlar[index];
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          title: Text(langCode == 'tr' ? mekan.isim.tr : mekan.isim.en, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(langCode == 'tr' ? mekan.aciklama.tr : mekan.aciklama.en, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => _showMekanDetay(context, mekan, langCode), // DÜZELTME
                  ),
      );
    },
  );
}

Widget _buildMekanlarTab(BuildContext context, List<MekanModel> mekanlar, String langCode) {
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12,
    ),
    itemCount: mekanlar.length,
    itemBuilder: (context, index) {
      final mekan = mekanlar[index];
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showMekanDetay(context, mekan, langCode), // DÜZELTME
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: Image.network(mekan.fotograflar.isNotEmpty ? mekan.fotograflar[0] : 'https://placehold.co/600x400', fit: BoxFit.cover)),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    langCode == 'tr' ? mekan.isim.tr : mekan.isim.en,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


// YENİDEN EKLENEN FONKSİYON: Aşağıdan yukarı kayan panel
void _showMekanDetay(BuildContext context, MekanModel mekan, String langCode) {
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
                      icon: const Icon(Icons.directions_outlined),
                      label: Text("haritaAç"),
                      onPressed: () => _haritayiAc(mekan.konum.enlem, mekan.konum.boylam),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(height: 18),

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


Widget _buildBilgilerTab(BuildContext context, AppLocalizations l10n) {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.backpack, color: Theme.of(context).primaryColor), const SizedBox(width: 8), Text(l10n.routePreparation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const Divider(height: 24),
              _buildPreparationItem(context, Icons.checkroom, l10n.clothing, l10n.clothingDescription),
              _buildPreparationItem(context, Icons.water_drop, l10n.water, l10n.waterDescription),
              _buildPreparationItem(context, Icons.restaurant, l10n.food, l10n.foodDescription),
              _buildPreparationItem(context, Icons.medical_services, l10n.firstAid, l10n.firstAidDescription),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.security, color: Theme.of(context).primaryColor), const SizedBox(width: 8), Text(l10n.safetyTips, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const Divider(height: 24),
              _buildSafetyTip(context, l10n.checkWeather),
              _buildSafetyTip(context, l10n.travelInGroup),
              _buildSafetyTip(context, l10n.askLocalGuides),
              _buildSafetyTip(context, l10n.emergencyContacts),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildPreparationItem(BuildContext context, IconData icon, String title, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSafetyTip(BuildContext context, String tip) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
      ],
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

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
