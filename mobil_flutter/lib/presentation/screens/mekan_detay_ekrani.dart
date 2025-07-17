import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/screens/profil_ekrani.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/widgets/fotograf_galerisi.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
import 'package:mobil_flutter/presentation/widgets/puanlama_girdisi.dart';
import 'package:mobil_flutter/presentation/widgets/yorum_karti.dart';
import 'package:url_launcher/url_launcher.dart';

// ANA WIDGET: Sayfa geçişini ve göstergeyi yönetmek için StatefulWidget
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
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
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
        error: (err, stack) => Center(child: Text('Mekan yüklenemedi: $err')),
        data: (mekan) {
          return Stack(
            children: [
              PageView(
                controller: _pageController,
                children: [
                  _AnaDetaySayfasi(mekan: mekan),
                  _YorumlarSayfasi(mekan: mekan),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
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

// --- SAYFA 1: ANA DETAY SAYFASI (Doğru Yerleşimle) ---
class _AnaDetaySayfasi extends ConsumerStatefulWidget {
  final MekanModel mekan;
  const _AnaDetaySayfasi({required this.mekan});

  @override
  ConsumerState<_AnaDetaySayfasi> createState() => __AnaDetaySayfasiState();
}

class __AnaDetaySayfasiState extends ConsumerState<_AnaDetaySayfasi> {
  double _kullaniciPuani = 0;

  Future<void> _haritayiAc(double lat, double lon) async {
    final Uri mapsUri = Uri.parse('geo:$lat,$lon');
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        throw 'Harita uygulaması bulunamadı.';
      }
    } catch (e) {
      print('Harita açılamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;


     // Yorum gönderme durumunu dinle
    ref.listen<AsyncValue<void>>(yorumSubmitProvider, (_, state) {
      if (!mounted) return;
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ${state.error}')));
      }
      if (state is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Puanınız başarıyla gönderildi!')));
      }
    });

    final yorumState = ref.watch(yorumSubmitProvider);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // YAPI DÜZELTİLDİ: Artık her şey tek bir CustomScrollView içinde
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.mekan.fotograflar.isNotEmpty
                        ? widget.mekan.fotograflar[0]
                        : 'https://placehold.co/600x400/EEE/31343C?text=Foto%C4%9Fraf\\nYok',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                widget.mekan.isim,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2.0)],
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.mekan.ortalamaPuan.toStringAsFixed(1),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PuanGostergesi(
                            puan: widget.mekan.ortalamaPuan,
                            iconSize: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.reviewsCount("500+"),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.mekan.aciklama, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions_outlined),
                      label: Text(l10n.getDirections),
                      onPressed: () => _haritayiAc(
                        widget.mekan.konum.enlem,
                        widget.mekan.konum.boylam,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                   const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.yourRating, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        // DÜZENLENDİ: Eski Row yerine yeni widget'ımız
                        if (yorumState.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          PuanlamaGirdisi(
                            iconBoyutu: 36,
                            onPuanDegisti: (yeniPuan) {
                              // Butona basınca puanı gönder
                              ref.read(yorumSubmitProvider.notifier).gonder(
                                    mekanId: widget.mekan.id,
                                    puan: yeniPuan,
                                  );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // FOTOĞRAF GALERİSİ OLMASI GEREKEN YERDE
          if (widget.mekan.fotograflar.length > 1) ...[
            _buildSectionHeader(theme, l10n.photos),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0), // Altına boşluk
                child: FotografGalerisi(imageUrls: widget.mekan.fotograflar),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Başlıklar için yardımcı sliver widget'ı
  Widget _buildSectionHeader(ThemeData theme, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
        child: Text(title, style: theme.textTheme.titleLarge),
      ),
    );
  }
}

// --- SAYFA 2: YORUMLAR SAYFASI (Değişiklik yok) ---
class _YorumlarSayfasi extends StatelessWidget {
  final MekanModel mekan;
  const _YorumlarSayfasi({required this.mekan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${mekan.isim} - ${l10n.reviews}'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            // GÜNCELLENDİ: Artık API'den gelen gerçek yorumları gösteriyoruz
            child: mekan.yorumlar.isEmpty
                ? Center(child: Text(l10n.noCommentsYet))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: mekan.yorumlar.length,
                    itemBuilder: (context, index) {
                      final yorum = mekan.yorumlar[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: YorumKarti(
                          kullaniciAdi: yorum.yazar.kullaniciAdi,
                          puan: yorum.puan,
                          yorum: yorum.icerik,
                          kullaniciImageUrl: yorum.yazar.profilFotoUrl,
                          yorumTarihi: yorum.yorumTarihi, // YorumKarti'na bunu da eklemen gerekebilir.
                        ),
                      );
                    },
                  ),
          ),
          // Artık state yönetimi için StatefulWidget gerekiyor
          _YorumYazmaAlani(mekanId: mekan.id), 
        ],
      ),
    );
  }
}
// Yorum yapma alanı için güncellenmiş widget
class _YorumYazmaAlani extends ConsumerStatefulWidget {
  final String mekanId;
  const _YorumYazmaAlani({required this.mekanId});

  @override
  ConsumerState<_YorumYazmaAlani> createState() => __YorumYazmaAlaniState();
}

class __YorumYazmaAlaniState extends ConsumerState<_YorumYazmaAlani> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _yorumGonder() {
    final icerik = _controller.text.trim();
    if (icerik.isEmpty) return;

    ref.read(yorumSubmitProvider.notifier).gonder(
      mekanId: widget.mekanId,
      icerik: icerik,
    );
    _controller.clear(); // Gönderdikten sonra alanı temizle
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    // GÜNCELLENDİ: Giriş yapmış kullanıcının profilini izliyoruz
    final userAsync = ref.watch(userProfileProvider);
    final yorumState = ref.watch(yorumSubmitProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      decoration: BoxDecoration( /* ... aynı ... */ ),
      child: Row(
        children: [
          // GÜNCELLENDİ: Kullanıcının profil fotoğrafını gösteriyoruz
          userAsync.when(
            data: (user) => CircleAvatar(
              backgroundImage: (user.profilFotoUrl != null && user.profilFotoUrl!.isNotEmpty)
                  ? NetworkImage(user.profilFotoUrl!)
                  : null,
              child: (user.profilFotoUrl == null || user.profilFotoUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            loading: () => const CircleAvatar(child: CircularProgressIndicator()),
            error: (e, s) => const CircleAvatar(child: Icon(Icons.person)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration( /* ... aynı ... */),
            ),
          ),
          const SizedBox(width: 12),
          // GÜNCELLENDİ: Gönderme butonu artık çalışıyor
          if (yorumState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
            )
          else
            IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: _yorumGonder,
            ),
        ],
      ),
    );
  }
}