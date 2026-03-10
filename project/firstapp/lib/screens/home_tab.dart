import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final user = AuthService.utilisateurConnecte!;
    final recentes = await DatabaseService.instance
        .getTransactionsRecentes(user.id!, limit: 5);
    if (!mounted) return;
    setState(() {
      _recentes = recentes;
      _isLoading = false;
    });
  }

  String _formaterDate(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    const mois = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${dt.day} ${mois[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.utilisateurConnecte!;

    return RefreshIndicator(
      onRefresh: _charger,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSoldeHeader(user),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
          Text(
            '${user.soldeActuel.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Solde initial : ${user.soldeInitial.toStringAsFixed(2)} €',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
