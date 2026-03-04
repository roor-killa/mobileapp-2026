import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bank_provider.dart';
import '../models/account.dart';

class TransferScreen extends StatelessWidget {
  final String? preselectedFromId;
  const TransferScreen({super.key, this.preselectedFromId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau virement')),
      resizeToAvoidBottomInset: true,
      body: TransferBody(preselectedFromId: preselectedFromId),
    );
  }
}

class TransferBody extends StatefulWidget {
  final String? preselectedFromId;
  const TransferBody({super.key, this.preselectedFromId});
  @override
  State<TransferBody> createState() => _TransferBodyState();
}

class _TransferBodyState extends State<TransferBody> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  final _searchCtrl = TextEditingController();

  String? _fromId;
  AccountModel? _toAccount;
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _fromId = widget.preselectedFromId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose(); _noteCtrl.dispose(); _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String q) async {
    if (q.length < 2) {
      setState(() { _searchResults = []; _searching = false; });
      return;
    }
    setState(() => _searching = true);
    final results = await context.read<BankProvider>().searchUsers(q);
    if (mounted) setState(() { _searchResults = results; _searching = false; });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromId == null)    { _err('Sélectionnez un compte source.'); return; }
    if (_toAccount == null) { _err('Sélectionnez un destinataire.'); return; }

    final bank   = context.read<BankProvider>();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final error  = await bank.transfer(
      fromAccountId: _fromId!,
      toAccountId: _toAccount!.id,
      amount: amount,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;
    if (error != null) {
      _err(error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${amount.toStringAsFixed(2)} € envoyé à ${_toAccount!.ownerName} ✓'),
        backgroundColor: Colors.green.shade700,
      ));
      _amountCtrl.clear(); _noteCtrl.clear(); _searchCtrl.clear();
      setState(() { _toAccount = null; _searchResults = []; });
    }
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700));

  @override
  Widget build(BuildContext context) {
    final bank       = context.watch<BankProvider>();
    final myAccounts = bank.accounts;

    if (myAccounts.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Vous n\'avez aucun compte.\nCréez-en un depuis l\'onglet Comptes.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
      ));
    }

    final fromAccount = _fromId != null ? bank.findById(_fromId!) : null;

    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Compte source ──────────────────────────────────────────────
              const _Label('Votre compte source'),
              DropdownButtonFormField<String>(
                initialValue: _fromId,
                hint: const Text('Choisir votre compte'),
                isExpanded: true,
                decoration: const InputDecoration(),
                items: myAccounts.map((acc) => DropdownMenuItem(
                  value: acc.id,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          acc.ownerName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        acc.label,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )).toList(),
                onChanged: (id) => setState(() => _fromId = id),
              ),
              if (fromAccount != null) ...[
                const SizedBox(height: 6),
                Text('Solde disponible : ${fromAccount.balance.toStringAsFixed(2)} €',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],

              const SizedBox(height: 20),

              // ── Recherche destinataire ─────────────────────────────────────
              const _Label('Rechercher le destinataire'),
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Nom, prénom ou email...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : null,
                ),
                onChanged: _doSearch,
              ),

              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: _searchResults.expand((user) {
                      final rawAccounts = List.from(user['accounts'] ?? []);
                      return rawAccounts.map((a) {
                        final acc = AccountModel.fromJson(
                          Map<String, dynamic>.from(a),
                        );
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user['full_name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${acc.accountNumber}  •  ${acc.label}'),
                          trailing: _toAccount?.id == acc.id
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () => setState(() {
                            _toAccount = acc;
                            _searchCtrl.text = '${user['full_name']} — ${acc.accountNumber}';
                            _searchResults = [];
                          }),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ],

              if (_toAccount != null && _searchResults.isEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200)),
                  child: Row(children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_toAccount!.ownerName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(_toAccount!.accountNumber,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ])),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _toAccount = null;
                          _searchCtrl.clear();
                        })),
                  ]),
                ),
              ],

              const SizedBox(height: 20),

              // ── Montant ────────────────────────────────────────────────────
              const _Label('Montant'),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: '0.00', prefixIcon: Icon(Icons.euro)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Montant requis.';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Montant invalide (> 0).';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const _Label('Motif (facultatif)'),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                    hintText: 'Loyer, remboursement...', prefixIcon: Icon(Icons.notes)),
                maxLength: 60,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmer le virement'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );
}