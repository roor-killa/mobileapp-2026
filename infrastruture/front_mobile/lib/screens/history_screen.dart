import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String token;
  final String myUsername; // Pour savoir si j'ai reçu ou envoyé
  const HistoryScreen({super.key, required this.token, required this.myUsername});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final data = await ApiService.getTransactions(widget.token);
      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Transactions'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text('Aucune transaction pour le moment', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    // Est-ce que j'ai reçu (+) ou envoyé (-) ?
                    final isReceived = tx['receiver_name'] == widget.myUsername;
                    final otherPerson = isReceived ? tx['sender_name'] : tx['receiver_name'];
                    final date = DateTime.parse(tx['created_at']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: isReceived ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isReceived ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        title: Text(
                          isReceived ? 'Reçu de $otherPerson' : 'Envoyé à $otherPerson',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Text(
                          '${isReceived ? '+' : '-'}${tx['amount']} BKN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isReceived ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
