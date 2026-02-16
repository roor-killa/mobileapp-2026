import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple Design System Colors
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color secondaryGreen = Color(0xFF34C759);
  static const Color accentPurple = Color(0xFF5856D6);
  static const Color errorRed = Color(0xFFFF3B30);
  static const Color warningOrange = Color(0xFFFF9500);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  
  // Gradients Apple Style
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34C759), Color(0xFF30B0C0)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF5F7FA)],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F7FA), Colors.white],
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Google Fonts INTER
    fontFamily: GoogleFonts.inter().fontFamily,
    
    // ✅ CORRECTION: Un seul paramètre surface
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryGreen,
      tertiary: accentPurple,
      surface: surfaceWhite,
      error: errorRed,
    ).copyWith(
      surfaceContainerHighest: backgroundLight,
      onSurface: textPrimary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    
    scaffoldBackgroundColor: backgroundLight,
    
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: primaryBlue),
      actionsIconTheme: const IconThemeData(color: primaryBlue),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceWhite,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5),
      displayMedium: GoogleFonts.inter(fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5),
      displaySmall: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w400),
      headlineMedium: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.25),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
    ),
  );
}