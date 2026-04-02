import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../constants/colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blur = 10,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                color: backgroundColor ?? Colors.white.withOpacity(0.05),
                borderRadius: borderRadius,
                border:
                    border ?? Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: boxShadow,
              ),
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const GlassIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      onTap: onPressed,
      child: Icon(icon, color: color ?? NEGsColors.primaryCyan, size: size),
    );
  }
}
