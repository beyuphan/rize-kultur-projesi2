import 'package:flutter/material.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

class RotaBilgilerTab extends StatelessWidget {
  const RotaBilgilerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
}
