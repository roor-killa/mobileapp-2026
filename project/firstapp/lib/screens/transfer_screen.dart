import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bank_service.dart';

class TransferScreen extends StatefulWidget {
  final List<Account> accounts;
  final Function? onTransferSuccess;

  const TransferScreen({
    Key? key,
    this.accounts = const [],
    this.onTransferSuccess,
  }) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final BankService _bankService = BankService();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  Account? _selectedFromAccount;
  Account? _selectedToAccount;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _bankService.init();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
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
        _selectedToAccount != null) {
      if (_selectedFromAccount!.id == _selectedToAccount!.id) {
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
          _selectedToAccount!.id,
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
          _selectedToAccount = null;
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
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
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
              DropdownButtonFormField<Account>(
                value: _selectedFromAccount,
                hint: const Text('Sélectionnez un compte'),
                items: widget.accounts
                    .map((account) => DropdownMenuItem(
                          value: account,
                          child: Text(
                              '${account.accountType} - ${account.balance.toStringAsFixed(2)} EUR'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedFromAccount = value);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                validator: (value) =>
                    value == null ? 'Sélectionnez un compte source' : null,
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
              DropdownButtonFormField<Account>(
                value: _selectedToAccount,
                hint: const Text('Sélectionnez un compte'),
                items: widget.accounts
                    .map((account) => DropdownMenuItem(
                          value: account,
                          child:
                              Text('${account.accountType} - ${account.iban}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedToAccount = value);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                validator: (value) =>
                    value == null ? 'Sélectionnez un compte destination' : null,
              ),

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
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey,
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
