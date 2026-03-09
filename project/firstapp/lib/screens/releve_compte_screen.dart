import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Version autonome (navigation directe) — conservée pour compatibilité.
class ReleveCompteScreen extends StatelessWidget {
  const ReleveCompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relevé de compte'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const HistoryTab(),
    );
  }
}

/// Contenu de l'historique — utilisé dans DashboardScreen comme onglet.
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String _filtre = 'tout'; // 'tout' | 'envoi' | 'reception' | 'echec'

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

  List<TransactionModel> get _transactionsFiltrees {
    if (_filtre == 'tout') return _transactions;
    if (_filtre == 'echec') {
      return _transactions.where((t) => t.statut == 'echec').toList();
    }
    return _transactions
        .where((t) => t.statut == 'succes' && t.type == _filtre)
        .toList();
  }

  double get _totalEnvoye => _transactions
      .where((t) => t.statut == 'succes' && t.type == 'envoi')
      .fold(0.0, (sum, t) => sum + t.montant);

  double get _totalRecu => _transactions
      .where((t) => t.statut == 'succes' && t.type == 'reception')
      .fold(0.0, (sum, t) => sum + t.montant);

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

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _chargerTransactions,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserCard(user.nom, user.email),
                  const SizedBox(height: 16),
                  _buildSoldesCard(user.soldeInitial, user.soldeActuel),
                  const SizedBox(height: 16),
                  _buildStatsCard(),
                  const SizedBox(height: 24),
                  _buildHistoriqueHeader(),
                  const SizedBox(height: 8),
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  _buildTransactionList(),
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

  Widget _buildStatsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.arrow_upward,
                iconColor: Colors.orange.shade800,
                label: 'Total envoyé',
                value: '- ${_totalEnvoye.toStringAsFixed(2)} €',
                valueColor: Colors.orange.shade800,
              ),
            ),
            Container(width: 1, height: 50, color: Colors.grey.shade200),
            Expanded(
              child: _buildStatItem(
                icon: Icons.arrow_downward,
                iconColor: Colors.green,
                label: 'Total reçu',
                value: '+ ${_totalRecu.toStringAsFixed(2)} €',
                valueColor: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoriqueHeader() {
    return Row(
      children: [
        const Icon(Icons.history, color: Colors.blue),
        const SizedBox(width: 8),
        const Text(
          'Historique des transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          '${_transactionsFiltrees.length} opération${_transactionsFiltrees.length > 1 ? 's' : ''}',
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('tout', 'Tout', Colors.blue),
      ('envoi', 'Envois', Colors.orange),
      ('reception', 'Reçus', Colors.green),
      ('echec', 'Échecs', Colors.red),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final (value, label, color) = f;
          final isSelected = _filtre == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _filtre = value),
              selectedColor: color.withValues(alpha:0.2),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isSelected ? color : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    final liste = _transactionsFiltrees;

    if (liste.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Aucune transaction pour ce filtre',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: liste.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) => _buildTransactionCard(liste[index]),
    );
  }

  Widget _buildTransactionCard(TransactionModel t) {
    final isSuccess = t.statut == 'succes';
    final isReception = t.type == 'reception';
    final isEnvoi = t.type == 'envoi';

    final Color iconBg;
    final Color iconColor;
    final IconData iconData;
    if (!isSuccess) {
      iconBg = Colors.red.shade100;
      iconColor = Colors.red;
      iconData = Icons.close;
    } else if (isReception) {
      iconBg = Colors.green.shade100;
      iconColor = Colors.green;
      iconData = Icons.arrow_downward;
    } else {
      iconBg = Colors.orange.shade100;
      iconColor = Colors.orange.shade800;
      iconData = Icons.arrow_upward;
    }

    final String montantAffiche;
    final Color montantColor;
    if (isReception) {
      montantAffiche = '+ ${t.montant.toStringAsFixed(2)} €';
      montantColor = Colors.green.shade700;
    } else if (isSuccess && isEnvoi) {
      montantAffiche = '- ${t.montant.toStringAsFixed(2)} €';
      montantColor = Colors.red.shade700;
    } else {
      montantAffiche = '- ${t.montant.toStringAsFixed(2)} €';
      montantColor = isSuccess ? Colors.red.shade700 : Colors.red.shade300;
    }

    return Card(
      elevation: 2,
      color: isSuccess ? Colors.white : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
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
            Text(
              montantAffiche,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: montantColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
