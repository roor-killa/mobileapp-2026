import 'package:flutter/material.dart';

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  final List<Map<String, dynamic>> actions = const [
    {'icon': Icons.add_shopping_cart, 'label': 'Acheter', 'route': '/buy'},
    {'icon': Icons.monetization_on, 'label': 'Vendre', 'route': '/sell'},
    {'icon': Icons.send, 'label': 'Transférer', 'route': '/transfer'},
    {'icon': Icons.qr_code, 'label': 'Recevoir', 'route': '/qr_receive'},
    {'icon': Icons.history, 'label': 'Historique', 'route': '/history'},
    {'icon': Icons.chat, 'label': 'Chatbot', 'route': '/chatbot'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionButton(
          context,
          icon: action['icon'],
          label: action['label'],
          route: action['route'],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2472).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF0A2472), size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A2472),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}