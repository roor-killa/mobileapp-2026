import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../services/api.dart';
import '../services/history_store.dart';
import '../models/history_entry.dart';

class _PricePoint {
  final DateTime t;
  final double price;
  const _PricePoint(this.t, this.price);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _api = Api(baseUrl: "http://127.0.0.1:8000");
  final _store = HistoryStore();

  final _searchCtrl = TextEditingController(text: "bitcoin");

  Timer? _debounce;
  bool _searchLoading = false;
  List<Map<String, dynamic>> _suggestions = [];

  int _days = 180;
  int _horizon = 7;
  int _zoom = 90;

  bool _loading = false;
  String? _error;

  List<_PricePoint> _history = [];
  List<double> _predicted = [];
  double? _currentPrice;
  String _model = "";

  final _usd = NumberFormat.currency(locale: "en_US", symbol: "\$");
  final _dateFmt = DateFormat("dd/MM/yyyy", "fr_FR");

  late final AnimationController _pulse;

  static const bg1 = Color(0xFF070A12);
  static const bg2 = Color(0xFF0B1230);
  static const surface = Color(0xFF0C1020);

  // Palette Trading: cyan (historique) / vert (prévision) / rouge baisse
  static const neon = Color(0xFF22D3EE);  // cyan
  static const neon2 = Color(0xFF34D399); // vert néon
  static const down = Color(0xFFFB7185);  // rouge/rose

