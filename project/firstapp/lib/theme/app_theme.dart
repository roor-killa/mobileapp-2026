import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_system.dart';

class AppTheme {
  // Couleurs alignées sur la maquette Figma "Bank mobile application"
  static const Color brand = DesignSystem.indigo600;
  static const Color brandLight = DesignSystem.purple500;
  static const Color brand2 = DesignSystem.purple400;
  static const Color surface = DesignSystem.gray100;
  static const Color cardBackground = DesignSystem.white;
  static const Color success = DesignSystem.green500;
  static const Color successLight = DesignSystem.green50;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: Brightness.light,
      primary: brand,
      secondary: brand2,
      surface: surface,
      tertiary: success,
    ).copyWith(
      primary: brand,
      secondary: brand2,
      surface: surface,
      tertiary: success,
    );

    const radiusCard = 20.0;
    const radiusButton = 14.0;
    const radiusInput = 14.0;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Roboto',

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      ),

      textTheme: TextTheme(
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: scheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: scheme.onSurfaceVariant,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        color: cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 40,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Thème sombre (mode nuit)
  static ThemeData dark() {
    const surfaceDark = Color(0xFF1C1B1F);
    const cardDark = Color(0xFF2B2930);
    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: Brightness.dark,
      primary: brand,
      secondary: brand2,
      surface: surfaceDark,
      tertiary: success,
    ).copyWith(
      primary: brand,
      secondary: brand2,
      surface: surfaceDark,
      tertiary: success,
    );

    const radiusCard = 20.0;
    const radiusButton = 14.0;
    const radiusInput = 14.0;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surfaceDark,
      fontFamily: 'Roboto',

      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black54,
        color: cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 40,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Préférence mode sombre (persistée + notifier pour mise à jour immédiate).
class ThemeModeHolder {
  ThemeModeHolder._();
  static final ValueNotifier<ThemeMode> notifier = ValueNotifier<ThemeMode>(ThemeMode.light);
  static const String _key = 'dark_mode';

  static Future<void> load(SharedPreferences prefs) async {
    final dark = prefs.getBool(_key) ?? false;
    notifier.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setDark(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
    notifier.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDark => notifier.value == ThemeMode.dark;
}
