import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/tx.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Tx tx;
  const TransactionDetailsScreen({super.key, required this.tx});

  String? get _reference {
    final note = tx.note?.trim();
    if (note == null || note.isEmpty) return null;
    return note;
  }

  String? get _externalUrl {
    final note = tx.note?.trim();
    if (note == null || note.isEmpty) return null;
    if (note.startsWith('http://') || note.startsWith('https://')) return note;
    if (note.startsWith('stripe:')) {
      final ref = Uri.encodeComponent(note.substring('stripe:'.length));
      return 'https://dashboard.stripe.com/test/payments?search=$ref';
    }
    return null;
  }

  IconData get _icon {
    if (tx.status != 'OK') return Icons.error_outline_rounded;
    switch (tx.type) {
      case 'BUY':
        return Icons.shopping_bag_outlined;
      case 'SELL':
        return Icons.south_west_rounded;
      case 'TRANSFER_IN':
        return Icons.call_received_rounded;
      case 'TRANSFER_OUT':
        return Icons.call_made_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copié')),
    );
  }

  Future<void> _openExternal(BuildContext context) async {
    final url = _externalUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le lien")),
      );
    }
  }

  Widget _sectionCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }

  Widget _row(BuildContext context, {
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (copyable)
                  TextButton.icon(
                    onPressed: () => _copy(context, label, value),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copier'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = _reference;
    final url = _externalUrl;
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de transaction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            context,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Icon(_icon, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  tx.displayType,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  tx.signedAmount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: tx.status != 'OK'
                            ? Theme.of(context).colorScheme.error
                            : tx.isDebit
                                ? Colors.red.shade400
                                : Colors.green.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(tx.status == 'OK' ? 'Confirmée' : 'Échec / attente'),
                  avatar: Icon(
                    tx.status == 'OK' ? Icons.check_circle : Icons.info_outline,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            child: Column(
              children: [
                _row(context, label: 'Type', value: tx.displayType),
                const Divider(height: 1),
                _row(context, label: 'Montant', value: tx.signedAmount),
                const Divider(height: 1),
                _row(context, label: 'Statut', value: tx.status),
                const Divider(height: 1),
                _row(context, label: 'Date', value: tx.createdAt),
                const Divider(height: 1),
                _row(context, label: 'ID', value: tx.id.toString(), copyable: true),
                if (tx.counterparty != null && tx.counterparty!.trim().isNotEmpty) ...[
                  const Divider(height: 1),
                  _row(
                    context,
                    label: 'Contrepartie',
                    value: tx.counterparty!,
                    copyable: true,
                  ),
                ],
                if (ref != null) ...[
                  const Divider(height: 1),
                  _row(context, label: 'Référence', value: ref, copyable: true),
                ],
              ],
            ),
          ),
          if (url != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openExternal(context),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Ouvrir le lien associé'),
            ),
          ],
        ],
      ),
    );
  }
}
