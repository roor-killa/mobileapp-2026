import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// Thème style export [Panache](https://github.com/rxlabz/panache)
//
// Panache propose un fichier `theme.dart` avec :
//   final ThemeData myTheme = ThemeData( ... );
// puis dans MaterialApp : theme: myTheme
//
// Le projet Panache est archivé depuis 2023 et générait surtout l’ancienne API
// (primarySwatch, accentColor…). Ici, les mêmes rôles de couleurs sont portés
// par [ColorScheme] et Material 3 ([useMaterial3]), ce que Flutter attend
// aujourd’hui. Tu peux encore t’inspirer de l’éditeur web
// https://rxlabz.github.io/panache puis recopier les teintes dans
// [NodexPanacheColors] ci-dessous.
// -----------------------------------------------------------------------------

/// Palette centrale — à modifier comme dans l’éditeur Panache (couleurs + contrastes).
abstract final class NodexPanacheColors {
  static const Color scaffoldBackground = Color(0xFF060A12);
  static const Color backgroundAlt = Color(0xFF0C1220);
  static const Color card = Color(0xFF141C2E);
  static const Color cardElevated = Color(0xFF1A2540);
  /// « Primary » à la Panache → couleur principale de l’interface
  static const Color primary = Color(0xFF22D3EE);
  static const Color primaryLight = Color(0xFF67E8F9);
  /// « Accent » à la Panache → secondaire fort (souvent boutons / liens)
  static const Color accent = Color(0xFFA78BFA);
  static const Color success = Color(0xFF34D399);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF8B9CB3);
  static const Color divider = Color(0xFF2D3F5C);
  static const Color inputFill = Color(0xFF0F1628);
  static const Color error = Color(0xFFF87171);
  static const Color onPrimaryContrast = Color(0xFF042028);
  static const Color onSecondaryContrast = Color(0xFF1E1033);
}

/// Rayons de coins (équivalent aux réglages de forme dans Panache).
abstract final class NodexPanacheRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
}

/// Thème global NodEX — à brancher sur [MaterialApp.theme], comme dans la doc Panache.
final ThemeData myTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  // Champs « classiques » encore utiles pour certains widgets / legacy
  primaryColor: NodexPanacheColors.primary,
  scaffoldBackgroundColor: NodexPanacheColors.scaffoldBackground,
  canvasColor: NodexPanacheColors.scaffoldBackground,
  cardColor: NodexPanacheColors.card,
  dividerColor: NodexPanacheColors.divider,
  hintColor: NodexPanacheColors.textSecondary,
  disabledColor: NodexPanacheColors.textSecondary.withValues(alpha: 0.45),
  splashColor: NodexPanacheColors.primary.withValues(alpha: 0.12),
  highlightColor: NodexPanacheColors.primary.withValues(alpha: 0.08),
  colorScheme: ColorScheme.dark(
    primary: NodexPanacheColors.primary,
    primaryContainer: NodexPanacheColors.primary.withValues(alpha: 0.18),
    secondary: NodexPanacheColors.accent,
    secondaryContainer: NodexPanacheColors.accent.withValues(alpha: 0.2),
    surface: NodexPanacheColors.card,
    surfaceContainerHighest: NodexPanacheColors.cardElevated,
    onPrimary: NodexPanacheColors.onPrimaryContrast,
    onSecondary: NodexPanacheColors.onSecondaryContrast,
    onSurface: NodexPanacheColors.textPrimary,
    onSurfaceVariant: NodexPanacheColors.textSecondary,
    outline: NodexPanacheColors.divider,
    error: NodexPanacheColors.error,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: NodexPanacheColors.textPrimary,
    titleTextStyle: TextStyle(
      color: NodexPanacheColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.transparent,
    selectedItemColor: NodexPanacheColors.primary,
    unselectedItemColor: NodexPanacheColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: NodexPanacheColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NodexPanacheRadii.md)),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: NodexPanacheColors.cardElevated,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NodexPanacheRadii.lg)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: NodexPanacheColors.cardElevated,
    contentTextStyle: const TextStyle(color: NodexPanacheColors.textPrimary),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NodexPanacheRadii.sm)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: NodexPanacheColors.inputFill,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(NodexPanacheRadii.sm)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(NodexPanacheRadii.sm),
      borderSide: const BorderSide(color: NodexPanacheColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(NodexPanacheRadii.sm),
      borderSide: const BorderSide(color: NodexPanacheColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(color: NodexPanacheColors.textSecondary),
    hintStyle: TextStyle(color: NodexPanacheColors.textSecondary.withValues(alpha: 0.85)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: NodexPanacheColors.primary,
      foregroundColor: NodexPanacheColors.onPrimaryContrast,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NodexPanacheRadii.sm)),
      elevation: 0,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: NodexPanacheColors.textPrimary,
      backgroundColor: NodexPanacheColors.primary.withValues(alpha: 0.25),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: NodexPanacheColors.divider.withValues(alpha: 0.6),
    thickness: 1,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: NodexPanacheColors.primary),
  listTileTheme: const ListTileThemeData(
    iconColor: NodexPanacheColors.textSecondary,
    textColor: NodexPanacheColors.textPrimary,
  ),
);
