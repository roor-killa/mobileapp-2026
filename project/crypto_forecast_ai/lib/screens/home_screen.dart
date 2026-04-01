import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api.dart';
import 'market_search_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final TextEditingController _coinCtrl = TextEditingController(text: "bitcoin");

  int _historyDays = 180;
  int _horizon = 7;

  bool _loadingHistory = false;
  bool _loadingPredict = false;

  List<double> _hist = [];
  double? _currentPrice;

  List<double> _pred = [];
  String _modelLabel = "—";

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tab.dispose();
    _coinCtrl.dispose();
    super.dispose();
  }

  String get _coinId => _coinCtrl.text.trim().toLowerCase();

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _loadHistory() async {
    final id = _coinId;
    if (id.isEmpty) return _snack("Coin ID requis (ex: bitcoin).");

    setState(() => _loadingHistory = true);
    try {
      final data = await api.history(id, days: _historyDays);
      final prices = (data["prices"] as List<dynamic>? ?? [])
          .map((p) => (p as List<dynamic>)[1] as num)
          .map((v) => v.toDouble())
          .toList();

      if (prices.isEmpty) throw Exception("Historique vide (coin_id invalide ?)");

      setState(() {
        _hist = prices;
        _currentPrice = prices.last;
        _pred = [];
        _modelLabel = "—";
      });
    } catch (e) {
      _snack("Chargement historique impossible: $e");
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _predict() async {
    final id = _coinId;
    if (id.isEmpty) return _snack("Coin ID requis (ex: bitcoin).");
    if (_hist.isEmpty) return _snack("Charge l’historique avant de prédire.");

    setState(() => _loadingPredict = true);
    try {
      final data = await api.predict(id, horizon: _horizon);
      final preds = (data["predicted_prices"] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList();

      setState(() {
        _pred = preds;
        _modelLabel = (data["model"] ?? "Modèle").toString();
        _currentPrice = (data["current_price"] as num?)?.toDouble() ?? _currentPrice;
      });

      _tab.animateTo(1);
    } catch (e) {
      _snack("Prévision impossible: $e");
    } finally {
      if (mounted) setState(() => _loadingPredict = false);
    }
  }

  double? get _projection => _pred.isEmpty ? null : _pred.last;

  double? get _delta {
    if (_currentPrice == null || _projection == null) return null;
    return _projection! - _currentPrice!;
  }

  double? get _pct {
    if (_currentPrice == null || _projection == null || _currentPrice == 0) return null;
    return (_projection! - _currentPrice!) / _currentPrice! * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final coinName = _coinId.isEmpty ? "—" : _coinId.toUpperCase();

    final cur = _currentPrice;
    final proj = _projection;
    final delta = _delta;
    final pct = _pct;
    final up = (delta ?? 0) >= 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Analyse"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Watchlist",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WatchlistScreen()),
            ),
            icon: const Icon(Icons.star_rounded),
          ),
          IconButton(
            tooltip: "Info",
            onPressed: () => _snack("Coin ID = identifiant CoinGecko (bitcoin, ethereum, solana...)"),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _FuturTabs(controller: _tab),
          ),
        ),
      ),
      body: Stack(
        children: [
          _FuturBackground(primary: cs.primary, secondary: cs.secondary),
          SafeArea(
            child: TabBarView(
              controller: _tab,
              children: [
                _OverviewTab(
                  coinName: coinName,
                  coinCtrl: _coinCtrl,
                  historyDays: _historyDays,
                  horizon: _horizon,
                  onChangeDays: (v) => setState(() => _historyDays = v),
                  onChangeHorizon: (v) => setState(() => _horizon = v),
                  onSubmitCoin: _loadHistory,
                  current: cur,
                  projection: proj,
                  modelLabel: _modelLabel,
                  delta: delta,
                  pct: pct,
                  deltaUp: up,
                  loadingHistory: _loadingHistory,
                  loadingPredict: _loadingPredict,
                ),
                _ForecastTab(
                  coinName: coinName,
                  horizon: _horizon,
                  current: cur,
                  projection: proj,
                  modelLabel: _modelLabel,
                  preds: _pred,
                ),
                _ChartTab(hist: _hist, pred: _pred),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _FuturBottomBar(
        loadingLoad: _loadingHistory,
        loadingPredict: _loadingPredict,
        onLoad: _loadingHistory ? null : _loadHistory,
        onPredict: _loadingPredict ? null : _predict,
      ),
    );
  }
}

// =========================
// UI components (modern)
// =========================

class _FuturBackground extends StatelessWidget {
  final Color primary;
  final Color secondary;
  const _FuturBackground({required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.7, -0.9),
          radius: 1.2,
          colors: [
            primary.withOpacity(0.25),
            secondary.withOpacity(0.12),
            const Color(0xFF05070B),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -120,
            top: 30,
            child: _GlowBlob(color: secondary.withOpacity(0.35), size: 280),
          ),
          Positioned(
            left: -140,
            bottom: -40,
            child: _GlowBlob(color: primary.withOpacity(0.30), size: 320),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 90,
              spreadRadius: 40,
            )
          ],
        ),
      ),
    );
  }
}

