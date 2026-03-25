import 'package:flutter/material.dart';
import 'panache_theme.dart';

/// Dégradés, ombres et raccourcis NodEX. Le [ThemeData] principal est [myTheme]
/// dans [panache_theme.dart] (workflow type [Panache](https://github.com/rxlabz/panache)).
class AppTheme {
  static const Color background = NodexPanacheColors.scaffoldBackground;
  static const Color backgroundAlt = NodexPanacheColors.backgroundAlt;
  static const Color card = NodexPanacheColors.card;
  static const Color cardElevated = NodexPanacheColors.cardElevated;
  static const Color primary = NodexPanacheColors.primary;
  static const Color primaryLight = NodexPanacheColors.primaryLight;
  static const Color secondary = NodexPanacheColors.accent;
  static const Color accent = NodexPanacheColors.success;
  static const Color textPrimary = NodexPanacheColors.textPrimary;
  static const Color textSecondary = NodexPanacheColors.textSecondary;
  static const Color border = NodexPanacheColors.divider;
  static const Color inputBg = NodexPanacheColors.inputFill;
  static const Color error = NodexPanacheColors.error;
  static const Color surfaceBright = Color(0xFFE2E8F0);
  static const Color warningSurface = Color(0xFF2D2410);
  static const Color warningBorder = Color(0xFF854D0E);
  static const Color warningText = Color(0xFFFDE68A);

  static const double radiusSm = NodexPanacheRadii.sm;
  static const double radiusMd = NodexPanacheRadii.md;
  static const double radiusLg = NodexPanacheRadii.lg;
  static const double radiusXl = NodexPanacheRadii.xl;

  static LinearGradient get heroGradient => const LinearGradient(
        colors: [
          Color(0xFF0E7490),
          Color(0xFF4F46E5),
          Color(0xFF6D28D9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get brandIconGradient => const LinearGradient(
        colors: [
          Color(0xFF22D3EE),
          Color(0xFF818CF8),
          Color(0xFFC084FC),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.4),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowStrong => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: secondary.withValues(alpha: 0.2),
          blurRadius: 36,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration get loginBackgroundDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            background,
            const Color(0xFF1E1B4B).withValues(alpha: 0.55),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      );

  /// Alias vers le thème Panache / Material 3.
  static ThemeData get light => myTheme;
}
