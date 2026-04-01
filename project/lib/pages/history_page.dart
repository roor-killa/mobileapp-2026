import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> history = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final data = await ApiService.getHistory();

      setState(() {
        history = data;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String getOperationLabel(String type) {
    switch (type) {
      case 'deposit':
        return 'Dépôt';
      case 'withdraw':
        return 'Retrait';
      case 'transfer_sent':
        return 'Virement envoyé';
      case 'transfer_received':
        return 'Virement reçu';
      case 'crypto_buy':
        return 'Achat crypto';
      case 'crypto_sell':
        return 'Vente crypto';
      default:
        return type;
    }
  }

  IconData getOperationIcon(String type) {
    switch (type) {
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdraw':
        return Icons.arrow_upward;
      case 'transfer_sent':
        return Icons.north_east;
      case 'transfer_received':
        return Icons.south_west;
      case 'crypto_buy':
        return Icons.currency_bitcoin;
      case 'crypto_sell':
        return Icons.sell;
      default:
        return Icons.receipt_long;
    }
  }

  Color getOperationColor(String type) {
    switch (type) {
      case 'deposit':
        return Colors.green;
      case 'withdraw':
        return Colors.red;
      case 'transfer_sent':
        return Colors.orange;
      case 'transfer_received':
        return Colors.teal;
      case 'crypto_buy':
        return Colors.amber.shade800;
      case 'crypto_sell':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  bool isPositiveOperation(String type) {
    return type == 'deposit' ||
        type == 'transfer_received' ||
        type == 'crypto_sell';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: loadHistory,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : history.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune opération effectuée.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadHistory,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Historique des opérations',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...history.map((operation) {
                            final String type = operation['type'] ?? '';
                            final String label = getOperationLabel(type);
                            final IconData icon = getOperationIcon(type);
                            final Color color = getOperationColor(type);
                            final bool isPositive = isPositiveOperation(type);
                            final double amount = double.tryParse(
                                  operation['amount'].toString(),
                                ) ??
                                0.0;
                            final String formattedDate =
                                formatDate(operation['created_at']);
                            final String? description =
                                operation['description'];

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
                                    backgroundColor: color.withOpacity(0.12),
                                    child: Icon(
                                      icon,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
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
                                        if (description != null &&
                                            description.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              description,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isPositive ? '+' : '-'}${amount.toStringAsFixed(2)} €',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
    );
  }
}