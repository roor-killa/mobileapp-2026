import 'package:flutter/material.dart';

import '../services/bank_service.dart';

class CreateAccountScreen extends StatefulWidget {
  final VoidCallback? onAccountCreated;

  const CreateAccountScreen({super.key, this.onAccountCreated});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final BankService _bankService = BankService();
  bool _loading = false;
  String? _error;

  static const List<String> _accountTypes = [
    "Compte d'Épargne",
    'Compte Titre',
    'Compte Chèques',
  ];

  Future<void> _createAccount(String accountType) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _bankService.createAccount(accountType);
      if (!mounted) return;
      widget.onAccountCreated?.call();
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau compte'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choisissez le type de compte à ouvrir :',
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: TextStyle(color: scheme.onErrorContainer)),
            ),
          ],
          ..._accountTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  title: Text(type),
                  trailing: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_circle_outline),
                  onTap: _loading ? null : () => _createAccount(type),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
