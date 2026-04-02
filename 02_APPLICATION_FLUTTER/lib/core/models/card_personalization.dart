import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum PersonalizationTheme { gradient, minimal, glass }

enum CardPattern { none, geometric, particles }

class CardPersonalization {
  final String name;
  final LinearGradient gradient;
  final PersonalizationTheme theme;
  final CardPattern pattern;
  final String color;

  const CardPersonalization({
    required this.name,
    required this.gradient,
    required this.theme,
    required this.pattern,
    required this.color,
  });

  static final presets = [
    CardPersonalization(
      name: 'Violet Cyan',
      gradient: NEGsGradients.cardGradient,
      theme: PersonalizationTheme.gradient,
      pattern: CardPattern.none,
      color: 'Gradient Premium',
    ),
    CardPersonalization(
      name: 'Vert Émeraude',
      gradient: NEGsGradients.greenCard,
      theme: PersonalizationTheme.gradient,
      pattern: CardPattern.none,
      color: 'Green',
    ),
    CardPersonalization(
      name: 'Coucher Soleil',
      gradient: NEGsGradients.sunsetCard,
      theme: PersonalizationTheme.gradient,
      pattern: CardPattern.none,
      color: 'Sunset',
    ),
    CardPersonalization(
      name: 'Océan',
      gradient: NEGsGradients.oceanCard,
      theme: PersonalizationTheme.gradient,
      pattern: CardPattern.none,
      color: 'Ocean',
    ),
    CardPersonalization(
      name: 'Noir Mat',
      gradient: LinearGradient(
        colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      theme: PersonalizationTheme.minimal,
      pattern: CardPattern.none,
      color: 'Black',
    ),
    CardPersonalization(
      name: 'Rouge',
      gradient: NEGsGradients.redCard,
      theme: PersonalizationTheme.gradient,
      pattern: CardPattern.none,
      color: 'Red',
    ),
    CardPersonalization(
      name: 'Galaxy',
      gradient: NEGsGradients.galaxyCard,
      theme: PersonalizationTheme.glass,
      pattern: CardPattern.particles,
      color: 'Galaxy',
    ),
    CardPersonalization(
      name: 'Bleu Indigo',
      gradient: LinearGradient(
        colors: [Color(0xFF1e1b4b), Color(0xFF312e81)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      theme: PersonalizationTheme.gradient,
      pattern: CardPattern.geometric,
      color: 'Indigo',
    ),
  ];
}
