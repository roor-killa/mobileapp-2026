import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/providers/transaction_provider.dart';
import 'package:app_bkn/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _copiedId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (ApiService.currentUserId != null) {
      await context.read<TransactionProvider>().loadTransactions(
        ApiService.currentUserId!,
        limit: 50,
      );
    }
  }

  void _copyTransactionId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    setState(() => _copiedId = id);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedId = null);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📋 ID copié dans le presse-papiers'),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'TRANSACTIONS'),
            Tab(text: 'ANALYTIQUE'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTransactionsView(),
            _buildAnalyticsView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsView() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          );
        }

        if (provider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune transaction',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vos transactions apparaîtront ici',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final t = provider.transactions[index];
            final isEnvoi = t['expediteur_pseudo'] == ApiService.currentUserPseudo;
            
            return _buildTransactionCard(t, isEnvoi, index)
                .animate()
                .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                .slideX(begin: 0.1, end: 0);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> t, bool isEnvoi, int index) {
    final date = DateTime.parse(t['date']);
    final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(date);
    final montant = t['montant'].toDouble();
    final transactionId = t['id'] ?? 'Inconnu';
    
    Color getColor() {
      if (t['type'] == 'achat' || t['type'] == 'reception') {
        return AppTheme.secondaryGreen;
      }
      return AppTheme.errorRed;
    }

    IconData getIcon() {
      switch (t['type']) {
        case 'achat':
          return Icons.shopping_cart;
        case 'vente':
          return Icons.monetization_on;
        case 'transfert':
          return isEnvoi ? Icons.arrow_upward : Icons.arrow_downward;
        case 'reception':
          return Icons.qr_code;
        default:
          return Icons.swap_horiz;
      }
    }

    String getTitle() {
      if (t['type'] == 'transfert') {
        return isEnvoi 
            ? 'Envoi à ${t['destinataire_pseudo'] ?? '?'}'
            : 'Réception de ${t['expediteur_pseudo'] ?? '?'}';
      } else if (t['type'] == 'achat') {
        return 'Achat BKN';
      } else if (t['type'] == 'vente') {
        return 'Vente BKN';
      } else if (t['type'] == 'reception') {
        return 'Réception BKN';
      }
      return 'Transaction';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: getColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    getIcon(),
                    color: getColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTitle(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (t['description'] != null && t['description'].isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          t['description'],
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Montant
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isEnvoi ? '-' : '+'}${montant.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '≈ ${montant.toStringAsFixed(0)} €',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // ✅ LIGNE D'ID DE TRANSACTION (avec bouton copier)
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt, size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transactionId,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade700,
                        fontWeight: _copiedId == transactionId ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: _copiedId == transactionId 
                          ? AppTheme.secondaryGreen.withValues(alpha: 0.1)
                          : AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _copiedId == transactionId ? Icons.check : Icons.copy,
                        size: 14,
                        color: _copiedId == transactionId 
                            ? AppTheme.secondaryGreen 
                            : AppTheme.primaryBlue,
                      ),
                      onPressed: () => _copyTransactionId(transactionId),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatCard(
            'Volume total',
            '24 500 BKN',
            Icons.trending_up,
            AppTheme.primaryBlue,
          )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.1, end: 0),
          
          const SizedBox(height: 16),
          
          _buildStatCard(
            'Transactions',
            '156',
            Icons.swap_horiz,
            AppTheme.accentPurple,
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 100.ms)
          .slideX(begin: -0.1, end: 0),
          
          const SizedBox(height: 16),
          
          _buildStatCard(
            'Moyenne',
            '157 BKN',
            Icons.calculate,
            AppTheme.secondaryGreen,
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}