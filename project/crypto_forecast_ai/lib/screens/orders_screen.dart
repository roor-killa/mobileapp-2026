import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api.dart';
import 'market_search_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  List<dynamic> _orders = const [];

  // form
  final _coinCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _triggerCtrl = TextEditingController();

  String _side = "BUY";
  String _type = "LIMIT";

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _coinCtrl.dispose();
    _qtyCtrl.dispose();
    _limitCtrl.dispose();
    _triggerCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final rows = await api.listOrders(status: "open");
      if (!mounted) return;
      setState(() => _orders = rows);
    } catch (e) {
      _snack("Erreur orders: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickCoin() async {
    final picked = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const MarketSearchScreen()),
    );
    final id = (picked ?? "").trim().toLowerCase();
    if (id.isEmpty) return;
    _coinCtrl.text = id;
  }

  Future<void> _create() async {
    final coinId = _coinCtrl.text.trim().toLowerCase();
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(",", ".")) ?? 0;
    final lp = double.tryParse(_limitCtrl.text.replaceAll(",", ".")) ;
    final tp = double.tryParse(_triggerCtrl.text.replaceAll(",", ".")) ;

    if (coinId.isEmpty) return _snack("coin_id requis.");
    if (qty <= 0) return _snack("qty invalide.");

    if (_type == "LIMIT" && (lp == null || lp <= 0)) return _snack("limit_price requis.");
    if ((_type == "STOP_LOSS" || _type == "TAKE_PROFIT") && (tp == null || tp <= 0)) return _snack("trigger_price requis.");

    try {
      await api.createOrder(
        coinId: coinId,
        side: _side,
        orderType: _type,
        qty: qty,
        limitPrice: _type == "LIMIT" ? lp : null,
        triggerPrice: (_type == "STOP_LOSS" || _type == "TAKE_PROFIT") ? tp : null,
      );
      _qtyCtrl.clear();
      _limitCtrl.clear();
      _triggerCtrl.clear();
      _snack("Order créé.");
      await _reload();
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _cancel(int id) async {
    try {
      await api.cancelOrder(id);
      _snack("Order annulé.");
      await _reload();
    } catch (e) {
      _snack(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ordres"),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.onSurface.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Créer un ordre", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _coinCtrl,
                        decoration: const InputDecoration(
                          labelText: "coin_id",
                          hintText: "bitcoin, ethereum...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: "Recherche",
                      onPressed: _pickCoin,
                      icon: const Icon(Icons.manage_search_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _side,
                        items: const [
                          DropdownMenuItem(value: "BUY", child: Text("BUY")),
                          DropdownMenuItem(value: "SELL", child: Text("SELL")),
                        ],
                        onChanged: (v) => setState(() => _side = v ?? "BUY"),
                        decoration: const InputDecoration(labelText: "Side", border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _type,
                        items: const [
                          DropdownMenuItem(value: "LIMIT", child: Text("LIMIT")),
                          DropdownMenuItem(value: "STOP_LOSS", child: Text("STOP_LOSS")),
                          DropdownMenuItem(value: "TAKE_PROFIT", child: Text("TAKE_PROFIT")),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? "LIMIT"),
                        decoration: const InputDecoration(labelText: "Type", border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Quantité (coin)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                if (_type == "LIMIT")
                  TextField(
                    controller: _limitCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Limit price (USD)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                if (_type == "STOP_LOSS" || _type == "TAKE_PROFIT")
                  TextField(
                    controller: _triggerCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Trigger price (USD)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _create,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text("Créer", style: TextStyle(fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: const [
              Expanded(child: Text("Ordres ouverts", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
            ],
          ),
          const SizedBox(height: 8),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()))
          else if (_orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Aucun ordre ouvert.",
                style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w700),
              ),
            )
          else
            ..._orders.map((o) {
              final id = (o["id"] as num?)?.toInt() ?? 0;
              final coin = (o["coin_id"] ?? "").toString();
              final side = (o["side"] ?? "").toString();
              final type = (o["order_type"] ?? "").toString();
              final qty = (o["qty"] as num?)?.toDouble();
              final lp = (o["limit_price"] as num?)?.toDouble();
              final tp = (o["trigger_price"] as num?)?.toDouble();

              String extra = "";
              if (type == "LIMIT" && lp != null) extra = " @ \$${lp.toStringAsFixed(2)}";
              if ((type == "STOP_LOSS" || type == "TAKE_PROFIT") && tp != null) extra = " trigger \$${tp.toStringAsFixed(2)}";

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("$coin • $side • $type",
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            "qty: ${qty?.toStringAsFixed(6) ?? "—"}$extra",
                            style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: "Annuler",
                      onPressed: id == 0 ? null : () => _cancel(id),
                      icon: const Icon(Icons.cancel_outlined),
                    )
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
