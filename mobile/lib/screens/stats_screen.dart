import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/tx.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final api = SupabaseService();

  bool loading = true;
  String? error;

  int count = 0;
  double buyTotal = 0;
  double sellTotal = 0;
  double inTotal = 0;
  double outTotal = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final List<Tx> txs = await api.getTransactions();
      double b = 0, s = 0, tin = 0, tout = 0;

      for (final t in txs) {
        final type = t.type.toUpperCase();
        final amt = t.amountBkn;

        if (type == 'BUY') b += amt;
        if (type == 'SELL') s += amt;
        if (type == 'TRANSFER_IN') tin += amt;
        if (type == 'TRANSFER_OUT') tout += amt;
      }

      setState(() {
        count = txs.length;
        buyTotal = b;
        sellTotal = s;
        inTotal = tin;
        outTotal = tout;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques"),
        actions: [
          IconButton(
            onPressed: loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : (error != null)
                ? Center(child: Text("Erreur: $error"))
                : ListView(
                    children: [
                      _StatCard(title: "Transactions", value: "$count"),
                      const SizedBox(height: 10),
                      _StatCard(title: "Total acheté (BUY)", value: "${buyTotal.toStringAsFixed(2)} BKN"),
                      const SizedBox(height: 10),
                      _StatCard(title: "Total vendu (SELL)", value: "${sellTotal.toStringAsFixed(2)} BKN"),
                      const SizedBox(height: 10),
                      _StatCard(title: "Reçu (TRANSFER_IN)", value: "${inTotal.toStringAsFixed(2)} BKN"),
                      const SizedBox(height: 10),
                      _StatCard(title: "Envoyé (TRANSFER_OUT)", value: "${outTotal.toStringAsFixed(2)} BKN"),
                    ],
                  ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
