import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardApi _api = DashboardApi();

  DashboardPayload? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _api.fetchDashboard();
    if (!mounted) return;
    setState(() {
      _data = result;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecondApp'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? _EmptyDockerState(
                  baseUrl: ApiConfig.jsonServerBaseUrl,
                  onRetry: _load,
                )
              : _DashboardBody(data: _data!, onRefresh: _load),
    );
  }
}

class _EmptyDockerState extends StatelessWidget {
  const _EmptyDockerState({
    required this.baseUrl,
    required this.onRetry,
  });

  final String baseUrl;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'L’application fonctionne, mais la base json-server (Docker) n’est pas '
              'joignable. Démarre le conteneur depuis le dossier SECONDAPP :\n'
              'docker compose up -d',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SelectableText(
              'URL utilisée : $baseUrl/dashboard',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.data,
    required this.onRefresh,
  });

  final DashboardPayload data;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final maxBalance = data.balanceData.isEmpty
        ? 1.0
        : data.balanceData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Données Docker (json-server)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final p in data.balanceData)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height:
                                    120 * (p.value / maxBalance).clamp(0.05, 1.0).toDouble(),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.month,
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...data.transactions.map(
            (t) => Card(
              child: ListTile(
                title: Text(t.name),
                subtitle: Text('${t.category} · ${t.time}'),
                trailing: Text(
                  t.amount >= 0
                      ? '+${t.amount.toStringAsFixed(2)}'
                      : t.amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: t.amount >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Insights', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...data.insights.map(
            (i) => Card(
              child: ListTile(
                title: Text(i.title),
                subtitle: Text(i.description),
                trailing: Text(
                  i.value,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
