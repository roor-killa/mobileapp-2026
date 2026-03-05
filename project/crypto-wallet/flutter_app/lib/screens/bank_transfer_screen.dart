import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/wallet_provider.dart';

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({super.key});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _ibanController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  static const _myIban = 'FR76 3000 6000 0112 3456 7890 189';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _ibanController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virement'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Envoyer'),
            Tab(text: 'Recevoir'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildSendTab(),
          _buildReceiveTab(),
        ],
      ),
    );
  }

  Widget _buildSendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.account_balance_rounded, color: AppTheme.primary, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compte NodEX', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                      Text('Solde : 2 500,00 \u20AC', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Bénéficiaire', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nom du bénéficiaire',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          const Text('IBAN', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _ibanController,
            decoration: const InputDecoration(
              hintText: 'FR76 XXXX XXXX XXXX XXXX XXXX XXX',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.account_balance_outlined, color: AppTheme.textSecondary),
            ),
            style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 16),
          const Text('Montant', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '0,00',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.euro_rounded, color: AppTheme.textSecondary),
              suffix: Text('\u20AC', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final amt = double.tryParse(_amountController.text) ?? 0;
                if (amt <= 0 || _ibanController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplis tous les champs'), backgroundColor: Colors.redAccent));
                  return;
                }
                context.read<WalletProvider>().bankSend(_nameController.text.trim(), _ibanController.text.trim(), amt);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Virement de ${amt.toStringAsFixed(2)} \u20AC envoyé'), backgroundColor: AppTheme.primary),
                );
                _amountController.clear();
                _ibanController.clear();
                _nameController.clear();
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Envoyer le virement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppTheme.primary, size: 40),
                const SizedBox(height: 16),
                const Text('Votre IBAN NodEX', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(_myIban, style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: _myIban));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('IBAN copié'), backgroundColor: AppTheme.primary),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('BIC : NODXFRPP', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(14)),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Partagez cet IBAN pour recevoir des virements SEPA en euros. Délai : 1-2 jours ouvrés.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: _myIban));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IBAN copié'), backgroundColor: AppTheme.primary),
                );
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Partager mon IBAN'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