class _FuturTabs extends StatelessWidget {
  final TabController controller;
  const _FuturTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface.withOpacity(0.50),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [cs.primary.withOpacity(0.35), cs.secondary.withOpacity(0.22)],
          ),
          border: Border.all(color: cs.primary.withOpacity(0.25)),
        ),
        tabs: const [
          Tab(text: "Aperçu"),
          Tab(text: "Prévision"),
          Tab(text: "Graphique"),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface.withOpacity(0.65),
            cs.surface.withOpacity(0.38),
          ],
        ),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 14),
          )
        ],
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  const _Chip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.22),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Text(
        "$label : $value",
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  final double delta;
  final double pct;
  final bool up;
  const _DeltaPill({required this.delta, required this.pct, required this.up});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = up ? cs.primaryContainer : cs.errorContainer;
    final fg = up ? cs.onPrimaryContainer : cs.onErrorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
        boxShadow: [
          BoxShadow(
            color: (up ? cs.primary : cs.error).withOpacity(0.20),
            blurRadius: 18,
          )
        ],
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
      ),
      child: Text(
        "${up ? "+" : ""}\$${delta.toStringAsFixed(2)} (${pct >= 0 ? "+" : ""}${pct.toStringAsFixed(2)}%)",
        style: TextStyle(fontWeight: FontWeight.w900, color: fg),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String coinName;
  final TextEditingController coinCtrl;

  final int historyDays;
  final int horizon;
  final ValueChanged<int> onChangeDays;
  final ValueChanged<int> onChangeHorizon;
  final VoidCallback onSubmitCoin;

  final double? current;
  final double? projection;
  final String modelLabel;
  final double? delta;
  final double? pct;
  final bool deltaUp;

  final bool loadingHistory;
  final bool loadingPredict;

  const _OverviewTab({
    required this.coinName,
    required this.coinCtrl,
    required this.historyDays,
    required this.horizon,
    required this.onChangeDays,
    required this.onChangeHorizon,
    required this.onSubmitCoin,
    required this.current,
    required this.projection,
    required this.modelLabel,
    required this.delta,
    required this.pct,
    required this.deltaUp,
    required this.loadingHistory,
    required this.loadingPredict,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coinName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Chip(label: "Prix", value: current == null ? "—" : "\$${current!.toStringAsFixed(2)}"),
                  _Chip(label: "Horizon", value: "J+$horizon"),
                  const _Chip(label: "Zoom", value: "90 pts"),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Projection : ${projection == null ? "—" : "\$${projection!.toStringAsFixed(2)}"}",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text("Modèle : $modelLabel", style: TextStyle(color: cs.onSurface.withOpacity(0.70))),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: (delta != null && pct != null)
                        ? _DeltaPill(delta: delta!, pct: pct!, up: deltaUp)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (loadingHistory || loadingPredict)
                LinearProgressIndicator(
                  minHeight: 3,
                  color: cs.primary,
                  backgroundColor: cs.onSurface.withOpacity(0.08),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Actif", style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.18),
                  border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: cs.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: coinCtrl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "CoinGecko id (bitcoin, ethereum...)",
                        ),
                        onSubmitted: (_) => onSubmitCoin(),
                      ),
                    ),
                    IconButton(
                      tooltip: "Recherche",
                      onPressed: () async {
                        final picked = await Navigator.push<String?>(
                          context,
                          MaterialPageRoute(builder: (_) => const MarketSearchScreen()),
                        );
                        final id = (picked ?? "").trim();
                        if (id.isNotEmpty) {
                          coinCtrl.text = id;
                          onSubmitCoin();
                        }
                      },
                      icon: const Icon(Icons.manage_search_rounded),
                    ),
                    IconButton(
                      tooltip: "Effacer",
                      onPressed: () => coinCtrl.clear(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dropBlock(
                      cs,
                      label: "Jours d'historique",
                      child: DropdownButton<int>(
                        value: historyDays,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: cs.surface,
                        items: const [30, 90, 180, 365].map((d) {
                          return DropdownMenuItem(value: d, child: Text("$d"));
                        }).toList(),
                        onChanged: (v) => onChangeDays(v ?? 180),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropBlock(
                      cs,
                      label: "Prévision",
                      child: DropdownButton<int>(
                        value: horizon,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: cs.surface,
                        items: const [3, 7, 14, 30].map((h) {
                          return DropdownMenuItem(value: h, child: Text("J+$h"));
                        }).toList(),
                        onChanged: (v) => onChangeHorizon(v ?? 7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Tip: coinId doit correspondre à CoinGecko.",
                style: TextStyle(color: cs.onSurface.withOpacity(0.55), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dropBlock(ColorScheme cs, {required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.18),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _ForecastTab extends StatelessWidget {
  final String coinName;
  final int horizon;
  final double? current;
  final double? projection;
  final String modelLabel;
  final List<double> preds;

  const _ForecastTab({
    required this.coinName,
    required this.horizon,
    required this.current,
    required this.projection,
    required this.modelLabel,
    required this.preds,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Prévision • $coinName", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 10),
              Text("Prix actuel : ${current == null ? "—" : "\$${current!.toStringAsFixed(2)}"}"),
              Text("Projection (J+$horizon) : ${projection == null ? "—" : "\$${projection!.toStringAsFixed(2)}"}"),
              const SizedBox(height: 8),
              Text("Modèle : $modelLabel", style: TextStyle(color: cs.onSurface.withOpacity(0.70))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _GlassCard(
          child: preds.isEmpty
              ? Text("Aucune prévision. Appuie sur “Prédire”.",
                  style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontWeight: FontWeight.w700))
              : Column(
                  children: preds.asMap().entries.map((e) {
                    final day = e.key + 1;
                    final v = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.18),
                        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 62,
                            child: Text("J+$day", style: const TextStyle(fontWeight: FontWeight.w900)),
                          ),
                          Expanded(
                            child: Text("\$${v.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _ChartTab extends StatelessWidget {
  final List<double> hist;
  final List<double> pred;
  const _ChartTab({required this.hist, required this.pred});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (hist.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          _GlassCard(
            child: SizedBox(
              height: 260,
              child: Center(
                child: Text(
                  "Charge l’historique pour afficher un graphique.",
                  style: TextStyle(color: cs.onSurface.withOpacity(0.70), fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final histSpots = <FlSpot>[];
    for (int i = 0; i < hist.length; i++) {
      histSpots.add(FlSpot(i.toDouble(), hist[i]));
    }

    final predSpots = <FlSpot>[];
    if (pred.isNotEmpty) {
      final startX = (hist.length - 1).toDouble();
      predSpots.add(FlSpot(startX, hist.last));
      for (int i = 0; i < pred.length; i++) {
        predSpots.add(FlSpot(startX + (i + 1).toDouble(), pred[i]));
      }
    }

    final allY = [...hist, ...pred];
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.08;
    final yMin = minY - pad;
    final yMax = maxY + pad;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Graphique", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                pred.isEmpty ? "Historique (USD)" : "Historique + Prévision (USD)",
                style: TextStyle(color: cs.onSurface.withOpacity(0.70), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: LineChart(
                  LineChartData(
                    minY: yMin,
                    maxY: yMax,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (yMax - yMin) / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: cs.onSurface.withOpacity(0.06),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (v, meta) => Text(
                            "\$${v.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          return spots.map((s) {
                            final x = s.x.toInt();
                            final isPred = pred.isNotEmpty && x >= hist.length - 1;
                            final label = isPred ? "Prévision" : "Historique";
                            return LineTooltipItem(
                              "$label\n\$${s.y.toStringAsFixed(2)}",
                              const TextStyle(fontWeight: FontWeight.w900),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: histSpots,
                        isCurved: true,
                        curveSmoothness: 0.25,
                        barWidth: 3,
                        color: cs.primary,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cs.primary.withOpacity(0.18),
                              cs.primary.withOpacity(0.00),
                            ],
                          ),
                        ),
                      ),
                      if (predSpots.isNotEmpty)
                        LineChartBarData(
                          spots: predSpots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          barWidth: 2,
                          color: cs.secondary,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 2.2,
                              color: cs.secondary,
                              strokeColor: cs.surface,
                              strokeWidth: 1,
                            ),
                          ),
                          belowBarData: BarAreaData(show: false),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _legend(cs.primary, "Historique"),
                  if (predSpots.isNotEmpty) _legend(cs.secondary, "Prévision"),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(Color c, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(99)),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ],
    );
  }
}

class _FuturBottomBar extends StatelessWidget {
  final VoidCallback? onLoad;
  final VoidCallback? onPredict;
  final bool loadingLoad;
  final bool loadingPredict;

  const _FuturBottomBar({
    required this.onLoad,
    required this.onPredict,
    required this.loadingLoad,
    required this.loadingPredict,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget loader() => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onLoad,
                icon: loadingLoad ? loader() : const Icon(Icons.download_rounded),
                label: const Text("Charger", style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.surface.withOpacity(0.72),
                  foregroundColor: cs.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPredict,
                icon: loadingPredict ? loader() : const Icon(Icons.auto_graph_rounded),
                label: const Text("Prédire", style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shadowColor: cs.primary.withOpacity(0.35),
                  elevation: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}