import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/watchlist_store.dart';

/// Saisie intelligente CoinGecko (via backend GET /search?query=...)
/// ✅ Retourne le coin_id (String) via Navigator.pop(coinId)
class MarketSearchScreen extends StatefulWidget {
  const MarketSearchScreen({super.key});

  @override
  State<MarketSearchScreen> createState() => _MarketSearchScreenState();
}

class _MarketSearchScreenState extends State<MarketSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  Timer? _debounce;

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _results = const [];

  // ✅ Favoris
  Set<String> _favIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFavs();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadFavs() async {
    final ids = await WatchlistStore.loadIds();
    if (!mounted) return;
    setState(() => _favIds = ids.map((e) => e.toLowerCase()).toSet());
  }

  Future<void> _toggleFav(String coinId) async {
    final id = coinId.trim().toLowerCase();
    if (id.isEmpty) return;

    if (_favIds.contains(id)) {
      await WatchlistStore.removeId(id);
      if (!mounted) return;
      setState(() => _favIds.remove(id));
    } else {
      await WatchlistStore.addId(id);
      if (!mounted) return;
      setState(() => _favIds.add(id));
    }
  }

  void _onChanged(String v) {
    final q = v.trim();
    _debounce?.cancel();

    if (q.length < 2) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _loading = true;
        _error = null;
      });

      try {
        final coins = await api.searchCoins(q);

        // Tri "intelligent": meilleur market_cap_rank d'abord (1,2,3...)
        coins.sort((a, b) {
          final ar = (a['market_cap_rank'] ?? 999999) as int;
          final br = (b['market_cap_rank'] ?? 999999) as int;
          return ar.compareTo(br);
        });

        if (!mounted) return;
        setState(() => _results = coins);
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = e.toString());
      } finally {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rechercher une crypto"),
        actions: [
          IconButton(
            tooltip: "Rafraîchir favoris",
            onPressed: _loadFavs,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              onChanged: _onChanged,
              decoration: InputDecoration(
                labelText: "Nom ou symbole (ex: bitcoin, eth)",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        tooltip: "Effacer",
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _results = []);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            if (_error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: TextStyle(color: cs.error, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text("Tape au moins 2 caractères…"))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final c = _results[i];
                        final id = (c['id'] ?? '').toString();
                        final name = (c['name'] ?? '').toString();
                        final symbol = (c['symbol'] ?? '').toString().toUpperCase();
                        final thumb = (c['thumb'] ?? '').toString();
                        final rank = c['market_cap_rank'];

                        final fav = _favIds.contains(id.toLowerCase());

                        return ListTile(
                          leading: thumb.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    thumb,
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin_rounded),
                                  ),
                                )
                              : const Icon(Icons.currency_bitcoin_rounded),
                          title: Text("$name ($symbol)"),
                          subtitle: Text("id: $id${rank != null ? " • rank: $rank" : ""}"),
                          trailing: IconButton(
                            tooltip: fav ? "Retirer des favoris" : "Ajouter aux favoris",
                            onPressed: () => _toggleFav(id),
                            icon: Icon(fav ? Icons.star_rounded : Icons.star_border_rounded),
                          ),
                          onTap: () => Navigator.of(context).pop(id), // ✅ retourne juste l'id
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
