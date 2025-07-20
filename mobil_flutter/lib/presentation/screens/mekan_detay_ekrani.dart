import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/widgets/fotograf_galerisi.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
import 'package:mobil_flutter/presentation/widgets/puanlama_girdisi.dart';
import 'package:mobil_flutter/presentation/widgets/yorum_karti.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';


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

//--- SAYFA 1: ANA DETAY (SON TASARIM) ---
class _AnaDetaySayfasi extends ConsumerStatefulWidget {
  final MekanModel mekan;
  const _AnaDetaySayfasi({required this.mekan});

  @override
  ConsumerState<_AnaDetaySayfasi> createState() => __AnaDetaySayfasiState();
}

class __AnaDetaySayfasiState extends ConsumerState<_AnaDetaySayfasi> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    final userAsync = ref.watch(userProfileProvider);
    final userId = userAsync.value?.id;
    final user = userAsync.value;

    final eslesenYorumlar = widget.mekan.yorumlar.where((yorum) => yorum.yazar.id == userId);
    final YorumModel? kullaniciYorumu = eslesenYorumlar.isNotEmpty ? eslesenYorumlar.first : null;
    final double mevcutKullaniciPuani = kullaniciYorumu?.puan ?? 0.0;

    ref.listen<AsyncValue<void>>(yorumSubmitProvider, (_, state) {
      if (!mounted) return;
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ${state.error.toString()}')));
      } else if (state is AsyncData && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değerlendirmeniz başarıyla gönderildi!')));
      }
    });

    final yorumState = ref.watch(yorumSubmitProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                langCode == 'tr' ? widget.mekan.isim.tr : widget.mekan.isim.en,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2.0)]),
              ),
              titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
            ),
            actions: [
              if (user != null)
              Consumer(builder: (context, ref, child) {
                // Favori durumunu anlık olarak kontrol et
                final isFavorited = user.favoriMekanlar.contains(widget.mekan.id);
                
                return IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.redAccent : Colors.white,
                  ),
                  onPressed: () {
                    // Butona basıldığında Notifier'daki metodu çağır
                    ref.read(userProfileProvider.notifier).toggleFavorite(widget.mekan.id);
                  },
                );
              }),
                    ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text(
"ortalaama puan",
                              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(width: 8),
                            PuanGostergesi(puan: widget.mekan.ortalamaPuan, iconSize: 22),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.mekan.ortalamaPuan.toStringAsFixed(1)} (${widget.mekan.yorumlar.length})',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (userId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                l10n.yourRating,
                                style: theme.textTheme.titleSmall,
                              ),
                              if (yorumState.isLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                                )
                              else
                                PuanlamaGirdisi(
                                  baslangicPuani: mevcutKullaniciPuani,
                                  iconBoyutu: 36,
                                  onPuanDegisti: (yeniPuan) {
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
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    langCode == 'tr' ? widget.mekan.aciklama.tr : widget.mekan.aciklama.en,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions_outlined),
                      label: Text(l10n.getDirections),
                      onPressed: () => _haritayiAc(widget.mekan.konum.enlem, widget.mekan.konum.boylam),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: theme.textTheme.titleMedium),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.mekan.fotograflar.length > 1) ...[
            _buildSectionHeader(theme, l10n.photos),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: FotografGalerisi(imageUrls: widget.mekan.fotograflar),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
        child: Text(title, style: theme.textTheme.titleLarge),
      ),
    );
  }
}

//--- SAYFA 2: YORUMLAR (AKILLI MANTIK) ---
class _YorumlarSayfasi extends ConsumerStatefulWidget {
  final MekanModel mekan;
  const _YorumlarSayfasi({required this.mekan});

  @override
  ConsumerState<_YorumlarSayfasi> createState() => _YorumlarSayfasiState();
}

class _YorumlarSayfasiState extends ConsumerState<_YorumlarSayfasi> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;
    final userId = userAsync.value?.id;

    final eslesenYorumlar = widget.mekan.yorumlar.where((yorum) => yorum.yazar.id == userId);
    final YorumModel? kullaniciYorumu = eslesenYorumlar.isNotEmpty ? eslesenYorumlar.first : null;
    final bool kullaniciMetinliYorumYaptiMi = kullaniciYorumu != null && (kullaniciYorumu.icerik?.trim().isNotEmpty ?? false);
    final digerYorumlar = widget.mekan.yorumlar.where((yorum) => yorum.yazar.id != userId).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${langCode == 'tr' ? widget.mekan.isim.tr : widget.mekan.isim.en} - ${l10n.reviews}'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: digerYorumlar.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "yorum yok şuan",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: digerYorumlar.length,
                    itemBuilder: (context, index) {
                      final yorum = digerYorumlar[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: YorumKarti(
                          kullaniciAdi: yorum.yazar.kullaniciAdi,
                          puan: yorum.puan,
                          yorum: yorum.icerik,
                          kullaniciImageUrl: yorum.yazar.profilFotoUrl,
                          yorumTarihi: yorum.yorumTarihi,
                        ),
                      );
                    },
                  ),
          ),
          if (userId != null)
            if (kullaniciMetinliYorumYaptiMi && !_isEditing)
              _KullaniciYorumuGoster(
                yorum: kullaniciYorumu!,
                onEditPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              )
            else
              _YorumYazmaAlani(
                mekanId: widget.mekan.id,
                duzenlenecekYorum: kullaniciYorumu,
                onCommentSubmitted: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
              ),
        ],
      ),
    );
  }
}

//--- KULLANICININ KENDİ YORUMUNU GÖSTEREN WIDGET ---
class _KullaniciYorumuGoster extends StatelessWidget {
  final YorumModel yorum;
  final VoidCallback onEditPressed;
  const _KullaniciYorumuGoster({required this.yorum, required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.yourComment, style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: Text(l10n.edit),
                onPressed: onEditPressed,
              )
            ],
          ),
          const SizedBox(height: 8),
          YorumKarti(
            kullaniciAdi: yorum.yazar.kullaniciAdi,
            puan: yorum.puan,
            yorum: yorum.icerik,
            kullaniciImageUrl: yorum.yazar.profilFotoUrl,
            yorumTarihi: yorum.yorumTarihi,
          ),
        ],
      ),
    );
  }
}

//--- YORUM YAZMA ALANI WIDGET'I ---
class _YorumYazmaAlani extends ConsumerStatefulWidget {
  final String mekanId;
  final YorumModel? duzenlenecekYorum;
  final VoidCallback? onCommentSubmitted;

  const _YorumYazmaAlani({
    required this.mekanId,
    this.duzenlenecekYorum,
    this.onCommentSubmitted,
  });

  @override
  ConsumerState<_YorumYazmaAlani> createState() => __YorumYazmaAlaniState();
}

class __YorumYazmaAlaniState extends ConsumerState<_YorumYazmaAlani> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.duzenlenecekYorum?.icerik ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _yorumGonder() {
    final icerik = _controller.text.trim();
    if (icerik.isEmpty && widget.duzenlenecekYorum?.puan == null) return;

    ref.read(yorumSubmitProvider.notifier).gonder(
          mekanId: widget.mekanId,
          icerik: icerik,
        );
    
    _controller.clear();
    FocusScope.of(context).unfocus();
    widget.onCommentSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(userProfileProvider);
    final yorumState = ref.watch(yorumSubmitProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
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
              decoration: InputDecoration(
                hintText: l10n.addComment,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
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