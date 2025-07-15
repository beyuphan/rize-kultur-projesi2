import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod'ı import et
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart'; // Provider'larımızı import et
import 'package:mobil_flutter/presentation/widgets/fotograf_galerisi.dart';
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
import 'package:mobil_flutter/presentation/widgets/yorum_karti.dart';
import 'package:url_launcher/url_launcher.dart'; // Bu import'u dosyanın en üstüne ekle

// StatelessWidget'ı ConsumerWidget'a çeviriyoruz
class MekanDetayEkrani extends ConsumerWidget {
  final String mekanId;
  const MekanDetayEkrani({super.key, required this.mekanId});

  @override
  // build metoduna WidgetRef ref parametresini ekliyoruz
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Oluşturduğumuz provider'ı gelen mekanId ile dinliyoruz
    final asyncMekan = ref.watch(mekanDetayProvider(mekanId));

    // provider'ın durumuna göre (yükleniyor, hata, veri geldi) UI çiziyoruz
    return asyncMekan.when(
      // Veri yüklenirken gösterilecek
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // Hata oluşursa gösterilecek
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Hata: $err')),
      ),
      // Veri başarıyla geldiyse gösterilecek
      data: (mekan) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // 1. BÖLÜM: AppBar (Dinamik Veriyle Doluyor)
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.surface,
                iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                flexibleSpace: FlexibleSpaceBar(
                  background: mekan.fotograflar.isNotEmpty
                      ? Image.network(
                          mekan.fotograflar[0],
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey,
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                ),
              ),

              // 2. BÖLÜM: Mekan Bilgileri (Dinamik Veriyle Doluyor)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mekan.isim, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PuanGostergesi(puan: mekan.ortalamaPuan),
                          const SizedBox(width: 8),
                          // TODO: Yorum sayısını dinamik hale getir
                          Text(
                            l10n.reviewsCount("500+"), // Şimdilik statik
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(mekan.aciklama, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.directions),
                              label: Text(l10n.getDirections),
                               onPressed: () {
                                // Dinamik olarak gelen mekanın konum bilgilerini fonksiyona gönderiyoruz.
                                _haritayiAc(mekan.konum.enlem, mekan.konum.boylam);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {},
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. BÖLÜM: FOTOĞRAF GALERİSİ (Dinamik Veriyle Doluyor)
              if (mekan.fotograflar.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Fotoğraflar', style: theme.textTheme.titleLarge),
                      ),
                      const SizedBox(height: 16),
                      FotografGalerisi(imageUrls: mekan.fotograflar),
                    ],
                  ),
                ),

              // 4. BÖLÜM: Yorumlar Başlığı
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 8.0),
                  child: Text(l10n.reviews, style: theme.textTheme.titleLarge),
                ),
              ),

              // 5. BÖLÜM: Yorumlar Listesi (ŞİMDİLİK STATİK)
              // TODO: Yorumları da dinamik olarak çekecek bir yapı kurulacak
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                   final yorumlar = [
                          {
                            "isim": "Ali Veli",
                            "puan": 5.0,
                            "yorum": "Hayatımda yediğim en güzel mıhlamaydı. Manzarası da cabası. Kesinlikle tavsiye ederim!",
                          },
                          {
                            "isim": "Ayşe Fatma",
                            "puan": 4.0,
                            "yorum": "Çok güzel bir yer ama hafta sonu biraz kalabalık olabiliyor. Yine de beklediğimize değdi.",
                            "foto": "https://randomuser.me/api/portraits/women/44.jpg",
                          },
                        ];
                  final yorum = yorumlar[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: YorumKarti(
                      kullaniciAdi: yorum["isim"] as String,
                      puan: yorum["puan"] as double,
                      yorum: yorum["yorum"] as String,
                      kullaniciImageUrl: yorum["foto"] as String?,
                    ),
                  );
                }, childCount: 2),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}
Future<void> _haritayiAc(double lat, double lon) async {
  // DİKKAT: Burası 'geo:' ile başlamalı.
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