import 'package:flutter/material.dart';

import '../models/tx.dart';
import '../services/cache_service.dart';
import '../services/supabase_service.dart';
import 'transaction_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final api = SupabaseService();
  final cache = CacheService();

  bool loading = true;
  List<Tx> txs = [];

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      txs = await api.getTransactions();
      await cache.saveTransactions(txs);
    } catch (e) {
      txs = await cache.loadTransactions();
      if (txs.isNotEmpty) _snack('Mode offline: historique en cache');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  IconData _iconFor(Tx t) {
    if (t.status != 'OK') return Icons.error_outline_rounded;
    switch (t.type) {
      case 'BUY':
        return Icons.shopping_bag_outlined;
      case 'SELL':
        return Icons.south_west_rounded;
      case 'TRANSFER_IN':
        return Icons.call_received_rounded;
      case 'TRANSFER_OUT':
        return Icons.call_made_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _amountColor(BuildContext context, Tx t) {
    if (t.status != 'OK') return Theme.of(context).colorScheme.error;
    return t.isDebit ? Colors.red.shade400 : Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : txs.isEmpty
              ? const Center(child: Text('Aucune transaction'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: txs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final t = txs[i];
                      return Material(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailsScreen(tx: t),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  child: Icon(_iconFor(t)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.displayType,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t.createdAt,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white54,
                                            ),
                                      ),
                                      if ((t.note ?? '').trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          t.note!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.white38,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      t.signedAmount,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: _amountColor(context, t),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          t.status,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: t.status == 'OK' ? Colors.green.shade700 : Theme.of(context).colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.chevron_right_rounded, size: 18),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
