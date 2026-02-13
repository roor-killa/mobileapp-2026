import 'package:flutter/material.dart';
import 'package:app_bkn/theme/app_theme.dart';

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  final List<Map<String, dynamic>> actions = const [
    {'icon': Icons.add_shopping_cart, 'label': 'Acheter', 'route': '/buy', 'color': Color(0xFF007AFF)},
    {'icon': Icons.monetization_on, 'label': 'Vendre', 'route': '/sell', 'color': Color(0xFFFF3B30)},
    {'icon': Icons.send, 'label': 'Transférer', 'route': '/transfer', 'color': Color(0xFF5856D6)},
    {'icon': Icons.qr_code, 'label': 'Recevoir', 'route': '/qr_receive', 'color': Color(0xFF34C759)},
    {'icon': Icons.history, 'label': 'Historique', 'route': '/history', 'color': Color(0xFFFF9500)},
    {'icon': Icons.chat, 'label': 'Chatbot', 'route': '/chatbot', 'color': Color(0xFF64D2FF)},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
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
          color: action['color'],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}