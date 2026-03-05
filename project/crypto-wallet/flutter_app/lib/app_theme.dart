import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0F0B2E);
  static const Color card = Color(0xFF16132B);
  static const Color primary = Color(0xFF7C3AED);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color border = Color(0xFF2A2A4A);
  static const Color inputBg = Color(0xFF1A1A2E);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.dark(
          primary: primary,
          surface: card,
          onPrimary: Colors.white,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          foregroundColor: textPrimary,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: card,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}
