import 'dart:math';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'result_screen.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final api = SupabaseService();
  final amountCtrl = TextEditingController(text: '200');
  bool loading = false;

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _sell() async {
    final amount = double.tryParse(amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    setState(() => loading = true);
    try {
      final ok = Random().nextInt(10) >= 2; // 80% OK (also checks balance server-side)
      await api.sellSimulated(amountBkn: amount, success: ok);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            ok: ok,
            title: ok ? 'Merci ✅' : 'Problème',
            message: ok ? 'Transaction OK — Vente validée.' : 'Transaction NOK — Solde insuffisant ou échec.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
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
      appBar: AppBar(title: const Text('Vendre des BKN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Vendre (BKN)', hintText: 'Ex: 200'),
            ),
            const SizedBox(height: 10),
            const Text('Tarif: 1 BKN = 1€', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: loading ? null : _sell,
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Valider'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
