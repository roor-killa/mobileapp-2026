import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import 'result_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final api = SupabaseService();
  final amountCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  bool loading = false;
  String? toUserId;

  @override
  void dispose() {
    amountCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<String?>(MaterialPageRoute(builder: (_) => const _QrScanPage()));
    if (result == null) return;
    final uri = Uri.tryParse(result);
    final id = uri != null && uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;

    if (id == null || id.length < 10) {
      _snack('QR invalide');
      return;
    }

    setState(() => toUserId = id);
    _snack('Destinataire détecté via QR ✅');
  }

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _transfer() async {
    if (loading) return;
    final amount = double.tryParse(amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _snack('Montant invalide');
      return;
    }

    setState(() => loading = true);

    try {
      String? receiver = toUserId;
      String targetLabel = 'destinataire';

      if (receiver == null) {
        final email = emailCtrl.text.trim().toLowerCase();
        if (email.isEmpty) {
          _snack('Scan QR ou saisie email obligatoire');
          return;
        }

        receiver = await api.userIdByEmail(email);
        if (receiver == null || receiver.isEmpty) {
          _snack('Utilisateur introuvable');
          return;
        }
        targetLabel = email;
      } else {
        targetLabel = receiver;
      }

      final res = await api.transferToUserId(toUserId: receiver, amount: amount);
      final ok = (res['success'] == true) || (res['ok'] == true);
      final msg = (res['message'] ?? (ok ? 'OK' : 'Échec')).toString();

      if (ok) {
        await NotificationService.instance.add(
          title: 'Transfert envoyé',
          message: '${amount.toStringAsFixed(2)} BKN ont été envoyés à $targetLabel.',
          type: 'outgoing',
          meta: {'kind': 'transfer_out', 'amount': amount, 'to': targetLabel},
        );
      } else {
        await NotificationService.instance.add(
          title: 'Transfert refusé',
          message: "Le transfert de ${amount.toStringAsFixed(2)} BKN n'a pas abouti. $msg",
          type: 'error',
          meta: {'kind': 'transfer_error', 'amount': amount},
        );
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            ok: ok,
            title: ok ? 'Merci ✅' : 'Problème',
            message: msg,
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      await NotificationService.instance.add(
        title: 'Erreur de transfert',
        message: "Une erreur est survenue pendant l'envoi. ${e.toString()}",
        type: 'error',
        meta: {'kind': 'transfer_exception'},
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(ok: false, title: 'Erreur', message: e.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transférer des BKN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Montant à transférer (BKN)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Utilisateur (email) (optionnel si QR)'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : _scanQr,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scanner QR'),
                  ),
                ),
              ],
            ),
            if (toUserId != null) ...[
              const SizedBox(height: 8),
              Text('Destinataire: $toUserId', style: const TextStyle(color: Colors.white70)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: loading ? null : _transfer,
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Valider'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrScanPage extends StatelessWidget {
  const _QrScanPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(
        onDetect: (capture) {
          final code = capture.barcodes.firstOrNull?.rawValue;
          if (code != null && code.isNotEmpty) {
            Navigator.of(context).pop(code);
          }
        },
      ),
    );
  }
}
