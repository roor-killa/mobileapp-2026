import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double solde;

  const BalanceCard({super.key, required this.solde});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2472).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '1 BKN = 1 €',
                    style: TextStyle(
                      color: Color(0xFF0A2472),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.account_balance_wallet, color: Color(0xFF0A2472)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Solde',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${solde.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2472),
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'BKN',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '≈ ${solde.toStringAsFixed(2)} €',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}