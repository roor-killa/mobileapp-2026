import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class ReleveCompteScreen extends StatefulWidget {
  const ReleveCompteScreen({super.key});

  @override
  State<ReleveCompteScreen> createState() => _ReleveCompteScreenState();
}

class _ReleveCompteScreenState extends State<ReleveCompteScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerTransactions();
  }

  Future<void> _chargerTransactions() async {
    final user = AuthService.utilisateurConnecte!;
    final transactions = await DatabaseService.instance.getTransactions(user.id!);
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  String _formaterDate(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    const mois = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    final heure = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${mois[dt.month]} ${dt.year}, $heure:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.utilisateurConnecte!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relevé de compte'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Carte identité utilisateur
                  _buildUserCard(user.nom, user.email),

                  const SizedBox(height: 16),

                  // Carte soldes
                  _buildSoldesCard(user.soldeInitial, user.soldeActuel),

                  const SizedBox(height: 24),

                  // Titre historique
                  Row(
                    children: [
                      const Icon(Icons.history, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Historique des transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_transactions.length} opération${_transactions.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Liste des transactions
                  if (_transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Aucune transaction pour le moment',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) =>
                          _buildTransactionCard(_transactions[index]),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserCard(String nom, String email) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 28,
              child: Text(
                nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(email, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoldesCard(double soldeInitial, double soldeActuel) {
    return Card(
      elevation: 3,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Solde initial déposé',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${soldeInitial.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: Colors.blue.shade200),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Solde actuel',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${soldeActuel.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel t) {
    final isSuccess = t.statut == 'succes';

    return Card(
      elevation: 2,
      color: isSuccess ? Colors.white : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icône statut
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade100 : Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.arrow_upward : Icons.close,
                color: isSuccess ? Colors.green : Colors.red,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.message,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSuccess ? Colors.black87 : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formaterDate(t.dateHeure),
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  if (isSuccess) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${t.soldeAvant.toStringAsFixed(2)} € → ${t.soldeApres.toStringAsFixed(2)} €',
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            // Montant
            Text(
              '- ${t.montant.toStringAsFixed(2)} €',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSuccess ? Colors.red.shade700 : Colors.red.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
