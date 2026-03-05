import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/wallet_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _address = TextEditingController();
  final _amount = TextEditingController();
  String? _selectedWalletId;

  @override
  void dispose() {
    _address.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Envoyer')),
      body: Consumer<WalletProvider>(
        builder: (context, wp, _) {
          if (wp.wallets.isEmpty) {
            return const Center(child: Text('Aucun portefeuille disponible', style: TextStyle(color: AppTheme.textSecondary)));
          }

          final selected = wp.wallets.firstWhere(
            (w) => w.id == _selectedWalletId,
            orElse: () => wp.wallets.first,
          );
          _selectedWalletId ??= selected.id;

          final price = wp.prices[selected.symbol] ?? 0.0;
          final amt = double.tryParse(_amount.text) ?? 0;
          final eurEquiv = amt * price;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Depuis', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedWalletId,
                      isExpanded: true,
                      dropdownColor: AppTheme.card,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      items: wp.wallets.map((w) {
                        return DropdownMenuItem(
                          value: w.id,
                          child: Row(
                            children: [
                              Text(w.icon, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                              const SizedBox(width: 10),
                              Text('${w.name} (${w.balance.toStringAsFixed(4)} ${w.symbol})'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedWalletId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Adresse du destinataire', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _address,
                  decoration: InputDecoration(
                    hintText: 'Coller l\'adresse ${selected.symbol}',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary),
                      onPressed: () {},
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text('Montant', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppTheme.textSecondary),
                    suffix: Text(selected.symbol, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '\u2248 ${eurEquiv.toStringAsFixed(2)} \u20AC',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['25%', '50%', '75%', 'Max'].map((label) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: OutlinedButton(
                          onPressed: () {
                            final pct = label == 'Max' ? 1.0 : double.parse(label.replaceAll('%', '')) / 100;
                            _amount.text = (selected.balance * pct).toStringAsFixed(6);
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amt = double.tryParse(_amount.text) ?? 0;
                      final addr = _address.text.trim();
                      if (amt <= 0 || addr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplis tous les champs'), backgroundColor: Colors.redAccent));
                        return;
                      }
                      wp.sendCrypto(selected.id, amt, addr);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${amt.toStringAsFixed(4)} ${selected.symbol} envoyé'), backgroundColor: AppTheme.primary),
                      );
                      _amount.clear();
                      _address.clear();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                    child: const Text('Confirmer l\'envoi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
