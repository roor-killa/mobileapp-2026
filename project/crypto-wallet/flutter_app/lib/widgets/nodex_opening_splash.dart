import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Splash d’ouverture (animation point + cercle, style
/// [red_dot_splash_animation](https://github.com/abuanwar072/red_dot_splash_animation))
/// aux couleurs cyan NodEX. Appelé une fois au lancement de l’app.
class NodexOpeningSplash extends StatefulWidget {
  const NodexOpeningSplash({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<NodexOpeningSplash> createState() => _NodexOpeningSplashState();
}

class _NodexOpeningSplashState extends State<NodexOpeningSplash> {
  bool _dotCentered = false;
  bool _scaleBurst = false;
  bool _fadeOut = false;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _dotCentered = true);
      });
      Future<void>.delayed(const Duration(milliseconds: 920), () {
        if (mounted) setState(() => _scaleBurst = true);
      });
      Future<void>.delayed(const Duration(milliseconds: 2100), () {
        if (mounted) setState(() => _fadeOut = true);
      });
      // Si le fondu ne déclenche pas onEnd (cas rare), on enlève quand même l’overlay.
      Future<void>.delayed(const Duration(milliseconds: 3200), _completeOnce);
    });
  }

  void _completeOnce() {
    if (_notified) return;
    _notified = true;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;
    final midY = h / 2 - 12;

    return Material(
      color: AppTheme.background,
      child: AnimatedOpacity(
        opacity: _fadeOut ? 0 : 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        onEnd: () {
          if (_fadeOut) _completeOnce();
        },
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 1.1,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.12),
                    AppTheme.background,
                  ],
                ),
              ),
            ),
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 650),
                curve: const Cubic(0.58, -0.3, 0.365, 1),
                scale: _scaleBurst ? 22 : 1,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  child: Center(
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: _scaleBurst ? Colors.white : AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 520),
              curve: const Cubic(0.47, -1.26, 0.36, 1),
              left: (w / 2) - 12 - (_dotCentered ? 0 : 96),
              top: midY,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.primaryLight,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: h * 0.14,
              child: Column(
                children: [
                  Text(
                    'NodEX',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Portefeuille crypto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
