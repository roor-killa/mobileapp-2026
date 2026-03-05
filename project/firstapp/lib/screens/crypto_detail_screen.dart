import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/design_system.dart';
import '../models/models.dart';
import '../services/bank_service.dart';

/// Détail d'une crypto : graphique, prix, quantité, bouton Acheter.
class CryptoDetailScreen extends StatefulWidget {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final List<Account> accounts;
  final int? selectedAccountId;

  const CryptoDetailScreen({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    this.accounts = const [],
    this.selectedAccountId,
  });

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  int _quantity = 1;
  bool _loading = false;
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.selectedAccountId;
    if (_selectedAccountId == null && widget.accounts.isNotEmpty) {
      _selectedAccountId = widget.accounts.first.id;
    }
  }

  List<double> get _chartData {
    final rand = math.Random(symbolToSeed(widget.symbol));
    final points = <double>[];
    double y = 100.0;
    final trend = widget.changePercent / 100;
    for (var i = 0; i < 30; i++) {
      y = y + trend * 2 + (rand.nextDouble() - 0.5) * 4;
      points.add(y.clamp(80.0, 120.0));
    }
    final last = points.last;
    final scale = widget.price / (last / 100);
    return points.map((v) => v * scale / 100).toList();
  }

  int symbolToSeed(String s) => s.codeUnits.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final data = _chartData;
    final total = widget.price * _quantity;
    final isPositive = widget.changePercent >= 0;

    return Scaffold(
      backgroundColor: DesignSystem.gray50,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.currency_bitcoin_rounded, color: DesignSystem.orange600, size: 22),
            const SizedBox(width: 8),
            Text(widget.symbol),
          ],
        ),
        backgroundColor: DesignSystem.gray50,
        foregroundColor: DesignSystem.gray900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.name, style: const TextStyle(fontSize: 14, color: DesignSystem.gray500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  widget.price >= 1000 ? '${widget.price.toStringAsFixed(0)} €' : '${widget.price.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: DesignSystem.gray900),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? DesignSystem.green50 : DesignSystem.red50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${widget.changePercent.toStringAsFixed(2)} %',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isPositive ? DesignSystem.green700 : DesignSystem.red500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.white,
                borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _CryptoLineChartPainter(
                  data: data,
                  lineColor: isPositive ? DesignSystem.green500 : DesignSystem.red500,
                  fillColor: (isPositive ? DesignSystem.green500 : DesignSystem.red500).withValues(alpha: 0.1),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesignSystem.white,
                borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quantité', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesignSystem.gray700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _quantityButton(Icons.remove_rounded, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('$_quantity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: DesignSystem.gray900)),
                      ),
                      _quantityButton(Icons.add_rounded, () => setState(() => _quantity++)),
                    ],
                  ),
                  if (widget.accounts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Débiter le compte', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesignSystem.gray700)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedAccountId ?? widget.accounts.first.id,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: DesignSystem.gray50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: widget.accounts.map((a) => DropdownMenuItem<int>(
                        value: a.id,
                        child: Text('${a.accountType} •••• ${a.accountNumber.length >= 4 ? a.accountNumber.substring(a.accountNumber.length - 4) : a.accountNumber}'),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedAccountId = v),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 14, color: DesignSystem.gray600)),
                      Text(
                        '${total.toStringAsFixed(2)} €',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DesignSystem.orange600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: (_loading || widget.accounts.isEmpty) ? null : _buy,
                      style: FilledButton.styleFrom(
                        backgroundColor: DesignSystem.orange600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Acheter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: DesignSystem.gray100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: DesignSystem.gray700)),
      ),
    );
  }

  Future<void> _buy() async {
    final accountId = _selectedAccountId ?? widget.accounts.first.id;
    final total = widget.price * _quantity;
    Account? selectedAccount;
    for (final a in widget.accounts) {
      if (a.id == accountId) {
        selectedAccount = a;
        break;
      }
    }
    if (selectedAccount != null && selectedAccount.balance < total) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solde insuffisant. Disponible : ${selectedAccount.balance.toStringAsFixed(2)} € — Requis : ${total.toStringAsFixed(2)} €'),
          backgroundColor: DesignSystem.red500,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await BankService().debitAccount(
        accountId,
        total,
        description: 'Achat Crypto: $_quantity × ${widget.symbol}',
      );
      final prefs = await SharedPreferences.getInstance();
      final key = 'crypto_portfolio_$accountId';
      final raw = prefs.getString(key);
      List<Map<String, dynamic>> positions = [];
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>?;
        if (list != null) positions = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      final existing = positions.indexWhere((p) => p['symbol'] == widget.symbol);
      final q = _quantity;
      final totalCost = widget.price * q;
      if (existing >= 0) {
        positions[existing]['quantity'] = (positions[existing]['quantity'] as int) + q;
        positions[existing]['totalSpent'] = (positions[existing]['totalSpent'] as num) + totalCost;
      } else {
        positions.add({
          'symbol': widget.symbol,
          'name': widget.name,
          'quantity': q,
          'priceAtBuy': widget.price,
          'totalSpent': totalCost,
          'date': DateTime.now().toIso8601String(),
        });
      }
      await prefs.setString(key, jsonEncode(positions));
      final txKey = 'crypto_transactions_$accountId';
      final txRaw = prefs.getString(txKey);
      List<Map<String, dynamic>> txList = [];
      if (txRaw != null) {
        final decoded = jsonDecode(txRaw) as List<dynamic>?;
        if (decoded != null) txList = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      txList.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': DateTime.now().toIso8601String(),
        'symbol': widget.symbol,
        'name': widget.name,
        'quantity': q,
        'total': totalCost,
        'accountId': accountId,
        'type': 'crypto',
      });
      await prefs.setString(txKey, jsonEncode(txList));
      if (!mounted) return;
      setState(() => _loading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Achat effectué : $q × ${widget.symbol} = ${totalCost.toStringAsFixed(2)} €'),
          backgroundColor: DesignSystem.green600,
        ),
      );
      nav.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: DesignSystem.red500,
        ),
      );
    }
  }
}

class _CryptoLineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  _CryptoLineChartPainter({required this.data, required this.lineColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).clamp(1.0, double.infinity);
    final stepX = data.length > 1 ? (size.width - 32) / (data.length - 1) : 0.0;
    final padding = 16.0;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final y = size.height - padding - ((data[i] - minY) / range) * (size.height - 2 * padding);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(padding + (data.length - 1) * stepX, size.height - padding);
    fillPath.close();

    final fillPaint = Paint()..color = fillColor..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
