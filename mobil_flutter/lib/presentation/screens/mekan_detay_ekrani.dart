import 'package:flutter/material.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/widgets/fotograf_galerisi.dart'; // Yeni galerimizi import ediyoruz
import 'package:mobil_flutter/presentation/widgets/puan_gostergesi.dart';
import 'package:mobil_flutter/presentation/widgets/yorum_karti.dart';

class MekanDetayEkrani extends StatelessWidget {
  final String mekanId;
  const MekanDetayEkrani(
  {super.key,
  required this.mekanId, });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Örnek veriler
    const mekanIsmi = 'Zil Kale';
    const mekanPuan = 4.8;
    const yorumSayisi = "500+";
    const mekanAciklama = 'Fırtına Vadisi\'ne hakim bir tepede, muhteşem bir manzaraya sahip, 14. yüzyıldan kalma tarihi bir kale. Rize\'nin en önemli kültürel miraslarından biridir.';
    
    // Örnek fotoğraf listesi
    final List<String> fotograflar = [
     'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8F4TyuflGd3x5a7D5vtj3xTo2RSwSDYZtlA&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSM-sYc2p3e7f_J1YRpTk4Z_IfXiSCd1TvY7A&sr',
      'https://iahbr.tmgrup.com.tr/album/2018/04/22/cumhurbaskani-erdoganin-istegi-uzerine-insaa-edilen-kibledag-camii-ziyaretci-akinina-ugruyor-1524391503895.jpg',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. BÖLÜM: AppBar
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                fotograflar[0], // Ana resim olarak galerinin ilk fotoğrafını kullanıyoruz
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. BÖLÜM: Mekan Bilgileri
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mekanIsmi, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PuanGostergesi(puan: mekanPuan),
                      const SizedBox(width: 8),
                      Text(
                        l10n.reviewsCount(yorumSayisi),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(mekanAciklama, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.directions),
                          label: Text(l10n.getDirections),
                          onPressed: () {},
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
          
          // 3. BÖLÜM: FOTOĞRAF GALERİSİ
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  // TODO: "Fotoğraflar" için l10n anahtarı ekle
                  child: Text('Fotoğraflar', style: theme.textTheme.titleLarge), 
                ),
                const SizedBox(height: 16),
                FotografGalerisi(imageUrls: fotograflar),
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

          // 5. BÖLÜM: Yorumlar Listesi
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final yorumlar = [
                  {
                    "isim": "Ali Veli",
                    "puan": 5.0,
                    "yorum": "Hayatımda yediğim en güzel mıhlamaydı. Manzarası da cabası. Kesinlikle tavsiye ederim!"
                  },
                  {
                    "isim": "Ayşe Fatma",
                    "puan": 4.0,
                    "yorum": "Çok güzel bir yer ama hafta sonu biraz kalabalık olabiliyor. Yine de beklediğimize değdi.",
                    "foto": "https://randomuser.me/api/portraits/women/44.jpg"
                  }
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
              },
              childCount: 2,
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          )
        ],
      ),
    );
  }
}
