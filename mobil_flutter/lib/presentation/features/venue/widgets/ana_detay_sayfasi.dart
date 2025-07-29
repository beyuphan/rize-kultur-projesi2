// lib/presentation/features/venue/widgets/ana_detay_sayfasi.dart

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
import 'package:url_launcher/url_launcher.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/features/auth/screens/giris_ekrani.dart';
import 'yorumlar_sayfasi.dart';

class AnaDetaySayfasi extends ConsumerStatefulWidget {
  final MekanModel mekan;
  const AnaDetaySayfasi({super.key, required this.mekan});

  @override
  ConsumerState<AnaDetaySayfasi> createState() => _AnaDetaySayfasiState();
}

class _AnaDetaySayfasiState extends ConsumerState<AnaDetaySayfasi> {
  

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
    
    // --- GÜVENLİK DÜZELTMESİ BURADA BAŞLIYOR ---
    
    // 1. Önce giriş durumunu kontrol et
    final authState = ref.watch(authProvider);
    final bool girisYapildi = authState == AuthStatus.girisYapildi;

    // 2. Sadece giriş yapıldıysa profil verisini izle
    final userAsync = girisYapildi ? ref.watch(userProfileProvider) : null;
    final user = userAsync?.value;
    final userId = user?.id;
    
    // --- GÜVENLİK DÜZELTMESİ BİTTİ ---

     final YorumModel? kullaniciYorumu;
    if (girisYapildi && userId != null) {
      // 'where' kullanarak güvenli bir şekilde arama yapıyoruz.
      final eslesenYorumlar = widget.mekan.yorumlar.where((yorum) => yorum.yazar.id == userId);
      kullaniciYorumu = eslesenYorumlar.isNotEmpty ? eslesenYorumlar.first : null;
    } else {
      kullaniciYorumu = null;
    }
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
      // Stack'i kaldırdık, Sliver'lar zaten katmanlama sağlıyor
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
                    widget.mekan.fotograflar.isNotEmpty ? widget.mekan.fotograflar[0] : 'https://placehold.co/600x400',
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
            // --- FAVORİ BUTONU (AKILLI HALE GETİRİLDİ) ---
            actions: [
              IconButton(
                icon: Icon(
                  (girisYapildi && user != null && user.favoriMekanlar.contains(widget.mekan.id))
                      ? Icons.favorite : Icons.favorite_border,
                  color: (girisYapildi && user != null && user.favoriMekanlar.contains(widget.mekan.id))
                      ? Colors.redAccent : Colors.white,
                ),
                onPressed: () {
                  if (girisYapildi) {
                    ref.read(userProfileProvider.notifier).toggleFavorite(widget.mekan.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Bu özelliği kullanmak için giriş yapmalısınız.'),
                        action: SnackBarAction(
                          label: 'Giriş Yap',
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GirisEkrani())),
                        ),
                      ),
                    );
                  }
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
                  // Ortalama Puan Bölümü
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(l10n.averageRating, style: theme.textTheme.labelLarge),
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
                  
                  // --- KULLANICININ KENDİ PUANLAMA ALANI (AKILLI HALE GETİRİLDİ) ---
                  if (girisYapildi)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Column(
                        children: [
                          Text(l10n.yourRating, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          if (yorumState.isLoading)
                            const CircularProgressIndicator()
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
                    )
                  else // Misafir kullanıcı için
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Center(
                        child: TextButton(
                          child: Text("Puan vermek için giriş yapın"),
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GirisEkrani())),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Divider(),
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
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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