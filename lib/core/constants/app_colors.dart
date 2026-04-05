import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primaires ────────────────────────────────────────────────────────────
  static const Color primary     = Color(0xFF5B4FE9);
  static const Color primaryDark = Color(0xFF3D35C8);
  static const Color primaryLight= Color(0xFF7B72F0);

  // ─── Secondaires ──────────────────────────────────────────────────────────
  static const Color secondary     = Color(0xFF00D09C);
  static const Color secondaryDark = Color(0xFF00A87B);

  static const Color accent = Color(0xFFFF6584);

  // ─── Fonds ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF0F2FF);
  static const Color surface    = Colors.white;

  // ─── Textes ───────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1147);
  static const Color textSecondary = Color(0xFF9E9BB3);
  static const Color textHint      = Color(0xFFBDB9D0);

  // ─── États ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00D09C);
  static const Color error   = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFA726);

  // ─── Bordures ─────────────────────────────────────────────────────────────
  static const Color border  = Color(0xFFE8E6F5);
  static const Color divider = Color(0xFFF0EEF9);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF3D35C8)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D09C), Color(0xFF00A87B)],
  );
}
