import 'package:flutter/material.dart';

import '../config.dart';
import '../services/blockchain_service.dart';
import '../services/notification_service.dart';
import 'result_screen.dart';

class CryptoTransferScreen extends StatefulWidget {
  const CryptoTransferScreen({super.key});

  @override
  State<CryptoTransferScreen> createState() => _CryptoTransferScreenState();
}

class _CryptoTransferScreenState extends State<CryptoTransferScreen> {
  final _service = const BlockchainService();
  final _walletCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _privateKeyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _walletCtrl.dispose();
    _amountCtrl.dispose();
    _privateKeyCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_sending) return;

    final wallet = _walletCtrl.text.trim();
    final pk = _privateKeyCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));

    if (!_service.isConfigured) {
      _snack('Configuration blockchain manquante. Renseigne EVM_RPC_URL et BKN_TOKEN_ADDRESS.');
      return;
    }
    if (BlockchainService.evmBackendBaseUrl.isEmpty) {
      _snack('EVM_BACKEND_BASE_URL manquant côté mobile.');
      return;
    }
    if (!wallet.startsWith('0x') || wallet.length < 40) {
      _snack('Adresse wallet invalide.');
      return;
    }
    if (!pk.startsWith('0x') || pk.length < 60) {
      _snack('Clé privée invalide.');
      return;
    }
    if (amount == null || amount <= 0) {
      _snack('Montant invalide.');
      return;
    }

    setState(() => _sending = true);

    try {
      final txHash = await _service.transferErc20ViaBackend(
        fromPrivateKey: pk,
        toWallet: wallet,
        amount: amount,
      );
      await NotificationService.instance.add(
        title: 'Transfert on-chain envoyé',
        message: '${amount.toStringAsFixed(2)} BKN ont été envoyés sur ${AppConfig.evmChain}.',
        type: 'outgoing',
        meta: {'kind': 'crypto_transfer', 'amount': amount, 'txHash': txHash},
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            ok: true,
            title: 'Transfert crypto envoyé ✅',
            message: "Transaction soumise sur ${AppConfig.evmChain}.\n\nTx hash:\n$txHash",
          ),
        ),
      );
    } catch (e) {
      await NotificationService.instance.add(
        title: 'Échec du transfert on-chain',
        message: "Le transfert blockchain n'a pas été confirmé. ${e.toString()}",
        type: 'error',
        meta: {'kind': 'crypto_transfer_error'},
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            ok: false,
            title: 'Erreur blockchain',
            message: e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _infoCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C2B45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                SelectableText(value, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configured = _service.isConfigured && BlockchainService.evmBackendBaseUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfert crypto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.22),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.10),
                ],
              ),
              border: Border.all(color: const Color(0xFF1C2B45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_bitcoin_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        configured ? 'On-chain prêt' : 'Configuration incomplète',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Cette page envoie un vrai transfert ERC-20 BKN via le backend EVM de démo.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _infoCard(icon: Icons.hub_outlined, title: 'Réseau', value: AppConfig.evmChain),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.token_outlined,
            title: 'Token BKN',
            value: AppConfig.bknTokenAddress.isEmpty ? 'À configurer' : AppConfig.bknTokenAddress,
          ),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.language,
            title: 'Backend EVM',
            value: BlockchainService.evmBackendBaseUrl.isEmpty ? 'À configurer' : BlockchainService.evmBackendBaseUrl,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _walletCtrl,
            decoration: const InputDecoration(labelText: 'Adresse wallet du destinataire', hintText: '0x...'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Montant BKN à envoyer', hintText: '2.5'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _privateKeyCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Clé privée expéditeur (démo testnet)', hintText: '0x...'),
          ),
          const SizedBox(height: 8),
          const Text('Démo uniquement: ne mets jamais une vraie clé mainnet ici.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _sending ? null : _submit,
              icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded),
              label: Text(_sending ? 'Envoi...' : 'Envoyer on-chain'),
            ),
          ),
        ],
      ),
    );
  }
}
