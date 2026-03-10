import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
  }

  Future<void> _chargerHistorique() async {
    final transactions = await _apiService.getTransactions();
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  // Petite fonction pour formater la date proprement
  String _formaterDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si ça charge, on montre un petit cercle
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si la liste est vide (aucun reçu)
    if (_transactions.isEmpty) {
      return const Center(
        child: Text(
          "Aucune transaction pour le moment.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Si on a des reçus, on affiche une belle liste
    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        
        // On détermine si c'est une entrée ou une sortie d'argent
        final isSortie = transaction['type'] == 'envoi';
        final montant = double.parse(transaction['montant'].toString());
        
        // Couleurs et symboles dynamiques
        final couleurMontant = isSortie ? Colors.red : Colors.green;
        final signe = isSortie ? "-" : "+";
        final icone = transaction['type'] == 'rechargement' 
            ? Icons.account_balance_wallet
            : (isSortie ? Icons.arrow_upward : Icons.arrow_downward);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: couleurMontant.withOpacity(0.1),
              child: Icon(icone, color: couleurMontant),
            ),
            title: Text(
              transaction['description'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _formaterDate(transaction['created_at']),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              "$signe ${montant.toStringAsFixed(2)} €",
              style: TextStyle(
                color: couleurMontant,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}