import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

/// Version autonome (navigation directe) — conservée pour compatibilité.
class ReleveCompteScreen extends StatelessWidget {
  const ReleveCompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relevé de compte'),
        backgroundColor: AppColors.primary,
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
  String _searchQuery = '';
  DateTime? _dateDebut;
  DateTime? _dateFin;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerTransactions();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
    var liste = _transactions;

    // Filtre type
    if (_filtre == 'echec') {
      liste = liste.where((t) => t.statut == 'echec').toList();
    } else if (_filtre != 'tout') {
      liste = liste.where((t) => t.statut == 'succes' && t.type == _filtre).toList();
    }

    // Filtre date
    if (_dateDebut != null) {
      liste = liste
          .where((t) => DateTime.parse(t.dateHeure).isAfter(
                _dateDebut!.subtract(const Duration(seconds: 1)),
              ))
          .toList();
    }
    if (_dateFin != null) {
      final fin = DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day, 23, 59, 59);
      liste = liste
          .where((t) => DateTime.parse(t.dateHeure).isBefore(fin))
          .toList();
    }

    // Filtre recherche
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      liste = liste
          .where((t) =>
              t.message.toLowerCase().contains(q) ||
              (t.autrePartieNom?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return liste;
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

  String _formaterDateCourte(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _choisirDate({required bool isDebut}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? (_dateDebut ?? now) : (_dateFin ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isDebut) {
        _dateDebut = picked;
      } else {
        _dateFin = picked;
      }
    });
  }

  void _reinitialiserFiltres() {
    setState(() {
      _filtre = 'tout';
      _searchQuery = '';
      _dateDebut = null;
      _dateFin = null;
      _searchCtrl.clear();
    });
  }

  Future<void> _exporterHistorique() async {
    final liste = _transactionsFiltrees;
    if (liste.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune transaction à exporter')),
      );
      return;
    }

    final user = AuthService.utilisateurConnecte!;
    final buffer = StringBuffer();
    buffer.writeln('=== RELEVÉ VLT BANK ===');
    buffer.writeln('Compte : ${user.nom} (${user.email})');
    buffer.writeln('Exporté le : ${_formaterDateCourte(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('Date\t\t\tMontant\tType\tStatut\tMessage');
    buffer.writeln('─' * 60);

    for (final t in liste) {
      final dt = DateTime.parse(t.dateHeure).toLocal();
      final signe = t.type == 'reception' ? '+' : '-';
      buffer.writeln(
        '${_formaterDateCourte(dt)}\t'
        '${signe}${t.montant.toStringAsFixed(2)} €\t'
        '${t.type ?? '-'}\t'
        '${t.statut}\t'
        '${t.message}',
      );
    }

    buffer.writeln('');
    buffer.writeln('Total envoyé  : -${_totalEnvoye.toStringAsFixed(2)} €');
    buffer.writeln('Total reçu    : +${_totalRecu.toStringAsFixed(2)} €');
    buffer.writeln('Solde actuel  : ${user.soldeActuel.toStringAsFixed(2)} €');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relevé copié dans le presse-papiers'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
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

                  // Barre de recherche
                  _buildSearchBar(),
                  const SizedBox(height: 12),

                  // Filtres date
                  _buildDateFilters(),
                  const SizedBox(height: 12),

                  _buildHistoriqueHeader(),
                  const SizedBox(height: 8),
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  _buildTransactionList(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Rechercher une transaction...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: (v) => setState(() => _searchQuery = v),
    );
  }

  Widget _buildDateFilters() {
    final hasFilter = _dateDebut != null || _dateFin != null;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _choisirDate(isDebut: true),
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              _dateDebut != null ? _formaterDateCourte(_dateDebut!) : 'Date début',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _dateDebut != null ? AppColors.primary : Colors.grey,
              side: BorderSide(
                color: _dateDebut != null ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('→', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _choisirDate(isDebut: false),
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              _dateFin != null ? _formaterDateCourte(_dateFin!) : 'Date fin',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _dateFin != null ? AppColors.primary : Colors.grey,
              side: BorderSide(
                color: _dateFin != null ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        if (hasFilter || _searchQuery.isNotEmpty || _filtre != 'tout') ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: _reinitialiserFiltres,
            icon: const Icon(Icons.filter_alt_off, color: Colors.red),
            tooltip: 'Réinitialiser les filtres',
          ),
        ],
        const SizedBox(width: 4),
        IconButton(
          onPressed: _exporterHistorique,
          icon: const Icon(Icons.copy, color: AppColors.primary),
          tooltip: 'Copier le relevé',
        ),
      ],
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
              backgroundColor: AppColors.primary,
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
      color: AppColors.primaryLight,
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
            Container(width: 1, height: 50, color: AppColors.primaryMedium),
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
                      color: AppColors.primary,
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
        const Icon(Icons.history, color: AppColors.primary),
        const SizedBox(width: 8),
        const Text(
          'Historique des transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          '${_transactionsFiltrees.length} op.',
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('tout', 'Tout', AppColors.primary),
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
              selectedColor: color.withValues(alpha: 0.2),
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
