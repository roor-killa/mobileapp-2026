import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(refresh: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<TransactionProvider>().loadTransactions();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Navigator.canPop(context)
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context))
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => tx.loadTransactions(refresh: true),
          ),
        ],
      ),
      body: tx.transactions.isEmpty && tx.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : tx.transactions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textHint),
                      SizedBox(height: 16),
                      Text('Aucune transaction',
                          style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Text('Vos transferts apparaîtront ici',
                          style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => tx.loadTransactions(refresh: true),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    itemCount: tx.transactions.length + (tx.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == tx.transactions.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                          ),
                        );
                      }
                      return TransactionCard(transaction: tx.transactions[i]);
                    },
                  ),
                ),
    );
  }
}
