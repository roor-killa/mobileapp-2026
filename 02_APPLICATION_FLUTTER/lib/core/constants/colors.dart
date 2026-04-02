import 'package:flutter/material.dart';

class NEGsColors {
  // LIGHT MODE - Palette Luxe
  // Backgrounds
  static const Color bgMainLight = Color(0xFFF8F6F2); // Beige crème principal
  static const Color bgSecondaryLight = Color(0xFFF0EEE8); // Gris perle
  static const Color bgTertiaryLight = Color(0xFFE8E4F0); // Légère teinte violette
  static const Color bgWhite = Color(0xFFFFFFFF); // Blanc pur

  // Primary Colors
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);

  // Text - Light Mode
  static const Color textPrimary = Color(0xFF1A1A2E); // Quasi noir
  static const Color textSecondary = Color(0x801A1A2E); // Semi-transparent
  static const Color textTertiary = Color(0xFF64748B);

  // Cards & Elements
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E1DC);

  // Accent Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Crypto Colors
  static const Color cryptoBTC = Color(0xFFF7931A);
  static const Color cryptoETH = Color(0xFF627EEA);
  static const Color cryptoGreen = Color(0xFF10B981);
}

class NEGsGradients {
  // Main gradient (Violet → Cyan)
  static const LinearGradient mainGradient = LinearGradient(
    colors: [NEGsColors.primaryViolet, NEGsColors.primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background gradient light beige
  static const LinearGradient bgGradient = LinearGradient(
    colors: [NEGsColors.bgMainLight, NEGsColors.bgSecondaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Header gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [NEGsColors.bgSecondaryLight, NEGsColors.bgTertiaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card gradient principal (couleurs sombres)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF4C1D95),
      NEGsColors.primaryViolet,
      NEGsColors.primaryCyan,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Galaxy card (dark)
  static const LinearGradient galaxyCard = LinearGradient(
    colors: [Color(0xFF1a0033), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Green card
  static const LinearGradient greenCard = LinearGradient(
    colors: [Color(0xFF065f46), Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sunset card
  static const LinearGradient sunsetCard = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ocean card
  static const LinearGradient oceanCard = LinearGradient(
    colors: [Color(0xFF0369a1), Color(0xFF0284c7), Color(0xFF38bdf8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Red card
  static const LinearGradient redCard = LinearGradient(
    colors: [Color(0xFF7f1d1d), Color(0xFFef4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Decorative circle gradients light
  static const RadialGradient violetCircle = RadialGradient(
    colors: [
      Color(0xFF7C3AED),
      Colors.transparent,
    ],
  );

  static const RadialGradient cyanCircle = RadialGradient(
    colors: [
      Color(0xFF06B6D4),
      Colors.transparent,
    ],
  );

  static const RadialGradient greenCircle = RadialGradient(
    colors: [
      Color(0xFF10B981),
      Colors.transparent,
    ],
  );
}
