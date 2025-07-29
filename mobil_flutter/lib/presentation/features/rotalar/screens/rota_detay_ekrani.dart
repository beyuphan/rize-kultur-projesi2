import 'package:flutter/material.dart';
import 'package:mobil_flutter/data/models/rota_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

class RotaDetayEkrani extends StatefulWidget {
  final Rota rota;

  const RotaDetayEkrani({super.key, required this.rota});

  @override
  State<RotaDetayEkrani> createState() => _RotaDetayEkraniState();
}

class _RotaDetayEkraniState extends State<RotaDetayEkrani>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dinamik anahtarları metne çevirmek için yardımcı fonksiyon
  String _translate(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      // Rota Adları
      case 'firtinaVadisiName':
        return l10n.firtinaVadisiName;
      case 'kackarlarZirveName':
        return l10n.kackarlarZirveName;
      case 'cayBahceleriName':
        return l10n.cayBahceleriName;
      // Açıklamalar
      case 'firtinaVadisiDescription':
        return l10n.firtinaVadisiDescription;
      case 'kackarlarZirveDescription':
        return l10n.kackarlarZirveDescription;
      case 'cayBahceleriDescription':
        return l10n.cayBahceleriDescription;
      // Süreler
      case 'firtinaVadisiDuration':
        return l10n.firtinaVadisiDuration;
      case 'kackarlarZirveDuration':
        return l10n.kackarlarZirveDuration;
      case 'cayBahceleriDuration':
        return l10n.cayBahceleriDuration;
      // Zorluklar
      case 'firtinaVadisiDifficulty':
        return l10n.firtinaVadisiDifficulty;
      case 'kackarlarZirveDifficulty':
        return l10n.kackarlarZirveDifficulty;
      case 'cayBahceleriDifficulty':
        return l10n.cayBahceleriDifficulty;
      default:
        return 'Key Not Found';
    }
  }

  // Örnek mekan verileri - gerçek veritabanından gelecek
  Map<String, Map<String, dynamic>> _getMekanBilgileri() {
    return {
      'mekan_zil_kalesi': {
        'ad': 'Zil Kalesi',
        'aciklama': 'Tarihi Zil Kalesi, muhteşem manzarası ile ünlü',
        'konum': 'Çamlıhemşin, Rize',
        'sure': '45 dakika',
        'fotograf': 'https://example.com/zil_kalesi.jpg',
        'koordinat': '41.0542, 40.8542',
        'ozellikler': ['Tarihi Yapı', 'Manzara', 'Fotoğraf Çekimi'],
      },
      'mekan_palovit_selalesi': {
        'ad': 'Palovit Şelalesi',
        'aciklama': 'Doğal güzelliği ile büyüleyen şelale',
        'konum': 'Çamlıhemşin, Rize',
        'sure': '30 dakika',
        'fotograf': 'https://example.com/palovit.jpg',
        'koordinat': '41.0642, 40.8642',
        'ozellikler': ['Doğa', 'Şelale', 'Yürüyüş'],
      },
      'mekan_ayder_yaylasi': {
        'ad': 'Ayder Yaylası',
        'aciklama': 'Yeşil doğası ile ünlü yayla',
        'konum': 'Çamlıhemşin, Rize',
        'sure': '2 saat',
        'fotograf': 'https://example.com/ayder.jpg',
        'koordinat': '41.1042, 40.9542',
        'ozellikler': ['Yayla', 'Doğa', 'Kamp'],
      },
      'mekan_gito_yaylasi': {
        'ad': 'Gito Yaylası',
        'aciklama': 'Sakin ve huzurlu yayla atmosferi',
        'konum': 'Çamlıhemşin, Rize',
        'sure': '1.5 saat',
        'fotograf': 'https://example.com/gito.jpg',
        'koordinat': '41.1142, 40.9642',
        'ozellikler': ['Yayla', 'Huzur', 'Doğa Yürüyüşü'],
      },
      'mekan_kavrun_yaylasi': {
        'ad': 'Kavrun Yaylası',
        'aciklama': 'Yüksek rakımlı güzel yayla',
        'konum': 'Çamlıhemşin, Rize',
        'sure': '3 saat',
        'fotograf': 'https://example.com/kavrun.jpg',
        'koordinat': '41.1242, 40.9742',
        'ozellikler': ['Yüksek Rakım', 'Trekking', 'Manzara'],
      },
      'mekan_ziraat_botanik_cayi': {
        'ad': 'Ziraat Botanik Çayı',
        'aciklama': 'Organik çay bahçeleri ve üretim tesisi',
        'konum': 'Rize Merkez',
        'sure': '1 saat',
        'fotograf': 'https://example.com/caybahcesi.jpg',
        'koordinat': '41.0242, 40.5742',
        'ozellikler': ['Çay Bahçesi', 'Organik', 'Üretim Tesisi'],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mekanBilgileri = _getMekanBilgileri();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Büyük kapak fotoğrafı ile app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _translate(context, widget.rota.adKey),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.rota.kapakFotografiUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFavorite
                            ? l10n.addedToFavorites
                            : l10n.removedFromFavorites,
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Paylaşma işlevi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.routeSharing),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          // Rota bilgileri kartı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _translate(context, widget.rota.aciklamaKey),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.timer_outlined,
                              label: 'Süre',
                              value: _translate(
                                context,
                                widget.rota.tahminiSureKey,
                              ),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.hiking,
                              label: 'Zorluk',
                              value: _translate(
                                context,
                                widget.rota.zorlukSeviyesiKey,
                              ),
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.location_on,
                              label: 'Mekan Sayısı',
                              value: '${widget.rota.mekanIdleri.length} Durak',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.star,
                              label: 'Puan',
                              value: '4.5/5',
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: const Icon(Icons.map), text: l10n.route),
                  Tab(icon: const Icon(Icons.place), text: l10n.places),
                  Tab(icon: const Icon(Icons.info), text: l10n.information),
                ],
              ),
            ),
          ),
          // Tab view içeriği
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRotaTab(mekanBilgileri),
                _buildMekanlarTab(mekanBilgileri),
                _buildBilgilerTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showStartRouteDialog(context);
        },
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.startRoute),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRotaTab(Map<String, Map<String, dynamic>> mekanBilgileri) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.rota.mekanIdleri.length,
      itemBuilder: (context, index) {
        final mekanId = widget.rota.mekanIdleri[index];
        final mekan = mekanBilgileri[mekanId];

        if (mekan == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              mekan['ad'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mekan['aciklama']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      mekan['sure'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mekan['konum'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showMekanDetay(context, mekan);
            },
          ),
        );
      },
    );
  }

  Widget _buildMekanlarTab(Map<String, Map<String, dynamic>> mekanBilgileri) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.rota.mekanIdleri.length,
      itemBuilder: (context, index) {
        final mekanId = widget.rota.mekanIdleri[index];
        final mekan = mekanBilgileri[mekanId];

        if (mekan == null) return const SizedBox.shrink();

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showMekanDetay(context, mekan),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mekan['ad'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mekan['aciklama'],
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              mekan['sure'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
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
        );
      },
    );
  }

  Widget _buildBilgilerTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hazırlık Kartı
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.backpack, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      l10n.routePreparation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildPreparationItem(
                  context,
                  Icons.checkroom,
                  l10n.clothing,
                  l10n.clothingDescription,
                ),
                _buildPreparationItem(
                  context,
                  Icons.water_drop,
                  l10n.water,
                  l10n.waterDescription,
                ),
                _buildPreparationItem(
                  context,
                  Icons.restaurant,
                  l10n.food,
                  l10n.foodDescription,
                ),
                _buildPreparationItem(
                  context,
                  Icons.medical_services,
                  l10n.firstAid,
                  l10n.firstAidDescription,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Güvenlik İpuçları Kartı
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      l10n.safetyTips,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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

  // Yardımcı widget'ları da güncelleyelim
  Widget _buildPreparationItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
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
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showMekanDetay(BuildContext context, Map<String, dynamic> mekan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mekan['ad'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mekan['aciklama'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(mekan['konum']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8),

                        Text('${l10n.recommendedTime}: ${mekan['sure']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.features,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (mekan['ozellikler'] as List<String>)
                          .map(
                            (ozellik) => Chip(
                              label: Text(ozellik),
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            ),
                          )
                          .toList(),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Harita açma işlevi
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${mekan['ad']} ${l10n.openingOnMap}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: Text(l10n.showOnMap),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartRouteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.startRoute),
        content: Text(l10n.startRouteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rota başlatılıyor... GPS açılıyor.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Başlat'),
          ),
        ],
      ),
    );
  }
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
