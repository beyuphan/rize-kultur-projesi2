import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/widgets/fotograf_galerisi.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
import 'package:mobil_flutter/presentation/widgets/puanlama_girdisi.dart';
import 'package:mobil_flutter/presentation/widgets/yorumlar_sayfasi.dart';
import 'package:url_launcher/url_launcher.dart';

//--- SAYFA 1: ANA DETAY (SON TASARIM) ---
class AnaDetaySayfasi extends ConsumerStatefulWidget {
  final MekanModel mekan;
  const AnaDetaySayfasi({required this.mekan});

  @override
  ConsumerState<AnaDetaySayfasi> createState() => __AnaDetaySayfasiState();
}

class __AnaDetaySayfasiState extends ConsumerState<AnaDetaySayfasi> {
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

  void _yorumlarSayfasinaGit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YorumlarSayfasi(mekan: widget.mekan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    final userAsync = ref.watch(userProfileProvider);
    final userId = userAsync.value?.id;
    final user = userAsync.value;

    final eslesenYorumlar = widget.mekan.yorumlar.where(
      (yorum) => yorum.yazar.id == userId,
    );
    final YorumModel? kullaniciYorumu = eslesenYorumlar.isNotEmpty
        ? eslesenYorumlar.first
        : null;
    final double mevcutKullaniciPuani = kullaniciYorumu?.puan ?? 0.0;

    ref.listen<AsyncValue<void>>(yorumSubmitProvider, (_, state) {
      if (!mounted) return;
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${state.error.toString()}')),
        );
      } else if (state is AsyncData && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Değerlendirmeniz başarıyla gönderildi!'),
          ),
        );
      }
    });

    final yorumState = ref.watch(yorumSubmitProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
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
                    langCode == 'tr'
                        ? widget.mekan.isim.tr
                        : widget.mekan.isim.en,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2.0)],
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
                ),
                actions: [
                  if (user != null)
                    Consumer(
                      builder: (context, ref, child) {
                        // Favori durumunu anlık olarak kontrol et
                        final isFavorited = user.favoriMekanlar.contains(
                          widget.mekan.id,
                        );

                        return IconButton(
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorited
                                ? Colors.redAccent
                                : Colors.white,
                          ),
                          onPressed: () {
                            // Butona basıldığında Notifier'daki metodu çağır
                            ref
                                .read(userProfileProvider.notifier)
                                .toggleFavorite(widget.mekan.id);
                          },
                        );
                      },
                    ),
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
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PuanGostergesi(
                                  puan: widget.mekan.ortalamaPuan,
                                  iconSize: 22,
                                ),
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
                              padding: const EdgeInsets.only(
                                top: 16.0,
                                bottom: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.yourRating,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  if (yorumState.isLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  else
                                    PuanlamaGirdisi(
                                      baslangicPuani: mevcutKullaniciPuani,
                                      iconBoyutu: 36,
                                      onPuanDegisti: (yeniPuan) {
                                        ref
                                            .read(yorumSubmitProvider.notifier)
                                            .gonder(
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
                        langCode == 'tr'
                            ? widget.mekan.aciklama.tr
                            : widget.mekan.aciklama.en,
                        style: theme.textTheme.bodyLarge,
                      ),
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
                    ],
                  ),
                ),
              ),
              if (widget.mekan.fotograflar.length > 1) ...[
                _buildSectionHeader(theme, l10n.photos),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: FotografGalerisi(
                      imageUrls: widget.mekan.fotograflar,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // YORUMLAR BUTONU - SAĞ ALT KÖŞE
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: "comments_btn",
              onPressed: _yorumlarSayfasinaGit,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 6,
              child: const Icon(Icons.comment_outlined),
            ),
          ),
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
