import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_system.dart';
import '../models/models.dart';
import 'stock_detail_screen.dart';

/// Écran Bourse : watchlist, portefeuille (mes positions + gains/pertes), indices.
/// Les positions et achats sont stockés par compte (un achat n'apparaît que sur le compte choisi).
class TradingScreen extends StatefulWidget {
  final List<Account> accounts;

  const TradingScreen({super.key, this.accounts = const []});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  int _tabIndex = 0; // 0 = Watchlist, 1 = Portefeuille, 2 = Indices
  List<Map<String, dynamic>> _positions = [];
  double _portfolioTotal = 0;
  double _portfolioGainPercent = 0;
  /// Compte dont on affiche le portefeuille boursier.
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) _selectedAccountId = widget.accounts.first.id;
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    if (_selectedAccountId == null) {
      if (!mounted) return;
      setState(() {
        _positions = [];
        _portfolioTotal = 0;
        _portfolioGainPercent = 0;
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    var raw = prefs.getString('stock_portfolio_$_selectedAccountId');
    if (raw == null && widget.accounts.isNotEmpty && widget.accounts.first.id == _selectedAccountId) {
      final legacy = prefs.getString('stock_portfolio');
      if (legacy != null) {
        await prefs.setString('stock_portfolio_$_selectedAccountId', legacy);
        await prefs.remove('stock_portfolio');
        raw = legacy;
      }
    }
    List<Map<String, dynamic>> positions = [];
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>?;
        if (list != null) positions = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
    }
    double total = 0;
    double spent = 0;
    for (final p in positions) {
      final q = (p['quantity'] as num?)?.toInt() ?? 0;
      final totalSpent = (p['totalSpent'] as num?)?.toDouble() ?? 0;
      final price = _priceForSymbol(p['symbol'] as String? ?? '');
      final value = q * price;
      total += value;
      spent += totalSpent;
    }
    double gainPercent = 0;
    if (spent > 0) gainPercent = ((total - spent) / spent) * 100;
    if (!mounted) return;
    setState(() {
      _positions = positions;
      _portfolioTotal = total;
      _portfolioGainPercent = gainPercent;
    });
  }

  double _priceForSymbol(String symbol) {
    for (final s in _watchlist) {
      if (s.symbol == symbol) return s.price;
    }
    return 0;
  }

  static const List<_StockItem> _watchlist = [
    _StockItem(symbol: 'AAPL', name: 'Apple Inc.', price: 178.42, changePercent: 1.24),
    _StockItem(symbol: 'MSFT', name: 'Microsoft', price: 378.91, changePercent: 0.85),
    _StockItem(symbol: 'GOOGL', name: 'Alphabet', price: 141.80, changePercent: -0.32),
    _StockItem(symbol: 'AMZN', name: 'Amazon', price: 178.25, changePercent: 2.10),
    _StockItem(symbol: 'TSLA', name: 'Tesla', price: 248.50, changePercent: -1.15),
    _StockItem(symbol: 'BTC-EUR', name: 'Bitcoin', price: 67234.00, changePercent: 3.42),
    _StockItem(symbol: 'ETH-EUR', name: 'Ethereum', price: 3456.20, changePercent: 2.08),
  ];

  static const List<_IndexItem> _indices = [
    _IndexItem(name: 'CAC 40', value: 7654.32, changePercent: 0.45),
    _IndexItem(name: 'S&P 500', value: 5234.18, changePercent: 0.62),
    _IndexItem(name: 'NASDAQ', value: 16234.56, changePercent: 0.28),
    _IndexItem(name: 'DAX', value: 17892.40, changePercent: -0.15),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.gray50,
      appBar: AppBar(
        title: const Text('Bourse'),
        backgroundColor: DesignSystem.gray50,
        foregroundColor: DesignSystem.gray900,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sélecteur de compte (portefeuille boursier par compte)
          if (widget.accounts.length > 1) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: DropdownButtonFormField<int>(
                initialValue: _selectedAccountId ?? widget.accounts.first.id,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: DesignSystem.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                items: widget.accounts.map((a) => DropdownMenuItem<int>(
                  value: a.id,
                  child: Text('${a.accountType} •••• ${a.accountNumber.length >= 4 ? a.accountNumber.substring(a.accountNumber.length - 4) : a.accountNumber}', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedAccountId = v);
                  _loadPortfolio();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Résumé virtuel
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: DesignSystem.cardGradient,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portefeuille', style: TextStyle(fontSize: 12, color: DesignSystem.indigo200)),
                const SizedBox(height: 4),
                Text(
                  '${_portfolioTotal.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _portfolioGainPercent >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 14,
                      color: _portfolioGainPercent >= 0 ? DesignSystem.green300 : DesignSystem.red500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_portfolioGainPercent >= 0 ? '+' : ''}${_portfolioGainPercent.toStringAsFixed(2)} %',
                      style: TextStyle(
                        fontSize: 12,
                        color: _portfolioGainPercent >= 0 ? DesignSystem.green300 : DesignSystem.red500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Onglets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _tab('Watchlist', 0),
                const SizedBox(width: 8),
                _tab('Portefeuille', 1),
                const SizedBox(width: 8),
                _tab('Indices', 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _tabIndex == 0
                ? _buildWatchlist()
                : _tabIndex == 1
                    ? _buildPortfolio()
                    : _buildIndices(),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: Material(
        color: isActive ? DesignSystem.indigo600 : DesignSystem.gray200,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
        child: InkWell(
          onTap: () => setState(() => _tabIndex = index),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : DesignSystem.gray600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlist() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _watchlist.length,
      itemBuilder: (context, index) {
        final s = _watchlist[index];
        final isPositive = s.changePercent >= 0;
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StockDetailScreen(
                  symbol: s.symbol,
                  name: s.name,
                  price: s.price,
                  changePercent: s.changePercent,
                  accounts: widget.accounts,
                  selectedAccountId: _selectedAccountId,
                ),
              ),
            ).then((_) => _loadPortfolio());
          },
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignSystem.white,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: DesignSystem.indigo50,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      s.symbol.substring(0, s.symbol.length >= 2 ? 2 : 1),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DesignSystem.indigo600),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.symbol, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesignSystem.gray900)),
                      const SizedBox(height: 2),
                      Text(s.name, style: const TextStyle(fontSize: 12, color: DesignSystem.gray500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      s.price >= 1000 ? '${s.price.toStringAsFixed(0)} €' : '${s.price.toStringAsFixed(2)} €',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesignSystem.gray900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isPositive ? '+' : ''}${s.changePercent.toStringAsFixed(2)} %',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isPositive ? DesignSystem.green600 : DesignSystem.red500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortfolio() {
    if (_positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 64, color: DesignSystem.gray400),
            const SizedBox(height: 16),
            Text(
              'Aucune position',
              style: TextStyle(fontSize: 16, color: DesignSystem.gray600),
            ),
            const SizedBox(height: 8),
            Text(
              'Achetez des actions depuis la Watchlist',
              style: TextStyle(fontSize: 13, color: DesignSystem.gray400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _positions.length,
      itemBuilder: (context, index) {
        final p = _positions[index];
        final symbol = p['symbol'] as String? ?? '';
        final name = p['name'] as String? ?? '';
        final quantity = (p['quantity'] as num?)?.toInt() ?? 0;
        final totalSpent = (p['totalSpent'] as num?)?.toDouble() ?? 0.0;
        final currentPrice = _priceForSymbol(symbol);
        final currentValue = quantity * currentPrice;
        final gain = currentValue - totalSpent;
        final gainPercent = totalSpent > 0 ? (gain / totalSpent) * 100 : 0.0;
        final isPositive = gain >= 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignSystem.white,
            borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: DesignSystem.indigo50,
                      borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        symbol.length >= 2 ? symbol.substring(0, 2) : symbol,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DesignSystem.indigo600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(symbol, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesignSystem.gray900)),
                        const SizedBox(height: 2),
                        Text(name, style: const TextStyle(fontSize: 12, color: DesignSystem.gray500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${currentValue.toStringAsFixed(2)} €',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesignSystem.gray900),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${gain.toStringAsFixed(2)} € (${isPositive ? '+' : ''}${gainPercent.toStringAsFixed(2)} %)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isPositive ? DesignSystem.green600 : DesignSystem.red500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$quantity part(s) • Prix actuel: ${currentPrice >= 1000 ? currentPrice.toStringAsFixed(0) : currentPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 11, color: DesignSystem.gray400)),
                  Text('Investi: ${totalSpent.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 11, color: DesignSystem.gray500)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndices() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _indices.length,
      itemBuilder: (context, index) {
        final s = _indices[index];
        final isPositive = s.changePercent >= 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignSystem.white,
            borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DesignSystem.purple50,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                ),
                child: const Icon(Icons.show_chart_rounded, color: DesignSystem.purple500, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesignSystem.gray900)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.value.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesignSystem.gray900),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${s.changePercent.toStringAsFixed(2)} %',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isPositive ? DesignSystem.green600 : DesignSystem.red500),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StockItem {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  const _StockItem({required this.symbol, required this.name, required this.price, required this.changePercent});
}

class _IndexItem {
  final String name;
  final double value;
  final double changePercent;
  const _IndexItem({required this.name, required this.value, required this.changePercent});
}
