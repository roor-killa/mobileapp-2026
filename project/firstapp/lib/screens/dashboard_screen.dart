import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/bank_service.dart';
import 'transfer_screen.dart';
import 'login_screen.dart';
import 'transactions_screen.dart';
import 'profile_screen.dart';
import 'cards_screen.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
import 'request_money_screen.dart';
import 'trading_screen.dart';
import 'chat_screen.dart';
import '../theme/design_system.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BankService _bankService = BankService();
  List<Account>? _accounts;
  List<Transaction>? _transactions;
  List<Map<String, dynamic>> _stockTransactions = [];
  String? _errorMessage;
  String? _userName;
  final String _transactionFilter = 'all';
  bool _balanceVisible = true; // affichage du solde (design uniquement)
  int _navIndex = 0; // onglet actif (0 = Accueil)

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await _bankService.init();
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('user_data');
      if (userRaw != null) {
        try {
          final user = (jsonDecode(userRaw) as Map<String, dynamic>);
          _userName = (user['full_name'] ?? user['name'] ?? '').toString().trim();
        } catch (_) {
          // ignore
        }
      }

      final accounts = await _bankService.getAccounts();
      final transactions = await _bankService.getTransactions();
      List<Map<String, dynamic>> stockTx = [];
      for (final acc in accounts) {
        final raw = prefs.getString('stock_transactions_${acc.id}');
        if (raw != null) {
          try {
            final decoded = jsonDecode(raw) as List<dynamic>?;
            if (decoded != null) {
              for (final e in decoded) {
                final m = Map<String, dynamic>.from(e as Map);
                if (!m.containsKey('accountId')) m['accountId'] = acc.id;
                stockTx.add(m);
              }
            }
          } catch (_) {}
        }
      }
      // Migration: anciennes données sans compte → premier compte
      if (stockTx.isEmpty && accounts.isNotEmpty) {
        final legacyRaw = prefs.getString('stock_transactions');
        if (legacyRaw != null) {
          try {
            final decoded = jsonDecode(legacyRaw) as List<dynamic>?;
            if (decoded != null && decoded.isNotEmpty) {
              final firstId = accounts.first.id;
              final migrated = <Map<String, dynamic>>[];
              for (final e in decoded) {
                final m = Map<String, dynamic>.from(e as Map);
                m['accountId'] = firstId;
                migrated.add(m);
                stockTx.add(m);
              }
              await prefs.setString('stock_transactions_$firstId', jsonEncode(migrated));
              await prefs.remove('stock_transactions');
            }
          } catch (_) {}
        }
      }
      setState(() {
        _accounts = accounts;
        _transactions = transactions;
        _stockTransactions = stockTx;
        _errorMessage = null;
      });
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.toLowerCase().contains('session expirée')) {
        await _logout();
        return;
      }
      setState(() => _errorMessage = msg);
    }
  }

  Future<void> _logout() async {
    await _bankService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
          backgroundColor: DesignSystem.white,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Message d'erreur
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: DesignSystem.red50,
                          borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                          border: Border.all(color: DesignSystem.red500.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 20, color: scheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: scheme.error, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Header — Figma: flex items-center justify-between mb-6
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: DesignSystem.indigo200,
                          child: Text(
                            (_userName?.isNotEmpty ?? false)
                                ? _userName!.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DesignSystem.indigo600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bonjour,',
                                style: TextStyle(fontSize: 12, color: DesignSystem.gray400),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userName?.isEmpty ?? true ? 'Utilisateur' : _userName!,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesignSystem.gray900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              color: DesignSystem.gray100,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.notifications_outlined, size: 18, color: DesignSystem.gray600),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: DesignSystem.red500, shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Balance Card — Figma: rounded-3xl p-6, minHeight 180px
                    _buildBalanceCard(),
                    const SizedBox(height: 24),

                    // Quick Actions — Figma: grid 4 cols, w-14 h-14 rounded-2xl
                    _buildQuickActions(),
                    const SizedBox(height: 24),

                    // Stats — Figma: grid 2 cols, rounded-2xl p-4
                    _buildStatsRow(),
                    const SizedBox(height: 24),

                    // Recent Transactions — Figma: titre + See all + space-y-3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transactions récentes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DesignSystem.gray900),
                        ),
                        GestureDetector(
                          onTap: (_accounts == null && _stockTransactions.isEmpty)
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TransactionsScreen(
                                        accounts: _accounts ?? const [],
                                        transactions: _transactions ?? const [],
                                        stockTransactions: _stockTransactions,
                                        initialFilter: _transactionFilter,
                                      ),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.indigo600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_transactions == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_transactions!.isEmpty && _stockTransactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Aucune transaction',
                          style: TextStyle(fontSize: 14, color: DesignSystem.gray500),
                        ),
                      )
                    else
                      ..._buildRecentTransactionsList(),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            },
            backgroundColor: DesignSystem.indigo600,
            child: const Icon(Icons.chat_rounded, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.white,
        border: Border(top: BorderSide(color: DesignSystem.gray200)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Accueil'),
              _buildNavItem(1, Icons.swap_horiz, Icons.swap_horiz, 'Virement'),
              _buildNavItem(2, Icons.credit_card_outlined, Icons.credit_card_rounded, 'Cartes'),
              _buildNavItem(3, Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded, 'Analytiques'),
              _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData iconSelected, String label) {
    final isActive = _navIndex == index;
    return InkWell(
      onTap: () {
        if (index == 0) return;
        setState(() => _navIndex = index);
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TransferScreen(accounts: _accounts ?? [], onTransferSuccess: _loadData))).then((_) => setState(() => _navIndex = 0));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CardsScreen(accounts: _accounts ?? [], transactions: _transactions ?? []))).then((_) => setState(() => _navIndex = 0));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(transactions: _transactions ?? [], accounts: _accounts ?? []))).then((_) => setState(() => _navIndex = 0));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) => setState(() => _navIndex = 0));
        }
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? DesignSystem.indigo600 : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              ),
              child: Icon(isActive ? iconSelected : icon, size: 20, color: isActive ? Colors.white : DesignSystem.gray400),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isActive ? DesignSystem.indigo600 : DesignSystem.gray400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final total = _accounts?.fold<double>(0, (sum, acc) => sum + acc.balance);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(DesignSystem.space24),
      decoration: BoxDecoration(
        gradient: DesignSystem.cardGradient,
        borderRadius: BorderRadius.circular(DesignSystem.radius2xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: -40, right: -40, child: _buildDecoCircle(80)),
          Positioned(bottom: -32, left: -32, child: _buildDecoCircle(64)),
          Positioned(top: 16, right: 16, child: _buildDecoCircle(40)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(color: DesignSystem.indigo200, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _balanceVisible && total != null
                                    ? '${total.toStringAsFixed(2)} €'
                                    : '••••••••',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _balanceVisible = !_balanceVisible),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              icon: Icon(
                                _balanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                size: 18,
                                color: DesignSystem.indigo200,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, size: 12, color: DesignSystem.green300),
                        const SizedBox(width: 4),
                        Text('+2.4%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesignSystem.green300)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Card Number', style: TextStyle(color: DesignSystem.indigo200, fontSize: 11)),
                      const Text(
                        '•••• •••• •••• 4291',
                        style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Expires', style: TextStyle(color: DesignSystem.indigo200, fontSize: 11)),
                      Text('09/28', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecoCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickAction('Envoyer', Icons.send_rounded, DesignSystem.indigo50, DesignSystem.indigo600, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransferScreen(
                accounts: _accounts ?? [],
                onTransferSuccess: _loadData,
              ),
            ),
          );
        }),
        _buildQuickAction('Recevoir', Icons.download_rounded, DesignSystem.purple50, DesignSystem.purple500, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestMoneyScreen()));
        }),
        _buildQuickAction('Recharger', Icons.add_rounded, DesignSystem.green50, DesignSystem.green600, () {}),
        _buildQuickAction('Bourse', Icons.show_chart_rounded, DesignSystem.orange50, DesignSystem.orange600, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TradingScreen(accounts: _accounts ?? [])));
        }),
      ],
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: DesignSystem.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final ids = (_accounts ?? <Account>[]).map((a) => a.id).toSet();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    double income = 0;
    double expense = 0;
    for (final t in _transactions ?? <Transaction>[]) {
      if (t.transactionDate.isBefore(startOfMonth)) continue;
      final isIncoming = t.toAccountId != null && ids.contains(t.toAccountId) && !ids.contains(t.fromAccountId);
      final isOutgoing = ids.contains(t.fromAccountId) && (t.toAccountId == null || !ids.contains(t.toAccountId));
      if (isIncoming) income += t.amount;
      if (isOutgoing) expense += t.amount;
    }
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            decoration: BoxDecoration(
              color: DesignSystem.green50,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: DesignSystem.green500, shape: BoxShape.circle),
                      child: const Icon(Icons.download_rounded, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('Revenus', style: TextStyle(fontSize: 12, color: DesignSystem.green700)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${income.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DesignSystem.gray900),
                ),
                const Text('Ce mois', style: TextStyle(fontSize: 11, color: DesignSystem.green600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            decoration: BoxDecoration(
              color: DesignSystem.red50,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: DesignSystem.red500, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('Dépenses', style: TextStyle(fontSize: 12, color: DesignSystem.red500)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${expense.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DesignSystem.gray900),
                ),
                const Text('Ce mois', style: TextStyle(fontSize: 11, color: DesignSystem.red500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRecentTransactionsList() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final List<(DateTime, bool, dynamic)> combined = [];
    for (final t in _filteredTransactions(_transactions ?? [])) {
      combined.add((t.transactionDate, false, t));
    }
    for (final s in _stockTransactions) {
      try {
        final date = DateTime.parse(s['date'] as String);
        combined.add((date, true, s));
      } catch (_) {}
    }
    combined.sort((a, b) => b.$1.compareTo(a.$1));
    final take = combined.take(5).toList();
    return take.map<Widget>((e) {
      if (e.$2) return _buildStockTransactionTile(e.$3 as Map<String, dynamic>, dateFormat);
      return _buildTransactionTile(e.$3 as Transaction);
    }).toList();
  }

  Widget _buildStockTransactionTile(Map<String, dynamic> s, DateFormat dateFormat) {
    final total = (s['total'] as num?)?.toDouble() ?? 0.0;
    final quantity = s['quantity'] as int? ?? 0;
    final symbol = s['symbol'] as String? ?? '';
    final name = s['name'] as String? ?? '';
    final accountId = s['accountId'] as int?;
    String accountLabel = '';
    if (accountId != null && _accounts != null) {
      for (final a in _accounts!) {
        if (a.id == accountId) {
          accountLabel = a.accountType;
          break;
        }
      }
    }
    String dateStr = '';
    try {
      dateStr = dateFormat.format(DateTime.parse(s['date'] as String));
    } catch (_) {}
    final subtitle = [if (accountLabel.isNotEmpty) accountLabel, name, dateStr].where((e) => e.isNotEmpty).join(' • ');
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DesignSystem.orange50,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: const Icon(Icons.show_chart_rounded, color: DesignSystem.orange600, size: 22),
          ),
          const SizedBox(width: DesignSystem.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achat Bourse: $quantity × $symbol',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DesignSystem.gray900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: DesignSystem.gray400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignSystem.space8),
          Text(
            '−${total.toStringAsFixed(2)} €',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DesignSystem.gray700),
          ),
        ],
      ),
    );
  }

  List<Transaction> _filteredTransactions(List<Transaction> list) {
    final ids = (_accounts ?? const <Account>[]).map((a) => a.id).toSet();
    return list.where((t) {
      final isOutgoing = ids.contains(t.fromAccountId) && (t.toAccountId == null || !ids.contains(t.toAccountId));
      final isIncoming = t.toAccountId != null && ids.contains(t.toAccountId) && !ids.contains(t.fromAccountId);
      final isInternal = t.toAccountId != null && ids.contains(t.fromAccountId) && ids.contains(t.toAccountId);
      switch (_transactionFilter) {
        case 'incoming': return isIncoming;
        case 'outgoing': return isOutgoing;
        case 'internal': return isInternal;
        default: return true;
      }
    }).toList();
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final ids = (_accounts ?? const <Account>[]).map((a) => a.id).toSet();
    final isOutgoing = ids.contains(transaction.fromAccountId) &&
        (transaction.toAccountId == null || !ids.contains(transaction.toAccountId));
    final isIncoming = transaction.toAccountId != null &&
        ids.contains(transaction.toAccountId) &&
        !ids.contains(transaction.fromAccountId);
    final isInternal = transaction.toAccountId != null &&
        ids.contains(transaction.toAccountId) &&
        ids.contains(transaction.fromAccountId);

    final icon = isInternal
        ? Icons.sync_alt_rounded
        : (isOutgoing ? Icons.call_made_rounded : (isIncoming ? Icons.call_received_rounded : Icons.receipt_long_rounded));
    final color = isInternal ? DesignSystem.indigo600 : (isOutgoing ? DesignSystem.gray700 : (isIncoming ? DesignSystem.green500 : DesignSystem.gray500));
    final sign = isInternal ? '' : (isOutgoing ? '−' : (isIncoming ? '+' : ''));

    final counterparty = isIncoming
        ? (transaction.fromOwnerName ?? 'Compte externe')
        : (isOutgoing ? (transaction.toOwnerName ?? 'Bénéficiaire') : null);
    final subtitle = [
      dateFormat.format(transaction.transactionDate),
      if (counterparty != null) (isIncoming ? 'De $counterparty' : 'À $counterparty'),
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: DesignSystem.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DesignSystem.gray900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: DesignSystem.gray400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignSystem.space8),
          Text(
            '$sign${transaction.amount.toStringAsFixed(2)} €',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
