import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transfer_response.dart';
import '../models/user.dart';
import '../models/transfer.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TransferScreen extends StatefulWidget {
  final Function() onLogout;

  const TransferScreen({super.key, required this.onLogout});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _isLoadingUsers = true;
  TransferResponse? _lastResponse;
  double? _soldeActuel;
  List<User> _availableUsers = [];
  User? _selectedUser;
  List<Transfer> _transferHistory = [];
  
  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }
  
  Future<void> _chargerDonnees() async {
    await Future.wait([
      _chargerSoldeInitial(),
      _chargerUtilisateurs(),
      _chargerHistorique(),
    ]);
  }
  
  Future<void> _chargerSoldeInitial() async {
    final solde = await _apiService.getSoldeActuel();
    setState(() {
      _soldeActuel = solde;
    });
  }
  
  Future<void> _chargerUtilisateurs() async {
    final users = await _apiService.getAvailableUsers();
    setState(() {
      _availableUsers = users;
      _isLoadingUsers = false;
      if (users.isNotEmpty) {
        _selectedUser = users.first;
      }
    });
  }
  
  Future<void> _chargerHistorique() async {
    final history = await _apiService.getTransferHistory();
    setState(() {
      _transferHistory = history;
    });
  }
  
  Future<void> _effectuerTransfert() async {
    final montantText = _montantController.text.trim();
    if (montantText.isEmpty) {
      _afficherErreur('Veuillez entrer un montant');
      return;
    }
    
    final montant = double.tryParse(montantText);
    if (montant == null || montant <= 0) {
      _afficherErreur('Montant invalide');
      return;
    }

    if (_selectedUser == null) {
      _afficherErreur('Veuillez selectionner un destinataire');
      return;
    }

    if (_soldeActuel! < montant) {
      _afficherErreur('Solde insuffisant');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });
    
    try {
      final response = await _apiService.transfererMontant(
        montant,
        _selectedUser!.id,
        _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );
      
      setState(() {
        _lastResponse = response;
        if (response.success) {
          _soldeActuel = response.nouveauSolde;
          _montantController.clear();
          _descriptionController.clear();
        }
        _isLoading = false;
      });

      if (response.success) {
        await _chargerHistorique();
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _afficherErreur('Erreur lors du transfert');
    }
  }
  
  Future<void> _handleLogout() async {
    await AuthService().logout();
    widget.onLogout();
  }
  
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert d\'argent'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se deconnecter',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Deconnexion'),
                    content: const Text('Etes-vous sur de vouloir vous deconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                        child: const Text('Deconnecter'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSoldeCard(),
            const SizedBox(height: 30),
            _buildDestinatairesSection(),
            const SizedBox(height: 20),
            _buildMontantInput(),
            const SizedBox(height: 20),
            _buildDescriptionInput(),
            const SizedBox(height: 20),
            _buildTransferButton(),
            const SizedBox(height: 30),
            if (_lastResponse != null) _buildResultCard(),
            if (_isLoading) _buildLoadingIndicator(),
            const SizedBox(height: 30),
            if (_transferHistory.isNotEmpty) _buildHistoriqueSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSoldeCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Solde disponible',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _soldeActuel != null 
                  ? '${_soldeActuel!.toStringAsFixed(2)} EUR'
                  : 'Chargement...',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDestinatairesSection() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableUsers.isEmpty) {
      return const Card(
        color: Colors.orange,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucun utilisateur disponible',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Destinataire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButton<User>(
          isExpanded: true,
          value: _selectedUser,
          items: _availableUsers.map((User user) {
            return DropdownMenuItem<User>(
              value: user,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user.name),
                  Text(
                    '${user.balance.toStringAsFixed(2)} EUR',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (User? newValue) {
            setState(() {
              _selectedUser = newValue;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildMontantInput() {
    return TextField(
      controller: _montantController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Montant a transferer',
        hintText: 'Ex: 50.00',
        prefixIcon: const Icon(Icons.euro),
        suffixText: 'EUR',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      style: const TextStyle(fontSize: 20),
    );
  }
  
  Widget _buildDescriptionInput() {
    return TextField(
      controller: _descriptionController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Description (optionnel)',
        hintText: 'Ex: Remboursement...',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
  
  Widget _buildTransferButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _effectuerTransfert,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Transferer',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(
          'Traitement en cours...',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
  
  Widget _buildResultCard() {
    final response = _lastResponse!;
    final isSuccess = response.success;
    
    return Card(
      elevation: 4,
      color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    response.message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (isSuccess) ...[
              const Divider(height: 30),
              _buildDetailRow('Ancien solde', '${(response.montantTotal).toStringAsFixed(2)} EUR'),
              _buildDetailRow('Montant transfére', '- ${response.montantTransfere.toStringAsFixed(2)} EUR'),
              _buildDetailRow('Nouveau solde', '${response.nouveauSolde.toStringAsFixed(2)} EUR', isBold: true),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isBold ? Colors.blue : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoriqueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique des transferts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _transferHistory.length,
          itemBuilder: (context, index) {
            final transfer = _transferHistory[index];
            final isOutgoing = transfer.fromUserId == ApiService.currentUserId;
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOutgoing ? 'Envoye a' : 'Recu de',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            isOutgoing 
                              ? (transfer.toUserId.toString())
                              : (transfer.fromUserId.toString()),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isOutgoing
                            ? '- ${transfer.amount.toStringAsFixed(2)} EUR'
                            : '+ ${transfer.amount.toStringAsFixed(2)} EUR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isOutgoing ? Colors.red : Colors.green,
                          ),
                        ),
                        Text(
                          transfer.createdAt.toString().substring(0, 16),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
