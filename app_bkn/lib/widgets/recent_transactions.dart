import 'package:flutter/material.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

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
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _transactions.map((transaction) {
        final isAchat = transaction['type'] == 'achat';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isAchat
                    ? const Color(0xFF00C9A7).withOpacity(0.1)
                    : const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAchat ? Icons.arrow_downward : Icons.arrow_upward,
                color: isAchat ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B),
                size: 22,
              ),
            ),
            title: Text(
              isAchat ? 'Achat BKN' : 'Vente BKN',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              transaction['date'],
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isAchat ? '+' : '-'}${transaction['montant']} BKN',
                  style: TextStyle(
                    color: isAchat ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '≈ ${transaction['montant']} €',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}