import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Bande lumineuse qui balaie la surface (effet proche des apps type YouTube / e-commerce).
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 12,
  });

  final double? height;
  final double? width;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.cardElevated;
    final highlight = AppTheme.primary.withValues(alpha: 0.22);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.2 + 2.4 * t, 0),
              end: Alignment(-0.2 + 2.4 * t, 0),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// Mise en page « fantôme » du tableau de bord pendant le chargement des wallets.
class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          children: [
            const ShimmerBox(height: 48, width: 48, borderRadius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(height: 14, width: 100, borderRadius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(height: 18, width: MediaQuery.sizeOf(context).width * 0.4, borderRadius: 6),
                ],
              ),
            ),
            const ShimmerBox(height: 44, width: 44, borderRadius: 12),
          ],
        ),
        const SizedBox(height: 16),
        const ShimmerBox(height: 140, width: double.infinity, borderRadius: 20),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: ShimmerBox(height: 72, width: double.infinity, borderRadius: 14)),
            const SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 72, width: double.infinity, borderRadius: 14)),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: List.generate(
            5,
            (_) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ShimmerBox(height: 54, width: double.infinity, borderRadius: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const ShimmerBox(height: 22, width: 120, borderRadius: 6),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ShimmerBox(height: 72, width: double.infinity, borderRadius: 14),
          ),
        ),
      ],
    );
  }
}
