import 'package:flutter/material.dart';
import 'colors.dart';

class NEGsStyles {
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: NEGsColors.textPrimary,
    letterSpacing: 1,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: NEGsColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: NEGsColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: NEGsColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: NEGsColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: NEGsColors.textTertiary,
  );

  static const TextStyle largePrice = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: NEGsColors.textPrimary,
    letterSpacing: 0.5,
  );

  // Box Decorations
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.1)),
  );

  static BoxDecoration glassDecorationSmall = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.15)),
  );

  static BoxDecoration gradientDecoration = BoxDecoration(
    gradient: NEGsGradients.cardGradient,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withOpacity(0.1)),
  );

  // Border Radius
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(28));
  static const BorderRadius radiusMedium = BorderRadius.all(
    Radius.circular(20),
  );
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(16));

  // Shadows
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0xFF7C3AED),
      blurRadius: 30,
      spreadRadius: 5,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0xFF7C3AED),
      blurRadius: 20,
      spreadRadius: 2,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0xFF7C3AED),
      blurRadius: 15,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
  ];

  // Padding/Spacing
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
  static const EdgeInsets paddingSmall = EdgeInsets.all(12);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(
    horizontal: 16,
  );
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: 16);
}