  String get _coinId => _searchCtrl.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _chargerHistorique());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _showInfo() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("À propos",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text(
                  "Estimation basée sur l’historique + un modèle simple.\n"
                  "Ce n’est pas un conseil d’investissement.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    final q = v.trim().toLowerCase();
    if (q.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        setState(() => _searchLoading = true);
        final res = await _api.searchCoins(q);
        if (!mounted) return;
        setState(() => _suggestions = res);
      } catch (_) {
        if (!mounted) return;
        setState(() => _suggestions = []);
      } finally {
        if (mounted) setState(() => _searchLoading = false);
      }
    });
  }

  Future<void> _chargerHistorique() async {
    setState(() {
      _loading = true;
      _error = null;
      // on garde la data précédente (si tu veux), ou on vide :
      // _history = [];
      _predicted = [];
      _model = "";
    });

    try {
      if (_coinId.isEmpty) throw Exception("Entre un actif (ex: bitcoin).");

      final data = await _api.history(_coinId, days: _days);

      final raw = (data["prices"] as List<dynamic>);
      final points = raw.map((e) {
        final ts = (e as List<dynamic>)[0] as num;
        final price = (e[1] as num).toDouble();
        return _PricePoint(
          DateTime.fromMillisecondsSinceEpoch(ts.toInt(), isUtc: true).toLocal(),
          price,
        );
      }).toList();

      setState(() {
        _history = points;
        _currentPrice = points.isNotEmpty ? points.last.price : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _predire() async {
    setState(() {
      _loading = true;
      _error = null;
      _predicted = [];
      _model = "";
    });

    try {
      if (_coinId.isEmpty) throw Exception("Entre un actif (ex: bitcoin).");

      final data = await _api.predict(_coinId, horizon: _horizon);
      if (data["success"] != true) {
        throw Exception(data["message"] ?? "Échec de la prédiction");
      }

      final current = (data["current_price"] as num).toDouble();
      final preds = (data["predicted_prices"] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();
      final model = (data["model"] as String?) ?? "unknown";

      setState(() {
        _currentPrice = current;
        _predicted = preds;
        _model = model;
      });

      await _store.add(
        HistoryEntry(
          coinId: _coinId,
          createdAt: DateTime.now(),
          currentPrice: current,
          horizonDays: _horizon,
          predictedPrices: preds,
          model: model,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prédiction enregistrée")),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<_PricePoint> get _visibleHistory {
    if (_history.isEmpty) return [];
    final n = _history.length;
    if (_zoom <= 0 || _zoom >= n || _zoom == 999999) return _history;
    return _history.sublist(n - _zoom);
  }

  List<FlSpot> _historySpots() {
    final vis = _visibleHistory;
    return List.generate(vis.length, (i) => FlSpot(i.toDouble(), vis[i].price));
  }

  List<FlSpot> _predSpots() {
    final startX =
        _visibleHistory.isEmpty ? 0 : _visibleHistory.length.toDouble();
    return List.generate(
        _predicted.length, (i) => FlSpot(startX + i.toDouble(), _predicted[i]));
  }

  String _zoomLabel() => _zoom == 999999 ? "Tout" : "${_zoom} pts";

  Widget _chip(String label, String value, {Color? glow}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1F2A4A)),
        boxShadow: glow == null
            ? const []
            : [
                BoxShadow(
                  color: glow.withOpacity(0.25),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label : ",
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vis = _visibleHistory;
    final history = _historySpots();
    final preds = _predSpots();

    final current = _currentPrice;
    final forecastLast = _predicted.isNotEmpty ? _predicted.last : null;

    double? delta;
    double? pct;
    if (current != null && forecastLast != null && current != 0) {
      delta = forecastLast - current;
      pct = (delta / current) * 100.0;
    }

    final hasForecast = (forecastLast != null && delta != null && pct != null);

    final skeletonPriceCard = _loading && current == null;
    final skeletonForecastList = _loading && _predicted.isEmpty;
    final skeletonChart = _loading && history.isEmpty;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Prévision Crypto"),
          actions: [
            IconButton(onPressed: _showInfo, icon: const Icon(Icons.info_outline)),
          ],
          bottom: const TabBar(
            indicatorColor: neon,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: "Aperçu"),
              Tab(text: "Prévision"),
              Tab(text: "Graphique"),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [bg1, bg2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: TabBarView(
              children: [
                // ================= APERÇU =================
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final t = _pulse.value;
                        final glowCyan = Color.lerp(
                          neon.withOpacity(0.05),
                          neon.withOpacity(0.22),
                          t,
                        )!;
                        final glowGreen = Color.lerp(
                          neon2.withOpacity(0.04),
                          neon2.withOpacity(0.18),
                          1 - t,
                        )!;

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                          color: glowCyan,
                                          blurRadius: 40,
                                          spreadRadius: 1),
                                      BoxShadow(
                                          color: glowGreen,
                                          blurRadius: 42,
                                          spreadRadius: 1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _coinId.isEmpty
                                          ? "Choisir un actif"
                                          : _coinId.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 12),

                                    if (skeletonPriceCard)
                                      const FuturSkeletonPriceHeader()
                                    else
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          _chip(
                                            "Prix",
                                            current == null
                                                ? "—"
                                                : _usd.format(current),
                                            glow: neon,
                                          ),
                                          _chip("Horizon", "J+$_horizon",
                                              glow: neon2),
                                          _chip("Zoom", _zoomLabel()),
                                        ],
                                      ),

                                    const SizedBox(height: 14),

                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      child: _loading && !hasForecast
                                          ? const FuturSkeletonLineBlock(
                                              key: ValueKey("sk1"),
                                            )
                                          : hasForecast
                                              ? Row(
                                                  key: const ValueKey("forecast"),
                                                  children: [
                                                    Expanded(
                                                      child: TweenAnimationBuilder<
                                                          double>(
                                                        tween: Tween<double>(
                                                          begin: current ??
                                                              forecastLast!,
                                                          end: forecastLast!,
                                                        ),
                                                        duration: const Duration(
                                                            milliseconds: 350),
                                                        builder: (_, v, __) => Text(
                                                          "Projection : ${_usd.format(v)}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight.w900),
                                                        ),
                                                      ),
                                                    ),
                                                    Builder(builder: (_) {
                                                      final isUp = delta! >= 0;
                                                      final pillText =
                                                          isUp ? neon2 : down;
                                                      final pillBg = isUp
                                                          ? neon2.withOpacity(0.16)
                                                          : down.withOpacity(0.14);
                                                      final pillBorder = isUp
                                                          ? neon2.withOpacity(0.55)
                                                          : down.withOpacity(0.55);

                                                      return Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                        decoration: BoxDecoration(
                                                          color: pillBg,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  999),
                                                          border: Border.all(
                                                              color: pillBorder),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: pillText
                                                                  .withOpacity(
                                                                      0.18),
                                                              blurRadius: 18,
                                                              spreadRadius: 1,
                                                            )
                                                          ],
                                                        ),
                                                        child: Text(
                                                          "${delta! >= 0 ? '+' : ''}${_usd.format(delta)} (${pct! >= 0 ? '+' : ''}${pct!.toStringAsFixed(2)}%)",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: pillText,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                )
                                              : const Text(
                                                  "Charge l’historique puis lance une prédiction.",
                                                  key: ValueKey("hint"),
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                    ),

                                    if (_model.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text("Modèle : $_model",
                                          style: const TextStyle(
                                              color: Colors.white60)),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Recherche
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchCtrl,
                              onChanged: _onSearchChanged,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _chargerHistorique(),
                              decoration: InputDecoration(
                                labelText:
                                    "Rechercher un actif (CoinGecko id)",
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : (_coinId.isEmpty
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: _loading
                                                ? null
                                                : () => setState(
                                                    () => _searchCtrl.clear()),
                                          )),
                              ),
                            ),

                            if (_suggestions.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: surface.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFF1F2A4A)),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: _suggestions.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(
                                          height: 1,
                                          color: Color(0xFF1F2A4A)),
                                  itemBuilder: (context, i) {
                                    final s = _suggestions[i];
                                    final id = (s["id"] ?? "").toString();
                                    final name = (s["name"] ?? "").toString();
                                    final symbol = (s["symbol"] ?? "")
                                        .toString()
                                        .toUpperCase();
                                    final rank = s["market_cap_rank"];
                                    final thumb = (s["thumb"] ?? "").toString();

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF18223F),
                                        backgroundImage: thumb.isNotEmpty
                                            ? NetworkImage(thumb)
                                            : null,
                                        child: thumb.isEmpty
                                            ? Text(
                                                symbol.isNotEmpty
                                                    ? symbol[0]
                                                    : "?",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w900),
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        "$name ($symbol)",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      subtitle: Text(
                                        "id : $id${rank != null ? " • rang : $rank" : ""}",
                                        style: const TextStyle(
                                            color: Colors.white60),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _searchCtrl.text = id;
                                          _suggestions = [];
                                        });
                                        _chargerHistorique();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Paramètres + actions
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _days,
                                    dropdownColor: surface,
                                    decoration: const InputDecoration(
                                        labelText: "Jours d’historique"),
                                    items: const [30, 90, 180, 365]
                                        .map((d) => DropdownMenuItem(
                                            value: d, child: Text("$d")))
                                        .toList(),
                                    onChanged: _loading
                                        ? null
                                        : (v) =>
                                            setState(() => _days = v ?? 180),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _horizon,
                                    dropdownColor: surface,
                                    decoration: const InputDecoration(
                                        labelText: "Prévision"),
                                    items: const [1, 3, 7, 14]
                                        .map((h) => DropdownMenuItem(
                                            value: h, child: Text("J+$h")))
                                        .toList(),
                                    onChanged: _loading
                                        ? null
                                        : (v) => setState(
                                            () => _horizon = v ?? 7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    onPressed:
                                        _loading ? null : _chargerHistorique,
                                    icon: const Icon(Icons.download),
                                    label: const Text("Charger"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _loading ? null : _predire,
                                    icon: const Icon(Icons.auto_graph),
                                    label: const Text("Prédire"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_loading) const LinearProgressIndicator(),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: _error == null
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: Colors.redAccent),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _error!,
                                              style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight:
                                                      FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ================= PRÉVISION =================
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Trajectoire de prévision",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 10),

                            if (skeletonForecastList)
                              const FuturSkeletonForecastList()
                            else if (_predicted.isEmpty)
                              const Text(
                                "Lance une prédiction pour afficher les prix estimés.",
                                style: TextStyle(color: Colors.white70),
                              )
                            else
                              ...List.generate(_predicted.length, (i) {
                                final day = i + 1;
                                final value = _predicted[i];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 64,
                                        child: Text("J+$day",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white)),
                                      ),
                                      Expanded(
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: value * 0.98, end: value),
                                          duration: const Duration(
                                              milliseconds: 260),
                                          builder: (_, v, __) => Text(
                                            _usd.format(v),
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ================= GRAPHIQUE =================
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Graphique",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _zoom,
                              dropdownColor: surface,
                              decoration:
                                  const InputDecoration(labelText: "Zoom (fenêtre)"),
                              items: const [30, 90, 180, 999999]
                                  .map((z) => DropdownMenuItem(
                                        value: z,
                                        child: Text(
                                            z == 999999 ? "Tout" : "$z points"),
                                      ))
                                  .toList(),
                              onChanged: _loading
                                  ? null
                                  : (v) => setState(() => _zoom = (v ?? 90)),
                            ),
                            const SizedBox(height: 12),

                            if (skeletonChart)
                              const FuturSkeletonChart()
                            else if (history.isEmpty)
                              const Text("Aucune donnée. Clique sur “Charger”.",
                                  style: TextStyle(color: Colors.white70))
                            else
                              SizedBox(
                                height: 340,
                                child: LineChart(
                                  LineChartData(
                                    lineTouchData: LineTouchData(
  				      enabled: true,
  				      touchTooltipData: LineTouchTooltipData(
    					getTooltipColor: (touchedSpot) => surface.withOpacity(0.95),
    					tooltipBorderRadius: BorderRadius.circular(12),
    					tooltipBorder: const BorderSide(color: Color(0xFF1F2A4A)),
    					getTooltipItems: (spots) {
      					  return spots.map((s) {
        				    final idx = s.x.round();
        				    String dateStr = "";
        				    if (idx >= 0 && idx < vis.length) {
          				      dateStr = _dateFmt.format(vis[idx].t);
        				    }
        				    return LineTooltipItem(
          				      "$dateStr\n${_usd.format(s.y)}",
             				      const TextStyle(
            					fontWeight: FontWeight.w900,
            					color: Colors.white,
          				      ),
        				    );
      					  }).toList();
    					},
  				      ),
				    ),

                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                        color: const Color(0xFF1F2A4A),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                          color: const Color(0xFF1F2A4A)),
                                    ),
                                    lineBarsData: [
                                      // Historique cyan
                                      LineChartBarData(
                                        spots: history,
                                        isCurved: true,
                                        curveSmoothness: 0.18,
                                        color: neon,
                                        barWidth: 2.2,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              neon.withOpacity(0.22),
                                              Colors.transparent
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                      // Prévision vert
                                      if (preds.isNotEmpty)
                                        LineChartBarData(
                                          spots: preds,
                                          isCurved: true,
                                          curveSmoothness: 0.18,
                                          color: neon2,
                                          barWidth: 2.2,
                                          dotData:
                                              const FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                neon2.withOpacity(0.18),
                                                Colors.transparent
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C1020).withOpacity(0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1F2A4A)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/* =========================
   SKELETON (shimmer futur)
   ========================= */

class FuturShimmer extends StatefulWidget {
  final Widget child;
  const FuturShimmer({super.key, required this.child});

  @override
  State<FuturShimmer> createState() => _FuturShimmerState();
}

class _FuturShimmerState extends State<FuturShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value; // 0..1
        final base = const Color(0xFF0F1733);
        final hi = const Color(0xFF1B2A55);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, hi, base],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(slidePercent: t),
            ).createShader(rect);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent; // 0..1
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final dx = bounds.width * (slidePercent * 2 - 1);
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

class FuturSkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  const FuturSkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return FuturShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1733),
          borderRadius: borderRadius,
          border: Border.all(color: const Color(0xFF1F2A4A)),
        ),
      ),
    );
  }
}

class FuturSkeletonPriceHeader extends StatelessWidget {
  const FuturSkeletonPriceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        FuturSkeletonBox(height: 34, width: 170, borderRadius: BorderRadius.all(Radius.circular(999))),
        FuturSkeletonBox(height: 34, width: 110, borderRadius: BorderRadius.all(Radius.circular(999))),
        FuturSkeletonBox(height: 34, width: 120, borderRadius: BorderRadius.all(Radius.circular(999))),
      ],
    );
  }
}

class FuturSkeletonLineBlock extends StatelessWidget {
  const FuturSkeletonLineBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        FuturSkeletonBox(height: 16, width: 220),
        SizedBox(height: 10),
        FuturSkeletonBox(height: 14, width: 180),
      ],
    );
  }
}

class FuturSkeletonForecastList extends StatelessWidget {
  const FuturSkeletonForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(7, (i) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              FuturSkeletonBox(height: 14, width: 54),
              SizedBox(width: 14),
              Expanded(child: FuturSkeletonBox(height: 14)),
            ],
          ),
        );
      }),
    );
  }
}

class FuturSkeletonChart extends StatelessWidget {
  const FuturSkeletonChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        FuturSkeletonBox(height: 18, width: 140),
        SizedBox(height: 12),
        FuturSkeletonBox(height: 340),
      ],
    );
  }
}
