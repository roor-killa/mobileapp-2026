import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique")),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final transactions = snapshot.data!;
          
          if (transactions.isEmpty) return const Center(child: Text("Aucune transaction"));

          return ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final t = transactions[index];
              final isSent = t['type'] == 'sent';
              final color = isSent ? Colors.red : Colors.green;
              final sign = isSent ? "-" : "+";
              final date = DateFormat('dd/MM HH:mm').format(DateTime.parse(t['created_at']));

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(isSent ? Icons.arrow_upward : Icons.arrow_downward, color: color),
                ),
                title: Text(isSent ? "Envoyé" : "Reçu"),
                subtitle: Text(date),
                trailing: Text(
                  "$sign ${t['amount']} BKN",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
