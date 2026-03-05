import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  bool _blocked = false;
  bool _showDetails = false;
  bool _onlinePayments = true;
  bool _abroadPayments = true;
  bool _atmWithdrawals = false;
  bool _contactless = true;
  double _paymentLimit = 3000;
  double _atmLimit = 500;
  double _onlineLimit = 2000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ma carte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCreditCard(),
            if (_blocked)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Carte bloquée', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _buildActions(),
            const SizedBox(height: 24),
            _buildToggleSettings(),
            const SizedBox(height: 24),
            _buildLimits(),
            const SizedBox(height: 24),
            _buildSpending(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _blocked ? [Colors.grey.shade700, Colors.grey.shade900] : [const Color(0xFF7C3AED), const Color(0xFF3B0F8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (_blocked ? Colors.grey : AppTheme.primary).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NodEX', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Icon(_blocked ? Icons.lock_rounded : Icons.contactless_rounded, color: Colors.white70, size: 28),
            ],
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: '4242888812345678'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Numéro copié'), backgroundColor: AppTheme.primary));
            },
            child: Text(
              _showDetails ? '4242  8888  1234  5678' : '••••  ••••  ••••  5678',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 3, fontFamily: 'monospace'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TITULAIRE', style: TextStyle(color: Colors.white54, fontSize: 10)),
                Text('NEYMAR NODEX', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('EXPIRE', style: TextStyle(color: Colors.white54, fontSize: 10)),
                const Text('12/28', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
              if (_showDetails)
                const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('CVV', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('742', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                ])
              else
                const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _actionBtn(
          icon: _blocked ? Icons.lock_open_rounded : Icons.lock_rounded,
          label: _blocked ? 'Débloquer' : 'Bloquer',
          color: _blocked ? const Color(0xFF10B981) : Colors.redAccent,
          onTap: () {
            setState(() => _blocked = !_blocked);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_blocked ? 'Carte bloquée' : 'Carte débloquée'), backgroundColor: _blocked ? Colors.redAccent : const Color(0xFF10B981)),
            );
          },
        ),
        const SizedBox(width: 10),
        _actionBtn(
          icon: _showDetails ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          label: _showDetails ? 'Masquer' : 'Détails',
          color: AppTheme.primary,
          onTap: () => setState(() => _showDetails = !_showDetails),
        ),
        const SizedBox(width: 10),
        _actionBtn(
          icon: Icons.pin_rounded,
          label: 'Code PIN',
          color: const Color(0xFFF59E0B),
          onTap: () => _showPinDialog(),
        ),
        const SizedBox(width: 10),
        _actionBtn(
          icon: Icons.tune_rounded,
          label: 'Plafonds',
          color: const Color(0xFF10B981),
          onTap: () => _showLimitsDialog(),
        ),
      ],
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSettings() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _toggle(Icons.shopping_bag_rounded, 'Paiements en ligne', _onlinePayments, (v) => setState(() => _onlinePayments = v)),
          const Divider(height: 1, color: AppTheme.border, indent: 52),
          _toggle(Icons.flight_rounded, 'Paiements à l\'étranger', _abroadPayments, (v) => setState(() => _abroadPayments = v)),
          const Divider(height: 1, color: AppTheme.border, indent: 52),
          _toggle(Icons.atm_rounded, 'Retraits DAB', _atmWithdrawals, (v) => setState(() => _atmWithdrawals = v)),
          const Divider(height: 1, color: AppTheme.border, indent: 52),
          _toggle(Icons.contactless_rounded, 'Sans contact', _contactless, (v) => setState(() => _contactless = v)),
        ],
      ),
    );
  }

  Widget _toggle(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 22),
      title: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary),
    );
  }

  Widget _buildLimits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Plafonds actuels', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _limitRow(Icons.credit_card_rounded, 'Paiement', _paymentLimit, 5000),
        const SizedBox(height: 8),
        _limitRow(Icons.atm_rounded, 'Retrait DAB', _atmLimit, 1000),
        const SizedBox(height: 8),
        _limitRow(Icons.shopping_cart_rounded, 'En ligne', _onlineLimit, 5000),
      ],
    );
  }

  Widget _limitRow(IconData icon, String label, double current, double max) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: current / max, backgroundColor: AppTheme.border, color: AppTheme.primary, minHeight: 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${current.toInt()} / ${max.toInt()} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSpending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dépenses récentes', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _spendRow(Icons.restaurant_rounded, 'Restaurant Le Petit', '-32,50 \u20AC', 'Hier', Colors.orange),
        _spendRow(Icons.local_gas_station_rounded, 'Station Total', '-55,00 \u20AC', 'Il y a 2j', Colors.blue),
        _spendRow(Icons.shopping_cart_rounded, 'Amazon', '-89,99 \u20AC', 'Il y a 3j', Colors.amber),
        _spendRow(Icons.coffee_rounded, 'Starbucks', '-5,80 \u20AC', 'Il y a 4j', Colors.brown),
        _spendRow(Icons.local_grocery_store_rounded, 'Carrefour', '-67,30 \u20AC', 'Il y a 5j', Colors.green),
      ],
    );
  }

  Widget _spendRow(IconData icon, String label, String amount, String time, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            Text(time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ])),
          Text(amount, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Code PIN', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
              child: const Text('1 2 3 4', style: TextStyle(color: AppTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, fontFamily: 'monospace')),
            ),
            const SizedBox(height: 16),
            const Text('Votre code PIN actuel', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nouveau PIN généré'), backgroundColor: AppTheme.primary));
            },
            child: const Text('Changer le PIN'),
          ),
        ],
      ),
    );
  }

  void _showLimitsDialog() {
    double tempPayment = _paymentLimit;
    double tempAtm = _atmLimit;
    double tempOnline = _onlineLimit;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: AppTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Modifier les plafonds', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sliderRow('Paiement', tempPayment, 5000, (v) => setDState(() => tempPayment = v)),
              const SizedBox(height: 12),
              _sliderRow('Retrait DAB', tempAtm, 1000, (v) => setDState(() => tempAtm = v)),
              const SizedBox(height: 12),
              _sliderRow('En ligne', tempOnline, 5000, (v) => setDState(() => tempOnline = v)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                setState(() { _paymentLimit = tempPayment; _atmLimit = tempAtm; _onlineLimit = tempOnline; });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plafonds mis à jour'), backgroundColor: AppTheme.primary));
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderRow(String label, double value, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text('${value.toInt()} \u20AC', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        ]),
        Slider(value: value, min: 0, max: max, divisions: (max / 100).toInt(), onChanged: onChanged, activeColor: AppTheme.primary),
      ],
    );
  }
}
