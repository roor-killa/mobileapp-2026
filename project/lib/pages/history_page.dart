import 'package:flutter/material.dart';
import '../models/operation.dart';

class HistoryPage extends StatelessWidget {
  final List<Operation> history;

  const HistoryPage({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: history.isEmpty
          ? const Center(
              child: Text(
                'Aucune opération effectuée.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historique des opérations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final operation = history[index];

                        final formattedDate =
                            '${operation.date.day.toString().padLeft(2, '0')}/'
                            '${operation.date.month.toString().padLeft(2, '0')}/'
                            '${operation.date.year} '
                            '${operation.date.hour.toString().padLeft(2, '0')}:'
                            '${operation.date.minute.toString().padLeft(2, '0')}';

                        final bool isDeposit = operation.type == 'Dépôt';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isDeposit
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  isDeposit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isDeposit ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      operation.type,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isDeposit ? '+' : '-'}${operation.amount.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDeposit ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}