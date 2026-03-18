import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Historique')),
      body: RefreshIndicator(
        onRefresh: () => context.read<TransactionProvider>().loadHistory(),
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('Aucune transaction',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.transactions.length,
                    itemBuilder: (_, i) =>
                        _TransactionTile(tx: provider.transactions[i]),
                  ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionTile({required this.tx});

  Future<void> _openAlgorand() async {
    final url = tx.blockchainExplorerUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.isDebit;
    final color   = isDebit ? AppColors.error : AppColors.success;
    final sign    = isDebit ? '- ' : '+ ';
    final date    = DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt.toLocal());
    final counterpartName = tx.counterpart?['full_name'] ?? tx.counterpart?['email'] ?? '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(_typeIcon(tx.type), color: color, size: 22),
            ),
            title: Text(
              tx.typeLabel,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (counterpartName != '—')
                  Text(counterpartName,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                Text(date,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            trailing: Text(
              '$sign${tx.amountFormatted}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // ─── Badge Algorand ──────────────────────────────────────────────────
          if (tx.hasBlockchain)
            InkWell(
              onTap: _openAlgorand,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4AB).withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined,
                        size: 14, color: Color(0xFF00B4AB)),
                    const SizedBox(width: 6),
                    const Text(
                      'Vérifié sur Algorand · ',
                      style: TextStyle(
                          color: Color(0xFF00B4AB),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        tx.blockchainTxId ?? '',
                        style: const TextStyle(
                            color: Color(0xFF00B4AB),
                            fontSize: 11,
                            fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new,
                        size: 12, color: Color(0xFF00B4AB)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'transfer':   return Icons.send_rounded;
      case 'recharge':   return Icons.add_card;
      case 'qr_send':    return Icons.qr_code;
      case 'qr_receive': return Icons.qr_code_scanner;
      default:           return Icons.swap_horiz;
    }
  }
}

