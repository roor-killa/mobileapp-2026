import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'savings_goals_screen.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onGoToTransfer;
  final VoidCallback? onGoToHistory;

  const HomeTab({super.key, this.onGoToTransfer, this.onGoToHistory});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<TransactionModel> _recentes = [];
  bool _isLoading = true;
  bool _balanceVisible = true;
  double _alerteSolde = 100.0;
  double _depenseMois = 0.0;
  double _recuMois = 0.0;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final user = AuthService.utilisateurConnecte!;
      final recentes = await DatabaseService.instance
          .getTransactionsRecentes(user.id!, limit: 5);
      final balVis = await PreferencesService.instance.getBalanceVisible();
      final alerte = await PreferencesService.instance.getAlerteSolde(user.id!.toString());

      // Calcul résumé du mois en cours
      final toutes = await DatabaseService.instance.getTransactions(user.id!);
      final now = DateTime.now();
      double depense = 0, recu = 0;
      for (final t in toutes) {
        if (t.statut != 'succes') continue;
        final dt = DateTime.parse(t.dateHeure);
        if (dt.year != now.year || dt.month != now.month) continue;
        if (t.type == 'envoi') depense += t.montant;
        if (t.type == 'reception') recu += t.montant;
      }

      if (!mounted) return;
      setState(() {
        _recentes = recentes;
        _isLoading = false;
        _balanceVisible = balVis;
        _alerteSolde = alerte;
        _depenseMois = depense;
        _recuMois = recu;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBalance() async {
    final newVal = !_balanceVisible;
    setState(() => _balanceVisible = newVal);
    await PreferencesService.instance.setBalanceVisible(newVal);
  }

  String _formaterDate(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    const mois = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${dt.day} ${mois[dt.month]} ${dt.year}';
  }

  /// Génère un numéro de compte virtuel formaté à partir de l'ID utilisateur.
  String _numeroCompte(int userId) {
    final base = userId.toString().padLeft(8, '0');
    return 'FR76 3000 6000 $base ${(userId * 17 % 97).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.utilisateurConnecte!;

    final alerteActive = user.soldeActuel < _alerteSolde;

    return RefreshIndicator(
      onRefresh: _charger,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSoldeHeader(user),

            // Alerte solde bas
            if (alerteActive)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solde bas : ${user.soldeActuel.toStringAsFixed(2)} € '
                        '(seuil : ${_alerteSolde.toStringAsFixed(0)} €)',
                        style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNumeroCompte(user.id!),
                  const SizedBox(height: 16),
                  _buildResumeMois(),
                  const SizedBox(height: 16),
                  _buildActionsRapides(context),
                  const SizedBox(height: 24),
                  _buildRecentesSection(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSoldeHeader(dynamic user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, ${user.nom.split(' ').first} 👋',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Votre solde disponible',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _balanceVisible
                    ? '${user.soldeActuel.toStringAsFixed(2)} €'
                    : '•••• €',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggleBalance,
                child: Icon(
                  _balanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Solde initial : ${_balanceVisible ? '${user.soldeInitial.toStringAsFixed(2)} €' : '•••• €'}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNumeroCompte(int userId) {
    final numero = _numeroCompte(userId);
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: numero));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro de compte copié'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                numero,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.copy, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeMois() {
    const mois = [
      '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    final nomMois = mois[DateTime.now().month];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ce mois-ci — $nomMois',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.orange.shade700, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '- ${_depenseMois.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('Dépensé', style: TextStyle(fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.green.shade700, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '+ ${_recuMois.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('Reçu', style: TextStyle(fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsRapides(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.send,
                label: 'Virement',
                color: AppColors.primary,
                onTap: widget.onGoToTransfer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.history,
                label: 'Historique',
                color: Colors.indigo,
                onTap: widget.onGoToHistory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.savings,
                label: 'Objectifs',
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions récentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.onGoToHistory != null)
              TextButton(
                onPressed: widget.onGoToHistory,
                child: const Text('Voir tout'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_recentes.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aucune transaction pour le moment',
                style: TextStyle(color: Colors.black45),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _buildTransactionTile(_recentes[i]),
          ),
      ],
    );
  }

  Widget _buildTransactionTile(TransactionModel t) {
    final isReception = t.type == 'reception';
    final isSuccess = t.statut == 'succes';

    final IconData icon;
    final Color color;
    if (!isSuccess) {
      icon = Icons.close;
      color = Colors.red;
    } else if (isReception) {
      icon = Icons.arrow_downward;
      color = Colors.green;
    } else {
      icon = Icons.arrow_upward;
      color = Colors.orange.shade800;
    }

    final String montant;
    final Color montantColor;
    if (isReception) {
      montant = '+ ${t.montant.toStringAsFixed(2)} €';
      montantColor = Colors.green.shade700;
    } else {
      montant = '- ${t.montant.toStringAsFixed(2)} €';
      montantColor = isSuccess ? Colors.red.shade700 : Colors.red.shade300;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        t.message,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formaterDate(t.dateHeure),
        style: const TextStyle(fontSize: 12, color: Colors.black45),
      ),
      trailing: Text(
        montant,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: montantColor,
        ),
      ),
    );
  }
}
