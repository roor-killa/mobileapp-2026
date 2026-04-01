import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/tx.dart';
import 'buy_screen.dart';
import 'transfer_screen.dart';
import 'receive_qr_screen.dart';
import 'history_screen.dart';
import 'chat_screen.dart';
import 'crypto_transfer_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final api = SupabaseService();
  double _balance = 0;
  bool _loading = true;
  List<Tx> _tx = const [];
  bool _loadingTx = true;

  /// Called by AppShell whenever this tab becomes visible after a push/pop.
  void reload() => _load();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _syncTransactionNotifications(List<Tx> tx) async {
    final seen = await NotificationService.instance.getSeenTxIds();
    if (seen.isEmpty) {
      await NotificationService.instance.setSeenTxIds(tx.map((e) => e.id.toString()).toSet());
      return;
    }
    final updatedSeen = Set<String>.from(seen);
    for (final item in tx) {
      final key = item.id.toString();
      if (updatedSeen.contains(key)) continue;
      updatedSeen.add(key);
      if (item.type == 'TRANSFER_IN' && item.status == 'OK') {
        await NotificationService.instance.add(
          title: 'Fonds reçus',
          message: '+${item.amountBkn.toStringAsFixed(2)} BKN crédités sur votre portefeuille.',
          type: 'incoming',
          meta: {'txId': item.id, 'kind': item.type},
        );
      } else if (item.type == 'BUY' && item.status == 'OK') {
        await NotificationService.instance.add(
          title: 'Achat confirmé',
          message: '${item.amountBkn.toStringAsFixed(2)} BKN ont été ajoutés à votre solde.',
          type: 'success',
          meta: {'txId': item.id, 'kind': item.type},
        );
      }
    }
    await NotificationService.instance.setSeenTxIds(updatedSeen);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final b = await api.getBalance();
      final tx = await api.getTransactions();
      await _syncTransactionNotifications(tx);
      setState(() {
        _balance = b;
        _tx = tx;
        _loadingTx = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur solde: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'chat_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/branding/uapay_logo.png', width: 28, height: 28),
                  ),
                  const SizedBox(width: 10),
                  const Text('UApay'),
                ],
              ),
              actions: [
                ValueListenableBuilder<int>(
                  valueListenable: NotificationService.instance.unreadCount,
                  builder: (context, unread, _) => IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text(unread > 99 ? '99+' : '$unread'),
                      child: const Icon(Icons.notifications_none),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Rafraîchir',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Aide',
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _FadeSlide(
                    delayMs: 0,
                    child: _BalanceHeader(
                      loading: _loading,
                      balance: _balance,
                      eurApprox: _balance * 1.0,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FadeSlide(
                    delayMs: 90,
                    child: _SectionTitleRow(
                      title: 'Actions',
                      trailing: Text('Rapide', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FadeSlide(
                    delayMs: 140,
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.2,
                      ),
                      children: [
                        _ActionChip(
                          icon: Icons.send,
                          label: 'Envoyer',
                          subtitle: 'Transfert',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen())),
                        ),
                        _ActionChip(
                          icon: Icons.qr_code_scanner,
                          label: 'Recevoir',
                          subtitle: 'QR',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiveQrScreen())),
                        ),
                        _ActionChip(
                          icon: Icons.add_card,
                          label: 'Acheter',
                          subtitle: 'BKN',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyScreen())),
                        ),
                        _ActionChip(
                          icon: Icons.currency_bitcoin,
                          label: 'Crypto',
                          subtitle: 'On-chain',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CryptoTransferScreen())),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  _FadeSlide(
                    delayMs: 200,
                    child: _SectionTitleRow(
                      title: 'Transactions',
                      trailing: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                        child: const Text('Tout voir'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FadeSlide(
                    delayMs: 240,
                    child: _TxPreviewCard(
                      loading: _loadingTx,
                      items: _tx.take(5).toList(growable: false),
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/* ---------------- Premium UI Widgets (Home) ---------------- */

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.loading, required this.balance, required this.eurApprox});

  final bool loading;
  final double balance;
  final double eurApprox;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.20),
            cs.secondary.withOpacity(0.10),
          ],
        ),
        border: Border.all(color: const Color(0xFF1C2B45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: const Text('1 BKN = 1€', style: TextStyle(color: Colors.white70)),
                ),
                const Spacer(),
                if (loading)
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 14),
            Text('Solde', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('BKN', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('≈ ${eurApprox.toStringAsFixed(2)} €', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                const Spacer(),
                Text('Mis à jour: maintenant', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({required this.title, required this.trailing});
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const Spacer(),
        trailing,
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF111C2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1C2B45)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withOpacity(0.14),
                  border: Border.all(color: cs.primary.withOpacity(0.22)),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxPreviewCard extends StatelessWidget {
  const _TxPreviewCard({required this.loading, required this.items});

  final bool loading;
  final List<Tx> items;

  IconData _iconFor(String type) {
    switch (type) {
      case 'BUY':
        return Icons.add_circle_outline;
      case 'SELL':
        return Icons.remove_circle_outline;
      case 'TRANSFER_IN':
        return Icons.call_received;
      case 'TRANSFER_OUT':
        return Icons.call_made;
      default:
        return Icons.swap_horiz;
    }
  }

  String _labelFor(String type) {
    switch (type) {
      case 'BUY':
        return 'Achat';
      case 'SELL':
        return 'Vente';
      case 'TRANSFER_IN':
        return 'Reçu';
      case 'TRANSFER_OUT':
        return 'Envoyé';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: loading
            ? const SizedBox(
                height: 92,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : items.isEmpty
                ? const SizedBox(
                    height: 92,
                    child: Center(
                      child: Text('Aucune transaction pour le moment', style: TextStyle(color: Colors.white70)),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        _TxRow(
                          icon: _iconFor(items[i].type),
                          label: _labelFor(items[i].type),
                          amount: items[i].amountBkn,
                          ok: items[i].status != 'NOK',
                          date: items[i].createdAt,
                          accent: cs.primary,
                          isOutgoing: items[i].isDebit,
                        ),
                        if (i != items.length - 1)
                          Divider(height: 18, color: Colors.white.withOpacity(0.08)),
                      ]
                    ],
                  ),
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.ok,
    required this.date,
    required this.accent,
    required this.isOutgoing,
  });

  final IconData icon;
  final String label;
  final double amount;
  final bool ok;
  final String date;
  final Color accent;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    final statusColor = ok ? Colors.greenAccent : Colors.orangeAccent;
    final amountColor = !ok
        ? Colors.orangeAccent
        : isOutgoing
            ? Colors.redAccent.shade100
            : Colors.greenAccent.shade100;
    final amountPrefix = isOutgoing ? '-' : '+';
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(0.14),
            border: Border.all(color: accent.withOpacity(0.22)),
          ),
          child: Icon(icon, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: statusColor.withOpacity(0.22)),
                    ),
                    child: Text(ok ? 'OK' : 'NOK', style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(date, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$amountPrefix${amount.toStringAsFixed(2)} BKN',
          style: TextStyle(fontWeight: FontWeight.w800, color: amountColor),
        ),
      ],
    );
  }
}

class _FadeSlide extends StatefulWidget {
  const _FadeSlide({required this.child, this.delayMs = 0});
  final Widget child;
  final int delayMs;

  @override
  State<_FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<_FadeSlide> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
