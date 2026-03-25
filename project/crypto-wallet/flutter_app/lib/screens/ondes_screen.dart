import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/appwrite_database_service.dart';

/// Écran pour afficher et ajouter des ondes (table Appwrite).
class OndesScreen extends StatefulWidget {
  const OndesScreen({super.key});

  @override
  State<OndesScreen> createState() => _OndesScreenState();
}

class _OndesScreenState extends State<OndesScreen> {
  final _db = AppwriteDatabaseService();
  List<Map<String, dynamic>> _ondes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _db.listOndes();
      if (mounted) setState(() {
        _ondes = list;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _addOnde() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const _AddOndeDialog(),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onde ajoutée'), backgroundColor: AppTheme.primary),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ondes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _addOnde,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 16),
            Text('Chargement...', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }
    if (_ondes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.waves_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Aucune onde', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Appuyez sur + pour en ajouter une', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addOnde,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une onde'),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _ondes.length,
      itemBuilder: (context, i) {
        final o = _ondes[i];
        final data = o['data'] as Map<String, dynamic>? ?? o;
        return _OndeTile(
          waveLength: (data['waveLength'] as num?)?.toDouble(),
          amplitude: (data['amplitude'] as num?)?.toDouble(),
          frequency: (data['frequency'] as num?)?.toDouble(),
          phaseShift: (data['phaseShift'] as num?)?.toDouble(),
          waveType: data['waveType'] as String?,
          origin: data['origin'] as String?,
        );
      },
    );
  }
}

class _OndeTile extends StatelessWidget {
  final double? waveLength;
  final double? amplitude;
  final double? frequency;
  final double? phaseShift;
  final String? waveType;
  final String? origin;

  const _OndeTile({
    this.waveLength,
    this.amplitude,
    this.frequency,
    this.phaseShift,
    this.waveType,
    this.origin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (waveType != null) Text(waveType!, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip('λ ${waveLength?.toStringAsFixed(1) ?? '-'}', Icons.straighten_rounded),
              const SizedBox(width: 8),
              _chip('A ${amplitude?.toStringAsFixed(1) ?? '-'}', Icons.show_chart_rounded),
              const SizedBox(width: 8),
              _chip('f ${frequency?.toStringAsFixed(1) ?? '-'}', Icons.speed_rounded),
            ],
          ),
          if (phaseShift != null || origin != null) ...[
            const SizedBox(height: 8),
            Text(
              [if (phaseShift != null) 'Phase: $phaseShift', if (origin != null) 'Origine: $origin'].join(' • '),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AddOndeDialog extends StatefulWidget {
  const _AddOndeDialog();

  @override
  State<_AddOndeDialog> createState() => _AddOndeDialogState();
}

class _AddOndeDialogState extends State<_AddOndeDialog> {
  final _waveLength = TextEditingController(text: '1.0');
  final _amplitude = TextEditingController(text: '1.0');
  final _frequency = TextEditingController(text: '1.0');
  final _phaseShift = TextEditingController(text: '0');
  final _waveType = TextEditingController(text: 'sinus');
  final _origin = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _waveLength.dispose();
    _amplitude.dispose();
    _frequency.dispose();
    _phaseShift.dispose();
    _waveType.dispose();
    _origin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final wl = double.tryParse(_waveLength.text);
    final amp = double.tryParse(_amplitude.text);
    final freq = double.tryParse(_frequency.text);
    if (wl == null || amp == null || freq == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir longueur, amplitude et fréquence'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AppwriteDatabaseService().createOnde(
        waveLength: wl,
        amplitude: amp,
        frequency: freq,
        phaseShift: double.tryParse(_phaseShift.text),
        waveType: _waveType.text.isEmpty ? null : _waveType.text,
        origin: _origin.text.isEmpty ? null : _origin.text,
      );
      if (mounted) Navigator.pop(context, {'ok': true});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Nouvelle onde', style: TextStyle(color: AppTheme.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _waveLength,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longueur d\'onde (waveLength)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amplitude,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amplitude', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _frequency,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Fréquence', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phaseShift,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Déphasage (optionnel)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _waveType,
              decoration: const InputDecoration(labelText: 'Type (sinus, carré...)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _origin,
              decoration: const InputDecoration(labelText: 'Origine (optionnel)', border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Ajouter'),
        ),
      ],
    );
  }
}
