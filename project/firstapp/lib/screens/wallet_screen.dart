import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'transfer_screen.dart';
import 'topup_screen.dart';
import 'receive_screen.dart';
import 'scan_pay_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _apiService  = ApiService();
  final _authService = AuthService();
  Wallet? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading      = true;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final wallet       = await _apiService.getWallet();
      final transactions = await _apiService.getTransactions();
      setState(() {
        _wallet       = wallet;
        _transactions = transactions;
        _isLoading    = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildBalanceCard()),
                    SliverToBoxAdapter(child: _buildActionButtons()),
                    SliverToBoxAdapter(child: _buildTransactionHeader()),
                    if (_transactions.isEmpty)
                      const SliverFillRemaining(child: _EmptyState())
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildTransactionTile(_transactions[i]),
                          childCount: _transactions.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: kGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mon Portefeuille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Wallet BKN',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 22),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Solde disponible',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _balanceVisible
                    ? (_wallet?.balance.toStringAsFixed(2) ?? '0.00')
                    : '••••••',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 7, left: 8),
                child: Text(
                  'EUR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Colors.white60, size: 15),
              const SizedBox(width: 6),
              Text(
                '${_transactions.length} transaction${_transactions.length > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionBtn(
            icon: Icons.send_rounded,
            label: 'Envoyer',
            color: AppColors.primary,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferScreen()),
              );
              _loadData();
            },
          ),
          _actionBtn(
            icon: Icons.add_rounded,
            label: 'Recharger',
            color: AppColors.success,
            onTap: kIsWeb
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TopUpScreen()),
                    );
                    _loadData();
                  },
          ),
          _actionBtn(
            icon: Icons.qr_code_rounded,
            label: 'Recevoir',
            color: const Color(0xFFFF6B9D),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceiveScreen()),
            ),
          ),
          _actionBtn(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scanner',
            color: AppColors.warning,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanPayScreen()),
              );
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: disabled ? AppColors.surfaceLight : color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: disabled ? AppColors.border : color.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              color: disabled ? AppColors.textSecondary : color,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: disabled ? AppColors.textSecondary : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          const Text(
            'Transactions récentes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            '${_transactions.length}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d   = dt.toLocal();
    final now = DateTime.now();
    final hh  = d.hour.toString().padLeft(2, '0');
    final mm  = d.minute.toString().padLeft(2, '0');
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return "Aujourd'hui $hh:$mm";
    }
    final day   = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hh:$mm';
  }

  Widget _buildTransactionTile(Transaction t) {
    final isPositive = t.type == 'topup' || t.type == 'transfer_in';

    final icon = switch (t.type) {
      'topup'        => Icons.add_card_rounded,
      'transfer_out' => Icons.arrow_upward_rounded,
      'transfer_in'  => Icons.arrow_downward_rounded,
      _              => Icons.swap_horiz_rounded,
    };

    final iconColor = switch (t.type) {
      'topup' || 'transfer_in' => AppColors.success,
      'transfer_out'           => AppColors.danger,
      _                        => AppColors.textSecondary,
    };

    final label = switch (t.type) {
      'topup'        => 'Rechargement',
      'transfer_out' => 'Envoyé',
      'transfer_in'  => 'Reçu',
      _              => t.type,
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.relatedUserName ?? label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(t.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${t.amount.toStringAsFixed(2)} €',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isPositive ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Vos opérations apparaîtront ici',
            style: TextStyle(color: AppColors.border, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
