import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/watchlist_store.dart';
import 'market_search_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  bool _loading = true;
  List<String> _ids = const [];
  Map<String, dynamic> _market = const {}; // coin_id -> {price_usd, change_24h_pct}

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final ids = (await WatchlistStore.loadIds()).map((e) => e.toLowerCase()).toList();
      ids.sort();
      Map<String, dynamic> market = {};
      if (ids.isNotEmpty) {
        final data = await api.pricesMarketMany(ids);
        market = (data["market"] as Map<String, dynamic>? ?? {});
      }
      if (!mounted) return;
      setState(() {
        _ids = ids;
        _market = market;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur watchlist: $e"), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addCoin() async {
    final picked = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const MarketSearchScreen()),
    );
    final id = (picked ?? "").trim().toLowerCase();
    if (id.isEmpty) return;
    await WatchlistStore.addId(id);
    await _refresh();
  }

  Future<void> _removeCoin(String id) async {
    await WatchlistStore.removeId(id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Watchlist"),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded)),
          IconButton(onPressed: _addCoin, icon: const Icon(Icons.add_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_ids.isEmpty
              ? Center(
                  child: Text(
                    "Aucun favori.\nAjoute des coins avec +",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w700),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                  itemCount: _ids.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final id = _ids[i];
                    final row = (_market[id] as Map<String, dynamic>? ?? {});
                    final price = (row["price_usd"] as num?)?.toDouble();
                    final ch = (row["change_24h_pct"] as num?)?.toDouble();

                    final up = (ch ?? 0) >= 0;
                    final chTxt = ch == null ? "—" : "${up ? "+" : ""}${ch.toStringAsFixed(2)}%";

                    return Container(
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
                                Text(id.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  price == null ? "Prix: —" : "Prix: \$${price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.72),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: up ? cs.primaryContainer : cs.errorContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              chTxt,
                              style: TextStyle(
                                color: up ? cs.onPrimaryContainer : cs.onErrorContainer,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Retirer",
                            onPressed: () => _removeCoin(id),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                )),
    );
  }
}
