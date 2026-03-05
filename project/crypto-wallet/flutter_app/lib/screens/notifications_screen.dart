import 'package:flutter/material.dart';
import '../app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final _notifs = [
    _Notif(icon: Icons.arrow_downward_rounded, color: const Color(0xFF10B981), title: 'ETH reçu', body: 'Vous avez reçu 0.5 ETH de 0x8a2f...3e91', time: 'Il y a 2h', read: false),
    _Notif(icon: Icons.check_circle_rounded, color: AppTheme.primary, title: 'Virement envoyé', body: 'Virement de 150,00 € vers FR76...890 confirmé', time: 'Il y a 1j', read: false),
    _Notif(icon: Icons.swap_horiz_rounded, color: const Color(0xFFF59E0B), title: 'Échange effectué', body: '0.1 ETH échangé contre 8.5 SOL', time: 'Il y a 1j', read: true),
    _Notif(icon: Icons.credit_card_rounded, color: const Color(0xFF3B82F6), title: 'Paiement carte', body: 'Paiement de 32,50 € chez Restaurant Le Petit', time: 'Il y a 2j', read: true),
    _Notif(icon: Icons.account_balance_rounded, color: const Color(0xFF10B981), title: 'Virement reçu', body: 'Virement de 500,00 € reçu de Jean Dupont', time: 'Il y a 3j', read: true),
    _Notif(icon: Icons.security_rounded, color: Colors.orange, title: 'Connexion détectée', body: 'Nouvelle connexion depuis Chrome sur macOS', time: 'Il y a 4j', read: true),
    _Notif(icon: Icons.shopping_cart_rounded, color: const Color(0xFF3B82F6), title: 'Achat crypto', body: 'Achat de 0.012 BTC pour 744,00 €', time: 'Il y a 5j', read: true),
    _Notif(icon: Icons.account_balance_rounded, color: const Color(0xFF10B981), title: 'Virement reçu', body: 'Virement de 2 000,00 € reçu - Salaire', time: 'Il y a 10j', read: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Tout lire', style: TextStyle(color: AppTheme.primary, fontSize: 13))),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _notifs.length,
        itemBuilder: (context, i) {
          final n = _notifs[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.read ? AppTheme.card : AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: n.read ? null : Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: n.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(n.icon, color: n.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(n.title, style: TextStyle(color: AppTheme.textPrimary, fontWeight: n.read ? FontWeight.w500 : FontWeight.w700, fontSize: 14))),
                          if (!n.read) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n.body, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(n.time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool read;
  const _Notif({required this.icon, required this.color, required this.title, required this.body, required this.time, required this.read});
}
