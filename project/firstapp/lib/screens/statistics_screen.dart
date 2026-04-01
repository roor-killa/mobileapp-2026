import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';

/// Onglet Statistiques avec graphiques dessinés via CustomPainter.
class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  double _budgetMensuel = 0.0;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final user = AuthService.utilisateurConnecte!;
    final txs = await DatabaseService.instance.getTransactions(user.id!);
    final budget = await PreferencesService.instance.getBudgetMensuel(user.id!.toString());
    if (!mounted) return;
    setState(() {
      _transactions = txs;
      _budgetMensuel = budget;
      _isLoading = false;
    });
  }

  double get _depenseMoisCourant {
    final now = DateTime.now();
    return _transactions
        .where((t) {
          if (t.statut != 'succes' || t.type != 'envoi') return false;
          final dt = DateTime.parse(t.dateHeure);
          return dt.year == now.year && dt.month == now.month;
        })
        .fold(0.0, (s, t) => s + t.montant);
  }

  Future<void> _definirBudget() async {
    final ctrl = TextEditingController(
      text: _budgetMensuel > 0 ? _budgetMensuel.toStringAsFixed(0) : '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budget mensuel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Définissez votre limite de dépenses mensuelle.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Budget (€)',
                suffixText: '€',
                hintText: 'Ex: 500',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          if (_budgetMensuel > 0)
            TextButton(
              onPressed: () async {
                await PreferencesService.instance.setBudgetMensuel(AuthService.utilisateurConnecte!.id!.toString(), 0);
                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: const Text('Désactiver', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != true) return;
    final val = double.tryParse(ctrl.text.trim());
    if (val != null && val > 0) {
      await PreferencesService.instance.setBudgetMensuel(AuthService.utilisateurConnecte!.id!.toString(), val);
    }
    await _charger();
  }

  // --- Calculs ---

  double get _totalEnvoye => _transactions
      .where((t) => t.statut == 'succes' && t.type == 'envoi')
      .fold(0.0, (s, t) => s + t.montant);

  double get _totalRecu => _transactions
      .where((t) => t.statut == 'succes' && t.type == 'reception')
      .fold(0.0, (s, t) => s + t.montant);

  int get _nbEnvois =>
      _transactions.where((t) => t.statut == 'succes' && t.type == 'envoi').length;

  int get _nbReceptions =>
      _transactions.where((t) => t.statut == 'succes' && t.type == 'reception').length;

  int get _nbEchecs => _transactions.where((t) => t.statut == 'echec').length;

  /// Retourne les totaux envoyés par mois sur les 6 derniers mois.
  List<_MonthData> get _monthlyData {
    final now = DateTime.now();
    final result = <_MonthData>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final sent = _transactions
          .where((t) {
            final dt = DateTime.parse(t.dateHeure);
            return t.statut == 'succes' &&
                t.type == 'envoi' &&
                dt.year == month.year &&
                dt.month == month.month;
          })
          .fold(0.0, (s, t) => s + t.montant);
      final received = _transactions
          .where((t) {
            final dt = DateTime.parse(t.dateHeure);
            return t.statut == 'succes' &&
                t.type == 'reception' &&
                dt.year == month.year &&
                dt.month == month.month;
          })
          .fold(0.0, (s, t) => s + t.montant);
      result.add(_MonthData(month: month, envoye: sent, recu: received));
    }
    return result;
  }

  static const _moisCourt = [
    '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final envoye = _totalEnvoye;
    final recu = _totalRecu;
    final monthly = _monthlyData;

    return RefreshIndicator(
      onRefresh: _charger,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Résumé ---
            _buildSummaryRow(),
            const SizedBox(height: 20),

            // --- Graphique donut ---
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Répartition Envoyé / Reçu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (envoye == 0 && recu == 0)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Aucune transaction réussie',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 160,
                              child: CustomPaint(
                                painter: _DonutChartPainter(
                                  envoye: envoye,
                                  recu: recu,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(
                                color: Colors.orange.shade700,
                                label: 'Envoyé',
                                value: '${envoye.toStringAsFixed(2)} €',
                              ),
                              const SizedBox(height: 8),
                              _buildLegendItem(
                                color: Colors.green.shade600,
                                label: 'Reçu',
                                value: '${recu.toStringAsFixed(2)} €',
                              ),
                              const SizedBox(height: 8),
                              if (envoye + recu > 0)
                                _buildLegendItem(
                                  color: AppColors.primary,
                                  label: 'Net',
                                  value:
                                      '${(recu - envoye) >= 0 ? '+' : ''}${(recu - envoye).toStringAsFixed(2)} €',
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Graphique barres mensuelles ---
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activité des 6 derniers mois',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildLegendDot(Colors.orange.shade700, 'Envoyé'),
                        const SizedBox(width: 12),
                        _buildLegendDot(Colors.green.shade600, 'Reçu'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: CustomPaint(
                        size: const Size(double.infinity, 180),
                        painter: _BarChartPainter(
                          data: monthly,
                          moisCourt: _moisCourt,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Budget mensuel ---
            _buildBudgetCard(),

            const SizedBox(height: 16),

            // --- Détails transactions ---
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails des opérations',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.arrow_upward,
                      color: Colors.orange.shade700,
                      label: 'Virements effectués',
                      value: '$_nbEnvois opération${_nbEnvois > 1 ? 's' : ''}',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.arrow_downward,
                      color: Colors.green.shade600,
                      label: 'Virements reçus',
                      value: '$_nbReceptions opération${_nbReceptions > 1 ? 's' : ''}',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.close,
                      color: Colors.red,
                      label: 'Transactions échouées',
                      value: '$_nbEchecs opération${_nbEchecs > 1 ? 's' : ''}',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.receipt_long,
                      color: AppColors.primary,
                      label: 'Total opérations',
                      value: '${_transactions.length}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
    final depense = _depenseMoisCourant;
    final budget = _budgetMensuel;
    final hasBudget = budget > 0;
    final progression = hasBudget ? (depense / budget).clamp(0.0, 1.0) : 0.0;
    final depasse = depense > budget && hasBudget;
    const mois = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    final nomMois = mois[DateTime.now().month];

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Budget mensuel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _definirBudget,
                  icon: Icon(hasBudget ? Icons.edit : Icons.add, size: 16),
                  label: Text(hasBudget ? 'Modifier' : 'Définir'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (!hasBudget)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Aucun budget défini pour $nomMois',
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${depense.toStringAsFixed(2)} € dépensés',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: depasse ? Colors.red : AppColors.primary,
                    ),
                  ),
                  Text(
                    'sur ${budget.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progression,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    depasse ? Colors.red : (progression > 0.8 ? Colors.orange : Colors.green),
                  ),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 6),
              if (depasse)
                Text(
                  'Budget dépassé de ${(depense - budget).toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                )
              else
                Text(
                  'Reste ${(budget - depense).toStringAsFixed(2)} € (${((1 - progression) * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final user = AuthService.utilisateurConnecte!;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.account_balance_wallet,
            color: AppColors.primary,
            label: 'Solde actuel',
            value: '${user.soldeActuel.toStringAsFixed(2)} €',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.swap_horiz,
            color: Colors.indigo,
            label: 'Transactions',
            value: '${_transactions.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── Donut Chart ──────────────────────────────────────────────────────────────

class _DonutChartPainter extends CustomPainter {
  final double envoye;
  final double recu;

  _DonutChartPainter({required this.envoye, required this.recu});

  @override
  void paint(Canvas canvas, Size size) {
    final total = envoye + recu;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;
    const strokeWidth = 28.0;

    final paintEnvoye = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintRecu = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintGap = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final envoyeAngle = (envoye / total) * 2 * math.pi;
    final recuAngle = 2 * math.pi - envoyeAngle;

    // Dessiner les segments
    if (envoyeAngle > 0) {
      canvas.drawArc(rect, startAngle, envoyeAngle, false, paintEnvoye);
    }
    if (recuAngle > 0) {
      canvas.drawArc(rect, startAngle + envoyeAngle, recuAngle, false, paintRecu);
    }

    // Séparation blanche
    if (envoyeAngle > 0 && recuAngle > 0) {
      final gapPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        center + Offset(math.cos(startAngle) * (radius - strokeWidth / 2),
            math.sin(startAngle) * (radius - strokeWidth / 2)),
        center + Offset(math.cos(startAngle) * (radius + strokeWidth / 2),
            math.sin(startAngle) * (radius + strokeWidth / 2)),
        gapPaint,
      );
      final mid = startAngle + envoyeAngle;
      canvas.drawLine(
        center + Offset(math.cos(mid) * (radius - strokeWidth / 2),
            math.sin(mid) * (radius - strokeWidth / 2)),
        center + Offset(math.cos(mid) * (radius + strokeWidth / 2),
            math.sin(mid) * (radius + strokeWidth / 2)),
        gapPaint,
      );
    }

    // Texte central : pourcentage envoyé
    final pct = ((envoye / total) * 100).toStringAsFixed(0);
    final tp = TextPainter(
      text: TextSpan(
        text: '$pct%\nenvoyé',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter old) =>
      old.envoye != envoye || old.recu != recu;
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

class _MonthData {
  final DateTime month;
  final double envoye;
  final double recu;
  _MonthData({required this.month, required this.envoye, required this.recu});
  double get max => math.max(envoye, recu);
}

class _BarChartPainter extends CustomPainter {
  final List<_MonthData> data;
  final List<String> moisCourt;

  _BarChartPainter({required this.data, required this.moisCourt});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const labelHeight = 20.0;
    const paddingLeft = 10.0;
    const paddingRight = 8.0;
    const paddingTop = 8.0;

    final chartH = size.height - labelHeight - paddingTop;
    final chartW = size.width - paddingLeft - paddingRight;
    final maxVal = data.map((d) => d.max).reduce(math.max);
    if (maxVal == 0) {
      // Aucune donnée : afficher message
      final tp = TextPainter(
        text: const TextSpan(
          text: 'Aucune donnée',
          style: TextStyle(color: Colors.black38, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2));
      return;
    }

    final n = data.length;
    final groupW = chartW / n;
    const barW = 10.0;
    const gap = 2.0;

    final paintEnvoye = Paint()..color = Colors.orange.shade700;
    final paintRecu = Paint()..color = Colors.green.shade600;
    final paintAxis = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;

    // Axe X
    canvas.drawLine(
      Offset(paddingLeft, paddingTop + chartH),
      Offset(size.width - paddingRight, paddingTop + chartH),
      paintAxis,
    );

    for (int i = 0; i < n; i++) {
      final d = data[i];
      final groupX = paddingLeft + i * groupW + groupW / 2;

      // Barre envoyé
      final envoyeH = maxVal > 0 ? (d.envoye / maxVal) * (chartH - 4) : 0.0;
      final recuH = maxVal > 0 ? (d.recu / maxVal) * (chartH - 4) : 0.0;

      final envoyeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupX - barW - gap / 2,
          paddingTop + chartH - envoyeH,
          barW,
          envoyeH,
        ),
        const Radius.circular(3),
      );
      final recuRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupX + gap / 2,
          paddingTop + chartH - recuH,
          barW,
          recuH,
        ),
        const Radius.circular(3),
      );

      if (d.envoye > 0) canvas.drawRRect(envoyeRect, paintEnvoye);
      if (d.recu > 0) canvas.drawRRect(recuRect, paintRecu);

      // Label mois
      final label = moisCourt[d.month.month];
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(groupX - tp.width / 2, paddingTop + chartH + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.data != data;
}
