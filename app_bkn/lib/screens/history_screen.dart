import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Données EXACTEMENT comme ton storyboard
  final List<Map<String, dynamic>> _transactions = const [
    {
      'date': '02/02/2024 - 01:00',
      'montant': 1800,
      'type': 'achat',
    },
    {
      'date': '04/02/2024 - 04:00',
      'montant': 1600,
      'type': 'vente',
    },
    {
      'date': '05/02/2024 - 14:30',
      'montant': 500,
      'type': 'transfert',
    },
    {
      'date': '06/02/2024 - 10:15',
      'montant': 300,
      'type': 'reception',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          final isPositive = transaction['type'] == 'achat' || transaction['type'] == 'reception';
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isPositive 
                  ? const Color(0xFF00C9A7).withOpacity(0.1)
                  : const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(transaction['type']),
                color: isPositive ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B),
                size: 22,
              ),
            ),
            title: Text(
              _getTitle(transaction['type']),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              transaction['date'],
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : '-'}${transaction['montant']} BKN',
                  style: TextStyle(
                    color: isPositive ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '≈ ${transaction['montant']} €',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'achat':
        return Icons.shopping_cart;
      case 'vente':
        return Icons.attach_money;
      case 'transfert':
        return Icons.send;
      case 'reception':
        return Icons.qr_code;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTitle(String type) {
    switch (type) {
      case 'achat':
        return 'Achat BKN';
      case 'vente':
        return 'Vente BKN';
      case 'transfert':
        return 'Transfert vers @john';
      case 'reception':
        return 'Reçu de @marie';
      default:
        return 'Transaction';
    }
  }
}