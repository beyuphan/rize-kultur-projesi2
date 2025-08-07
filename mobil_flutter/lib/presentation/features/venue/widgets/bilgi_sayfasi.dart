// lib/presentation/screens/mekan_detay/widgets/bilgi_sayfasi.dart

import 'package:flutter/material.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

class BilgiSayfasi extends StatelessWidget {
  final MekanModel mekan;
  const BilgiSayfasi({super.key, required this.mekan});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final tarihce = langCode == 'tr' ? mekan.tarihce?.tr ?? '' : mekan.tarihce?.en ?? '';
    final etiketler = mekan.etiketler ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // YENİ YAPI: Geri butonunu ekleyebilmek için Stack kullanıyoruz
      body: Stack(
        children: [
          // Ana içerik, kaydırılabilir olmaya devam ediyor
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 100), // Geri butonu için üstte boşluk
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TARİHÇE BÖLÜMÜ
                if (tarihce.isNotEmpty) ...[
                  _buildSectionCard(
                    theme: theme,
                    title: "Tarihçe",
                    child: Text(tarihce, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // ÖZELLİKLER BÖLÜMÜ
                _buildSectionCard(
                  theme: theme,
                  title: "Özellikler",
                  child: etiketler.isEmpty
                      ? const Text("Bu mekan için özellik bilgisi eklenmemiş.")
                      : Wrap(
                          spacing: 12.0, // Yatay boşluk
                          runSpacing: 12.0, // Dikey boşluk
                          children: etiketler.map((etiketKey) => _EtiketChip(etiketKey: etiketKey)).toList(),
                        ),
                ),
              ],
            ),
          ),

          // YENİ: SOL ÜST GERİ BUTONU
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bölümleri standart bir kart yapısına sokan yardımcı widget
  Widget _buildSectionCard({required ThemeData theme, required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Divider(color: theme.primaryColor.withOpacity(0.2), thickness: 1, endIndent: 150),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

// YENİ: Etiketleri şık "chip"ler halinde gösteren widget
class _EtiketChip extends StatelessWidget {
  final String etiketKey;
  const _EtiketChip({required this.etiketKey});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    IconData icon;
    String text;
    Color color;

    switch (etiketKey) {
      case 'araba-ulasimi-var':
        icon = Icons.directions_car;
        text = l10n.tagCarAccess;
        color = Colors.blue;
        break;
      case 'araba-ulasimi-zorlu':
    icon = Icons.directions_car_filled;
    text = l10n.tagDifficultCarAccess;
    color = Colors.indigo;
    break;
      case 'kis-mevsimine-uygun':
        icon = Icons.ac_unit;
        text = l10n.tagWinterFriendly;
        color = Colors.cyan;
        break;
          case 'kis-mevsimine-uygun-degil':
    icon = Icons.snowing;
    text = l10n.tagNotWinterFriendly;
    color = Colors.grey;
    break;
      case 'giris-ucretli':
        icon = Icons.attach_money;
        text = l10n.tagEntryFee;
        color = Colors.green;
        break;
         case 'giris-ucretsiz':
    icon = Icons.money_off;
    text = l10n.tagFreeEntry;
    color = Colors.lightGreen;
    break;
      case 'yuruyus-parkuru-var':
        icon = Icons.hiking;
        text = l10n.tagHikingTrail;
        color = Colors.orange;
        break;
        case 'kamp-yapilir':
    icon = Icons.park;
    text = l10n.tagCamping;
    color = Colors.brown;
    break;
  case 'konaklama-tesisi-var':
    icon = Icons.hotel;
    text = l10n.tagAccommodation;
    color = Colors.teal;
    break;
  case 'yeme-icme-tesisi-var':
    icon = Icons.restaurant;
    text = l10n.tagFoodFacility;
    color = Colors.redAccent;
    break;
case 'yaban-hayati':
    icon = Icons.pets;
    text = l10n.tagWildlife;
    color = Colors.lightGreen;
    break;
  case 'manzarali':
    icon = Icons.landscape;
    text = l10n.tagScenic;
    color = Colors.blueAccent;
    break;
  case 'salincak':
    icon = Icons.chair_alt;
    text = l10n.tagSwing;
    color = Colors.pinkAccent;
    break;
  case 'fotograf-cekim-noktasi':
    icon = Icons.camera_alt;
    text = l10n.tagPhotoSpot;
    color = Colors.deepOrangeAccent;
    break;

  default:
    icon = Icons.label;
    text = l10n.tagDefault;
    color = Colors.grey;

    }

    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(text),
      backgroundColor: color.withOpacity(0.1),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.3))),
    );
  }
}