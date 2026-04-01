
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'orders_screen.dart';

import '../services/api.dart';
import '../services/auth_store.dart';
import '../services/session_store.dart';

class WalletScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const WalletScreen({super.key, required this.onLogout});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _refreshEvery = Duration(seconds: 10); // ✅ “temps réel” (safe)
  Timer? _ticker;

  Timer? _pricesTimer;
  Timer? _walletTimer;

  Map<String, double> _livePrices = {}; // coin_id -> price
  DateTime? _lastPricesAt;
  double? _lastTotalUsdForAnim; // optionnel pour animation total


  bool _loading = true;
  String? _err;
  Map<String, dynamic>? _wallet;

  double? _prevTotal;
  Map<String, double> _prevPrice = {}; // coin_id -> last price

  final _usd = NumberFormat.currency(locale: 'fr_FR', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _reload();
    _ticker = Timer.periodic(_refreshEvery, (_) => _reload(silent: true));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _reload({bool silent = false}) async {
    setState(() {
      if (!silent) _loading = true;
      _err = null;
    });

    try {
      final w = await api.wallet();

      // Map des prix actuels (pour delta)
      final holdings = (w["holdings"] as List<dynamic>? ?? []);
      final currentPrice = <String, double>{};
      for (final h in holdings) {
        final m = (h as Map).cast<String, dynamic>();
        final cid = (m["coin_id"] ?? "").toString();
        final p = (m["price_usd"] ?? 0).toDouble();
        if (cid.isNotEmpty) currentPrice[cid] = p;
      }

      final newTotal = (w["total_usd"] ?? 0).toDouble();
      _prevTotal ??= newTotal;

      setState(() {
        _wallet = w;
        _prevPrice = _prevPrice.isEmpty ? currentPrice : _prevPrice;
      });

      // met à jour les références “previous” après setState (pour delta visuel)
      _prevTotal = _prevTotal ?? newTotal;
      _prevPrice = _prevPrice.isEmpty ? currentPrice : _prevPrice;

      // Ici on “commit” la nouvelle baseline pour la prochaine tick
      _prevTotal = newTotal;
      _prevPrice = currentPrice;
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      setState(() {
        if (!silent) _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    // On vide les 2 stores (le projet a 2 clés différentes selon les écrans)
    await AuthStore.clear();
    await SessionStore.clear();
    api.setToken(null);
    widget.onLogout();
  }

  Future<void> _openTradeSheet({required bool isBuy}) async {
    final cs = Theme.of(context).colorScheme;

    final coinCtrl = TextEditingController(text: "bitcoin");
    final amountCtrl = TextEditingController(text: isBuy ? "100" : "0.01");

    // ✅ Saisie intelligente (CoinGecko via /search?query=...)
    Timer? _coinDebounce;
    bool searchingCoins = false;
    List<Map<String, dynamic>> coinSuggestions = [];


    String? err;
    bool busy = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(builder: (context, setSheet) {
          Future<void> submit() async {
            setSheet(() {
              busy = true;
              err = null;
            });
            try {
              final coin = coinCtrl.text.trim().toLowerCase();
              final raw = amountCtrl.text.replaceAll(",", ".").trim();
              final v = double.parse(raw);

              if (isBuy) {
                await api.buy(coin, v);
              } else {
                await api.sell(coin, v);
              }

              if (context.mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(isBuy ? "Achat effectué (démo)" : "Vente effectuée (démo)"),
                  ),
                );
              }
              await _reload();
            } catch (e) {
              setSheet(() => err = e.toString());
            } finally {
              setSheet(() => busy = false);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A1022),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.primary.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 22,
                    spreadRadius: 2,
                    color: cs.primary.withOpacity(0.15),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: isBuy ? cs.primaryContainer : cs.tertiaryContainer,
                        ),
                        child: Text(
                          isBuy ? "ACHETER" : "VENDRE",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isBuy ? cs.onPrimaryContainer : cs.onTertiaryContainer,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: coinCtrl,
                      onChanged: (v) {
                        final q = v.trim();
                        _coinDebounce?.cancel();

                        if (q.length < 2) {
                          setSheet(() {
                            coinSuggestions = [];
                            searchingCoins = false;
                          });
                          return;
                        }

                        setSheet(() => searchingCoins = true);

                        _coinDebounce = Timer(const Duration(milliseconds: 300), () async {
                          try {
                            final coins = await api.searchCoins(q);

                            // tri intelligent : meilleur market_cap_rank en premier
                            coins.sort((a, b) {
                              final ar = (a["market_cap_rank"] ?? 999999) as int;
                              final br = (b["market_cap_rank"] ?? 999999) as int;
                              return ar.compareTo(br);
                            });

                            final top = coins.take(8).toList();

                            setSheet(() {
                              coinSuggestions = top;
                              searchingCoins = false;
                            });
                          } catch (_) {
                            setSheet(() {
                              coinSuggestions = [];
                              searchingCoins = false;
                            });
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Crypto (coin_id)",
                        hintText: "ex: bitcoin, ethereum, solana",
                        suffixIcon: searchingCoins
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.search_rounded),
                      ),
                    ),

                    if (coinSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: coinSuggestions.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.06)),
                          itemBuilder: (_, i) {
                            final c = coinSuggestions[i];
                            final id = (c["id"] ?? "").toString();
                            final name = (c["name"] ?? "").toString();
                            final sym = (c["symbol"] ?? "").toString().toUpperCase();

                            return ListTile(
                              dense: true,
                              title: Text("$name ($sym)", style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text(id, style: TextStyle(color: Colors.white.withOpacity(0.65))),
                              onTap: () {
                                coinCtrl.text = id; // ✅ on enregistre l'id attendu par le backend
                                setSheet(() => coinSuggestions = []);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: isBuy ? "Montant USD" : "Quantité crypto",
                    ),
                  ),
                  if (err != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      err!,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: busy ? null : submit,
                      child: busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isBuy ? "Confirmer l'achat" : "Confirmer la vente"),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final w = _wallet;
    final cash = (w?["cash_usd"] ?? 0).toDouble();
    final total = (w?["total_usd"] ?? 0).toDouble();
    final holdings = (w?["holdings"] as List<dynamic>? ?? []);

    // delta total (sur le dernier refresh)
    // (si tu veux une delta stable, on peut garder une baseline séparée)
    final delta = 0.0; // on garde simple ici (optionnel)

    return Scaffold(
      appBar: AppBar(
        title: const Text("Portefeuille"),
        actions: [
          IconButton(
            onPressed: () => _reload(),
            icon: const Icon(Icons.refresh),
            tooltip: "Rafraîchir",
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: "Ordres",
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Déconnexion",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_err != null) ...[
              const SizedBox(height: 10),
              Text(_err!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 10),

            // ===== HERO CARD (futur) =====
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.20),
                    cs.tertiary.withOpacity(0.12),
                    const Color(0xFF070A12),
                  ],
                ),
                border: Border.all(color: cs.primary.withOpacity(0.28)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    spreadRadius: 2,
                    color: cs.primary.withOpacity(0.18),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet),
                      const SizedBox(width: 8),
                      const Text("Valeur totale", style: TextStyle(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cs.primary.withOpacity(0.25)),
                        ),
                        child: Text(
                          "LIVE ${_refreshEvery.inSeconds}s",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      _usd.format(total),
                      key: ValueKey(total.toStringAsFixed(2)),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Cash USD : ${_usd.format(cash)}",
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w700),
                  ),
                  if (delta != 0) const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== Actions =====
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _loading ? null : () => _openTradeSheet(isBuy: true),
                    child: const Text("Acheter"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : () => _openTradeSheet(isBuy: false),
                    child: const Text("Vendre"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Text("Positions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),

            if (holdings.isEmpty)
              Text("Aucune position pour l’instant.", style: TextStyle(color: Colors.white.withOpacity(0.75)))
            else
              ...holdings.map((h) {
                final m = (h as Map).cast<String, dynamic>();
                final coin = (m["coin_id"] ?? "").toString();
                final amount = (m["amount"] ?? 0).toDouble();
                final price = (m["price_usd"] ?? 0).toDouble();
                final value = (m["value_usd"] ?? 0).toDouble();

                // delta prix depuis la dernière refresh (si dispo)
                // ✅ PnL latent (si fourni par l'API)
                final pnl = (m["pnl_usd"] ?? 0).toDouble();
                final pnlPct = (m["pnl_pct"] ?? 0).toDouble();
                final avgCost = (m["avg_cost_usd"] ?? 0).toDouble();

                final up = pnl >= 0;
                final pillBg = up ? cs.primaryContainer : cs.errorContainer;
                final pillFg = up ? cs.onPrimaryContainer : cs.onErrorContainer;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFF0A1022),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: ListTile(
                    title: Text(
                      coin.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Qty: ${amount.toStringAsFixed(6)}  •  PRU: ${_usd.format(avgCost)}  •  Prix: ${_usd.format(price)}",
                        style: TextStyle(color: Colors.white.withOpacity(0.70)),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _usd.format(value),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Container(
                            key: ValueKey("${coin}_$pnl"),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              "${up ? '+' : ''}${pnl.toStringAsFixed(2)} (${up ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: pillFg,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
