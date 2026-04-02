import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NEGsLogo extends StatelessWidget {
  final double size;
  final bool animated;

  const NEGsLogo({Key? key, this.size = 100, this.animated = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Diamant (carré tourné 45°)
          Transform.rotate(
            angle: 0.785398, // 45 degrés en radians
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                gradient: NEGsGradients.cardGradient,
                borderRadius: BorderRadius.circular(size * 0.12),
                border: Border.all(
                  color: NEGsColors.primaryCyan.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: NEGsColors.primaryViolet.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Texte "N" au centre
          Text(
            'N',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class NEGsLogoText extends StatelessWidget {
  final double fontSize;

  const NEGsLogoText({Key? key, this.fontSize = 32}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'N',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: NEGsColors.primaryViolet,
            letterSpacing: 1,
          ),
        ),
        Text(
          'E',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: NEGsColors.primaryCyan,
            letterSpacing: 1,
          ),
        ),
        Text(
          'G',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: NEGsColors.accentGreen,
            letterSpacing: 1,
          ),
        ),
        Text(
          "'s",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class NEGsBranding extends StatelessWidget {
  final double logoSize;

  const NEGsBranding({Key? key, this.logoSize = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NEGsLogo(size: logoSize),
        const SizedBox(height: 12),
        NEGsLogoText(fontSize: logoSize * 0.4),
        const SizedBox(height: 8),
        Text(
          'Votre vie financière, notre priorité',
          style: TextStyle(
            fontSize: 12,
            color: NEGsColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
