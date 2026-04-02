import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NEGsTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NEGsColors.bgMainLight,
      primaryColor: NEGsColors.primaryViolet,
      colorScheme: ColorScheme.light(
        primary: NEGsColors.primaryViolet,
        secondary: NEGsColors.primaryCyan,
        tertiary: NEGsColors.success,
        surface: NEGsColors.cardBg,
        error: NEGsColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: NEGsColors.textPrimary,
        onError: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NEGsColors.bgWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: NEGsColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: NEGsColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: NEGsColors.primaryViolet, width: 2),
        ),
        hintStyle: const TextStyle(color: NEGsColors.textSecondary),
        labelStyle: const TextStyle(color: NEGsColors.primaryViolet),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NEGsColors.primaryViolet,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NEGsColors.primaryViolet,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: NEGsColors.primaryCyan),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NEGsColors.bgSecondaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: NEGsColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NEGsColors.bgWhite,
        selectedItemColor: NEGsColors.primaryCyan,
        unselectedItemColor: NEGsColors.textTertiary,
        elevation: 8,
      ),
    );
  }
}
