import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';
import 'package:app_bkn/providers/transaction_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final stats = await ApiService.getStats();
    
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
            : RefreshIndicator(
                onRefresh: _loadStats,
                color: AppTheme.primaryBlue,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildTotalUsersCard(),
                    const SizedBox(height: 16),
                    _buildTotalVolumeCard(),
                    const SizedBox(height: 16),
                    _buildTodayTransactionsCard(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTotalUsersCard() {
    final totalUsers = _stats['total_users'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight, 
          colors: [Color(0xFF5856D6), Color(0xFF007AFF)]
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5856D6).withValues(alpha: 0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), 
              borderRadius: BorderRadius.circular(16)
            ),
            child: const Icon(Icons.people, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Utilisateurs', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text('$totalUsers', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalVolumeCard() {
    final volume = _stats['total_transactions_volume'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight, 
          colors: [Color(0xFF34C759), Color(0xFF30B0C0)]
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34C759).withValues(alpha: 0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), 
              borderRadius: BorderRadius.circular(16)
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Volume total', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${volume.toStringAsFixed(0)} BKN', 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTransactionsCard() {
    final today = _stats['today_transactions'] ?? {'count': 0, 'volume': 0};
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.today, color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Aujourd\'hui', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTodayStat('Transactions', '${today['count']}', Icons.swap_horiz, AppTheme.primaryBlue),
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              _buildTodayStat('Volume', '${today['volume']} BKN', Icons.euro, AppTheme.secondaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), 
            shape: BoxShape.circle
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final recentTransactions = transactionProvider.transactions.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text('Activité récente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ),
        ...recentTransactions.map((t) => _buildRecentTransactionTile(t)),
        if (recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Center(
              child: Text('Aucune transaction récente', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentTransactionTile(Map<String, dynamic> t) {
    final montant = t['montant'].toDouble();
    final isEnvoi = t['expediteur_pseudo'] == ApiService.currentUserPseudo;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEnvoi ? Icons.arrow_upward : Icons.arrow_downward,
              color: isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnvoi ? 'Envoi à ${t['destinataire_pseudo']}' : 'Réception de ${t['expediteur_pseudo']}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(t['date']),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isEnvoi ? '-' : '+'}${montant.toStringAsFixed(0)} BKN',
            style: TextStyle(
              color: isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}