import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transfer_response.dart';
import '../models/utilisateur.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'releve_compte_screen.dart';
import 'login_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _montantController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  TransferResponse? _lastResponse;

  Utilisateur get _user => AuthService.utilisateurConnecte!;

  @override
  void initState() {
    super.initState();
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

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      final response = await _apiService.transfererMontant(montant, _user);

      if (!mounted) return;
      setState(() {
        _lastResponse = response;
        _isLoading = false;
      });

      if (response.success) {
        _montantController.clear();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du transfert');
    }
  }

  void _deconnecter() {
    AuthService().deconnecter();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, ${_user.nom.split(' ').first}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Relevé de compte',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReleveCompteScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _deconnecter,
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
            _buildMontantInput(),
            const SizedBox(height: 20),
            _buildTransferButton(),
            const SizedBox(height: 30),
            if (_lastResponse != null) _buildResultCard(),
            if (_isLoading) _buildLoadingIndicator(),
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
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              '${_user.soldeActuel.toStringAsFixed(2)} €',
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

  Widget _buildMontantInput() {
    return TextField(
      controller: _montantController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Montant à transférer',
        hintText: 'Ex: 50.00',
        prefixIcon: const Icon(Icons.euro),
        suffixText: '€',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget _buildTransferButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _effectuerTransfert,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Transférer',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text('Traitement en cours...', style: TextStyle(color: Colors.grey)),
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
              _buildDetailRow('Solde initial', '${response.montantTotal.toStringAsFixed(2)} €'),
              _buildDetailRow('Montant transféré', '- ${response.montantTransfere.toStringAsFixed(2)} €'),
              _buildDetailRow('Nouveau solde', '${response.nouveauSolde.toStringAsFixed(2)} €', isBold: true),
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

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }
}
