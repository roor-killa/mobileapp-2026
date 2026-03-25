import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Fond animé discret (auréoles cyan / violet) pour les onglets principaux.
class FuturisticBackground extends StatefulWidget {
  const FuturisticBackground({super.key});

  @override
  State<FuturisticBackground> createState() => _FuturisticBackgroundState();
}

class _FuturisticBackgroundState extends State<FuturisticBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppTheme.background),
            _glowOrb(
              color: AppTheme.primary,
              top: -60 + 48 * t,
              right: -40,
              size: 240,
              opacity: 0.11,
            ),
            _glowOrb(
              color: AppTheme.secondary,
              bottom: 80 - 60 * t,
              left: -100,
              size: 300,
              opacity: 0.09,
            ),
            _glowOrb(
              color: const Color(0xFF6366F1),
              top: 180 + 40 * (1 - t),
              left: 20,
              size: 200,
              opacity: 0.07,
            ),
          ],
        );
      },
    );
  }

  static Widget _glowOrb({
    required Color color,
    required double size,
    required double opacity,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
