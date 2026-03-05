import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/wallet_provider.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final _amount = TextEditingController();
  int _fromIndex = 0;
  int _toIndex = 1;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Échanger')),
      body: Consumer<WalletProvider>(
        builder: (context, wp, _) {
          if (wp.wallets.length < 2) {
            return const Center(child: Text('Il faut au moins 2 wallets', style: TextStyle(color: AppTheme.textSecondary)));
          }
          final from = wp.wallets[_fromIndex];
          final to = wp.wallets[_toIndex % wp.wallets.length];
          final fromPrice = wp.prices[from.symbol] ?? 1;
          final toPrice = wp.prices[to.symbol] ?? 1;
          final amt = double.tryParse(_amount.text) ?? 0;
          final converted = toPrice > 0 ? (amt * fromPrice / toPrice) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SwapCard(
                  label: 'De',
                  wallet: from,
                  wallets: wp.wallets,
                  selectedIndex: _fromIndex,
                  onChanged: (i) => setState(() { _fromIndex = i; if (_toIndex == i) _toIndex = (i + 1) % wp.wallets.length; }),
                  amount: _amount,
                  editable: true,
                  onAmountChanged: () => setState(() {}),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() { final tmp = _fromIndex; _fromIndex = _toIndex; _toIndex = tmp; }),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.swap_vert_rounded, color: AppTheme.primary, size: 28),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vers', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 8),
                      _CryptoSelector(
                        wallets: wp.wallets,
                        selectedIndex: _toIndex,
                        onChanged: (i) => setState(() => _toIndex = i),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${converted.toStringAsFixed(6)} ${to.symbol}',
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Taux', style: TextStyle(color: AppTheme.textSecondary)),
                      Text(
                        '1 ${from.symbol} = ${(fromPrice / toPrice).toStringAsFixed(6)} ${to.symbol}',
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amt = double.tryParse(_amount.text) ?? 0;
                      if (amt <= 0) return;
                      wp.swapCrypto(_fromIndex, _toIndex, amt);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${amt.toStringAsFixed(4)} ${from.symbol} → ${converted.toStringAsFixed(4)} ${to.symbol}'), backgroundColor: AppTheme.primary),
                      );
                      _amount.clear();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                    child: const Text('Échanger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SwapCard extends StatelessWidget {
  final String label;
  final Wallet wallet;
  final List<Wallet> wallets;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final TextEditingController amount;
  final bool editable;
  final VoidCallback onAmountChanged;
  const _SwapCard({required this.label, required this.wallet, required this.wallets, required this.selectedIndex, required this.onChanged, required this.amount, required this.editable, required this.onAmountChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          _CryptoSelector(wallets: wallets, selectedIndex: selectedIndex, onChanged: onChanged),
          const SizedBox(height: 8),
          Text('Solde: ${wallet.balance.toStringAsFixed(4)} ${wallet.symbol}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onAmountChanged(),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              suffix: Text(wallet.symbol, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CryptoSelector extends StatelessWidget {
  final List<Wallet> wallets;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _CryptoSelector({required this.wallets, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: wallets.asMap().entries.map((e) {
          final selected = e.key == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value.symbol),
              selected: selected,
              onSelected: (_) => onChanged(e.key),
              selectedColor: AppTheme.primary.withOpacity(0.2),
              backgroundColor: AppTheme.background,
              labelStyle: TextStyle(color: selected ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.w600),
              side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
            ),
          );
        }).toList(),
      ),
    );
  }
}
