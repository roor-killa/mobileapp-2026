import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _transactionsFuture = _apiService.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTransactions,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: FutureBuilder<List<Transaction>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune transaction pour le moment.'));
            }

            final transactions = snapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionTile(tx);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction tx) {
    IconData icon;
    Color color;
    String amountString = tx.amount.toStringAsFixed(2);

    switch (tx.type) {
      case 'sent':
        icon = Icons.arrow_upward;
        color = Colors.redAccent;
        amountString = '$amountString €'; // Le montant est déjà négatif
        break;
      case 'received':
        icon = Icons.arrow_downward;
        color = Colors.green;
        amountString = '+$amountString €';
        break;
      case 'topup':
        icon = Icons.add_circle;
        color = Colors.blue;
        amountString = '+$amountString €';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(tx.details, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(tx.date.toLocal())),
      trailing: Text(amountString, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}