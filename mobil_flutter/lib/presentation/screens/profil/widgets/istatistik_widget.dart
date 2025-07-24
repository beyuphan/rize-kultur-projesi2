// lib/presentation/screens/profil/widgets/istatistik_widget.dart

import 'package:flutter/material.dart';

// SINIF ADININ 'StatWidget' OLDUĞUNDAN VE BAŞINDA '_' OLMADIĞINDAN EMİN OL
class StatWidget extends StatelessWidget {
  final int count;
  final String label;

  // super.key'i ekleyerek daha standart hale getirelim
  const StatWidget({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}