import 'package:flutter/material.dart';

/// Toutes les couleurs de l'application centralisées ici.
/// Pour changer le thème, modifiez uniquement ce fichier.
class AppColors {
  AppColors._();

  // ── Couleur principale ──────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1976D2); // bleu principal
  static const Color primaryLight   = Color(0xFFE3F2FD); // fond très clair
  static const Color primaryMedium  = Color(0xFF42A5F5); // bleu moyen

  // ── Dégradé de l'écran d'accueil ───────────────────────────────────────────
  static const Color gradientStart  = Color(0xFF1565C0); // bleu foncé (gauche)
  static const Color gradientEnd    = Color(0xFF42A5F5); // bleu clair (droite)

  // ── Couleurs sémantiques (ne pas changer) ──────────────────────────────────
  static const Color success        = Color(0xFF43A047); // vert succès
  static const Color successLight   = Color(0xFFE8F5E9);
  static const Color error          = Color(0xFFE53935); // rouge erreur
  static const Color errorLight     = Color(0xFFFFEBEE);
  static const Color warning        = Color(0xFFF57C00); // orange avertissement
  static const Color warningLight   = Color(0xFFFFF3E0);

  // ── Textes ─────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF212121);
  static const Color textSecondary  = Color(0xFF757575);
  static const Color textHint       = Color(0xFFBDBDBD);

  // ── Fonds ──────────────────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
}
