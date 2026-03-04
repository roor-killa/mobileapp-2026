import 'package:flutter/material.dart';

/// Design system basé sur la maquette Figma "Bank mobile application".
/// Utilisé uniquement pour le design (couleurs, espacements, rayons).
/// Aucune logique métier.
class DesignSystem {
  DesignSystem._();

  // ——— Espacements (grille 8px, mobile) ———
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;  // px-6 dans Figma
  static const double space32 = 32;

  // ——— Rayons (Figma : rounded-2xl = 16, rounded-3xl = 24) ———
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;   // rounded-2xl
  static const double radiusXl = 20;
  static const double radius2xl = 24;  // rounded-3xl

  // ——— Couleurs Figma / React (Tailwind) ———
  // Indigo / Violet (carte et primary)
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color purple500 = Color(0xFF7C3AED);
  static const Color purple400 = Color(0xFFA855F7);
  static const Color purple50 = Color(0xFFF5F3FF);

  // Vert (crédit / succès)
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF34D399);
  static const Color green500 = Color(0xFF10B981);
  static const Color green50 = Color(0xFFECFDF5);
  static const Color green600 = Color(0xFF059669);
  static const Color green700 = Color(0xFF047857);

  // Rouge (débit / erreur)
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red500 = Color(0xFFEF4444);

  // Orange (quick action)
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange600 = Color(0xFFEA580C);

  // Gris (texte et fonds)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);

  /// Dégradé de la carte solde (Figma HomeScreen)
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo600, purple500, purple400],
  );
}
