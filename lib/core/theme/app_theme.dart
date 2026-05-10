// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Palet Warna Utama
  static const Color backgroundColor = Color(0xFF05070D); // Hitam Pekat Premium
  static const Color primaryCyan = Color(0xFF00D9FF);     // Cyan Neon
  static const Color secondaryPurple = Color(0xFF8B5CF6); // Purple Glow
  static const Color cardColor = Color(0xFF0F121D);       // Navy Gelap untuk Card
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);   // Abu-abu soft

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: secondaryPurple,
        background: backgroundColor,
        surface: cardColor,
      ),
      
      // Desain Font & Tipografi
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),

      // Desain Tombol Global
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // Radius 18px sesuai kesepakatan
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
