import 'dart:async';

import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Carrousel auto-inspiré du template FlutterShop ([OffersCarousel](https://github.com/abuanwar072/E-commerce-Complete-Flutter-UI)) :
/// défilement périodique + points indicateurs.
class NodexSpotlightCarousel extends StatefulWidget {
  const NodexSpotlightCarousel({super.key});

  @override
  State<NodexSpotlightCarousel> createState() => _NodexSpotlightCarouselState();
}

class _NodexSpotlightCarouselState extends State<NodexSpotlightCarousel> {
  int _page = 0;
  late PageController _controller;
  Timer? _timer;

  static const _slides = <_Slide>[
    _Slide(
      title: 'Virements instantanés',
      subtitle: 'Envoyez des euros entre utilisateurs NodEX en quelques secondes.',
      icon: Icons.bolt_rounded,
      colors: [Color(0xFF0E7490), Color(0xFF4F46E5)],
    ),
    _Slide(
      title: 'Crypto & carte',
      subtitle: 'Suivez vos actifs et votre carte virtuelle au même endroit.',
      icon: Icons.hub_rounded,
      colors: [Color(0xFF5B21B6), Color(0xFF0E7490)],
    ),
    _Slide(
      title: 'Assistant intelligent',
      subtitle: 'Posez vos questions : solde, IBAN, virements — réponses basées sur vos données.',
      icon: Icons.smart_toy_rounded,
      colors: [Color(0xFF4F46E5), Color(0xFF6D28D9)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = _page < _slides.length - 1 ? _page + 1 : 0;
      setState(() => _page = next);
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final s = _slides[i];
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: s.colors,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(s.icon, color: Colors.white.withValues(alpha: 0.95), size: 40),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: i == _page ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _page
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _Slide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}
