import 'package:flutter/material.dart';

/// Central place for the app's look & feel — a warm blood-red primary color
/// that fits a blood-donation product, on a clean white/grey surface.
class AppTheme {
  static const Color primaryRed = Color(0xFFC62828);
  static const Color darkRed = Color(0xFF8E0000);
  static const Color surface = Color(0xFFF7F7F8);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryRed,
      primary: primaryRed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      cardColor: Colors.white,
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primaryRed),
        selectedLabelTextStyle: TextStyle(color: primaryRed),
      ),
    );
  }

  /// Color used for "eligible now" badges/status.
  static const Color eligibleGreen = Color(0xFF2E7D32);
  static const Color waitingOrange = Color(0xFFEF6C00);
}
