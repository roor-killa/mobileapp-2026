import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/history_store.dart';
import '../models/history_entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _store = HistoryStore();
  late Future<List<HistoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _store.load();
  }

  Future<void> _refresh() async {
    setState(() => _future = _store.load());
  }

  Future<void> _clear() async {
    await _store.clear();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    const bg1 = Color(0xFF070A12);
    const bg2 = Color(0xFF0B1230);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Historique"),
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: "Vider",
          )
        ],
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
          child: FutureBuilder<List<HistoryEntry>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snap.data ?? [];
              if (data.isEmpty) {
                return const Center(
                  child: Text("Aucune prédiction enregistrée.", style: TextStyle(color: Colors.white70)),
                );
              }
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final e = data[i];
                    return _GlassCard(
                      child: ListTile(
                        title: Text(
                          "${e.coinId.toUpperCase()} • J+${e.horizonDays}",
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        subtitle: Text(
                          "${e.createdAt.toLocal()}\n"
                          "Actuel: ${e.currentPrice.toStringAsFixed(2)} | Prévu: ${e.predictedLast.toStringAsFixed(2)}\n"
                          "${e.model}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

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
