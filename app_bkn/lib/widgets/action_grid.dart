import 'package:flutter/material.dart';
import 'package:app_bkn/theme/app_theme.dart';

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  final List<Map<String, dynamic>> actions = const [
    {'icon': Icons.shopping_cart, 'label': 'Acheter', 'route': '/buy', 'gradient': [AppTheme.primaryBlue, Color(0xFF6B8CFF)]},
    {'icon': Icons.monetization_on, 'label': 'Vendre', 'route': '/sell', 'gradient': [AppTheme.primaryPink, Color(0xFFFF4D8C)]},
    {'icon': Icons.send, 'label': 'Transférer', 'route': '/transfer', 'gradient': [AppTheme.accentPurple, Color(0xFFB983FF)]},
    {'icon': Icons.qr_code, 'label': 'Recevoir', 'route': '/qr_receive', 'gradient': [AppTheme.secondaryGreen, Color(0xFF4ECDC4)]},
    {'icon': Icons.currency_bitcoin, 'label': 'Crypto', 'route': '/crypto', 'gradient': [Color(0xFFF7931A), Color(0xFFFFB347)]},
    {'icon': Icons.history, 'label': 'Historique', 'route': '/history', 'gradient': [AppTheme.warningOrange, Color(0xFFFFB347)]},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionButton(
          context,
          icon: action['icon'],
          label: action['label'],
          route: action['route'],
          gradient: action['gradient'] as List<Color>,
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required List<Color> gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}