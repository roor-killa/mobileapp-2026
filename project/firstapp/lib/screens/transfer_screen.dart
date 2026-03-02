import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bank_service.dart';

class TransferScreen extends StatefulWidget {
  final List<Account> accounts;
  final Function? onTransferSuccess;

  const TransferScreen({
    super.key,
    this.accounts = const [],
    this.onTransferSuccess,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final BankService _bankService = BankService();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  Account? _selectedFromAccount;
  _Destination? _selectedDestination;
  List<_Destination> _destinations = const [];
  bool _loadingDestinations = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _init();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  Future<void> _init() async {
    await _bankService.init();
    await _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _loadingDestinations = true;
    });
    try {
      final beneficiaries = await _bankService.getBeneficiaries();

      final own = widget.accounts
          .map(
            (a) => _Destination(
              id: a.id,
              label: a.accountType,
              subtitle: a.iban,
              isOwn: true,
            ),
          )
          .toList();

      final others = beneficiaries
          .map(
            (b) => _Destination(
              id: b.id,
              label: b.ownerName,
              subtitle: '${b.accountType} • ${b.iban}',
              isOwn: false,
            ),
          )
          .toList();

      setState(() {
        _destinations = [...own, ...others];
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loadingDestinations = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _performTransfer() async {
    if (_formKey.currentState!.validate() &&
        _selectedFromAccount != null &&
        _selectedDestination != null) {
      if (_selectedFromAccount!.id == _selectedDestination!.id) {
        setState(() {
          _errorMessage = 'Veuillez sélectionner deux comptes différents';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _bankService.transfer(
          _selectedFromAccount!.id,
          _selectedDestination!.id,
          double.parse(_amountController.text),
          _descriptionController.text.isEmpty
              ? 'Virement bancaire'
              : _descriptionController.text,
        );

        setState(() {
          _showSuccessMessage = true;
          _amountController.clear();
          _descriptionController.clear();
          _selectedFromAccount = null;
          _selectedDestination = null;
        });

        // Appeler la fonction de succès si fournie
        if (widget.onTransferSuccess != null) {
          await widget.onTransferSuccess!();
        }

        // Afficher le message de succès pendant 2 secondes, puis revenir
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effectuer un virement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Message de succès
              if (_showSuccessMessage)
                Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'Virement effectué avec succès!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Message d'erreur
              if (_errorMessage != null && !_showSuccessMessage)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),

              // Compte source
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Compte source',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              DropdownMenu<Account>(
                initialSelection: _selectedFromAccount,
                hintText: 'Sélectionnez un compte',
                expandedInsets: EdgeInsets.zero,
                onSelected: (value) {
                  setState(() {
                    _selectedFromAccount = value;
                    if (_selectedDestination != null && value != null && _selectedDestination!.id == value.id) {
                      _selectedDestination = null;
                    }
                  });
                },
                dropdownMenuEntries: widget.accounts
                    .map(
                      (account) => DropdownMenuEntry(
                        value: account,
                        label: '${account.accountType} • ${account.balance.toStringAsFixed(2)} EUR',
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Compte destination
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Compte destination',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              if (_loadingDestinations)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: LinearProgressIndicator(),
                )
              else
                DropdownMenu<_Destination>(
                  initialSelection: _selectedDestination,
                  hintText: 'Sélectionnez un bénéficiaire',
                  expandedInsets: EdgeInsets.zero,
                  onSelected: (value) => setState(() => _selectedDestination = value),
                  dropdownMenuEntries: _destinations
                      .where((d) => _selectedFromAccount == null || d.id != _selectedFromAccount!.id)
                      .map(
                        (d) => DropdownMenuEntry(
                          value: d,
                          label: d.isOwn ? '${d.label} (mes comptes)' : d.label,
                        ),
                      )
                      .toList(),
                ),

              if (_selectedDestination != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _selectedDestination!.subtitle,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Montant
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Montant (EUR)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '€ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un montant';
                  }
                  try {
                    final amount = double.parse(value!);
                    if (amount <= 0) {
                      return 'Le montant doit être supérieur à 0';
                    }
                    if (_selectedFromAccount != null &&
                        amount > _selectedFromAccount!.balance) {
                      return 'Solde insuffisant';
                    }
                  } catch (e) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Description (optionnel)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex: Loyer du mois de février',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 30),

              // Bouton de confirmation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _performTransfer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: scheme.primary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirmer le virement',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination {
  final int id;
  final String label;
  final String subtitle;
  final bool isOwn;

  const _Destination({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.isOwn,
  });
}
