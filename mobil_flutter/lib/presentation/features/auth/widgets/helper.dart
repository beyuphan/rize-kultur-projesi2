import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// GİRİŞ ALANLARI İÇİN STİL
InputDecoration buildAuthInputDecoration({required String label, required IconData icon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.poppins(color: Colors.white70),
    prefixIcon: Icon(icon, color: Colors.white70, size: 20),
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
    ),
    errorStyle: GoogleFonts.poppins(color: Colors.yellowAccent),
  );
}

// SAYFA GEÇİŞ YAZISI İÇİN STİL
Widget buildAuthRichTextNavigation({
  required BuildContext context,
  required String text1,
  required String text2,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: onTap,
    child: RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8)),
        children: [
          TextSpan(text: text1),
          TextSpan(
            text: text2,
            style: TextStyle(
              color: theme.colorScheme.secondary, // Temanızdaki ikincil rengi kullanır
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}