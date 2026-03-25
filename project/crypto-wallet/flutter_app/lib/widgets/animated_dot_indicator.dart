import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Indicateurs « pilule » animés, inspirés de
/// [navigator_animation](https://github.com/abuanwar072/navigator_animation) :
/// [AnimatedContainer] + [Curves.elasticOut], sans package tiers.
///
/// Si [onAnimationComplete] est null (ex. barre d’onglets), l’animation interne
/// ne déclenche aucun changement automatique.
class NavigatorStyleDotIndicator extends StatelessWidget {
  const NavigatorStyleDotIndicator({
    super.key,
    required this.isActive,
    this.onAnimationComplete,
  });

  final bool isActive;
  final VoidCallback? onAnimationComplete;

  @override
  Widget build(BuildContext context) {
    final track = AppTheme.border.withValues(alpha: 0.55);
    final trackActive = AppTheme.primary.withValues(alpha: 0.22);

    return AnimatedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      height: 12,
      width: isActive ? 48 : 12,
      decoration: BoxDecoration(
        color: isActive ? trackActive : track,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppTheme.primary.withValues(alpha: 0.45) : Colors.transparent,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(seconds: 3),
          width: isActive ? 42 : 0,
          onEnd: () {
            if (isActive) onAnimationComplete?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryLight.withValues(alpha: 0.95) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rangée d’indicateurs pour les onglets principaux (5 positions).
class TabNavigatorDots extends StatelessWidget {
  const TabNavigatorDots({super.key, required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: NavigatorStyleDotIndicator(isActive: i == selectedIndex),
        ),
      ),
    );
  }
}
