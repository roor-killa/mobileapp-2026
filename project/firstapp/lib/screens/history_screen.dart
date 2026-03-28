import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A);

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
    try {
      // On utilise "dynamic" pour que Flutter arrête de paniquer sur le type de données
      final dynamic result = await _apiService.getTransactions();
      
      if (!mounted) return;
      
      // CAS 1 : Si ton serveur a renvoyé DIRECTEMENT la liste des transactions
      if (result is List) {
        setState(() {
          _transactions = List.from(result);
          _isLoading = false;
        });
      } 
      // CAS 2 : Si ton serveur a renvoyé un objet avec un "success"
      else if (result is Map) {
        if (result['success'] == true) {
          setState(() {
            _transactions = List.from(result['transactions']);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } 
      // CAS 3 : Réponse inconnue
      else {
        setState(() => _isLoading = false);
      }
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formaterDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade900)),
                child: const Icon(Icons.history, color: emerald500),
              ),
              const SizedBox(width: 15),
              const Text('Historique', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: emerald500))
              : _transactions.isEmpty
                  ? const Center(child: Text("Aucune transaction.", style: TextStyle(color: textGray)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        final type = transaction['type'];
                        
                        // Logique de sortie / entrée (Identique à ce qu'on a corrigé)
                        final isSortie = type == 'envoi' || type == 'achat_bkn';
                        final montant = double.parse(transaction['montant'].toString());
                        
                        final couleurMontant = isSortie ? Colors.white : emerald500;
                        final signe = isSortie ? "-" : "+";
                        
                        IconData icone;
                        if (type == 'rechargement') {
                          icone = Icons.account_balance_wallet;
                        } else if (type == 'achat_bkn' || type == 'vente_bkn') {
                          icone = Icons.currency_bitcoin;
                        } else {
                          icone = isSortie ? Icons.arrow_upward : Icons.arrow_downward;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade900)
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 45, height: 45,
                                decoration: BoxDecoration(
                                  color: bgDark,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(icone, color: textGray, size: 20),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(transaction['description'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(_formaterDate(transaction['created_at']), style: const TextStyle(color: textGray, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text(
                                "$signe ${montant.toStringAsFixed(2)} €",
                                style: TextStyle(color: couleurMontant, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}