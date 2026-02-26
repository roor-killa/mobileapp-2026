import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientController = TextEditingController();
  final _montantController   = TextEditingController();
  final _apiService          = ApiService();

  bool _isLoading       = false;
  bool? _lastSuccess;
  String _lastMessage   = '';
  double? _nouveauSolde;

  Future<void> _confirmerEtTransferer() async {
    final email = _recipientController.text.trim();
    final montantText = _montantController.text.trim();

    if (email.isEmpty) {
      _afficherErreur('Veuillez entrer l\'email du destinataire');
      return;
    }

    final montant = double.tryParse(montantText);
    if (montant == null || montant <= 0) {
      _afficherErreur('Montant invalide');
      return;
    }

    // Popup de confirmation
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.send, color: Colors.blue),
            SizedBox(width: 8),
            Text('Confirmer le transfert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vous êtes sur le point d\'envoyer :'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Destinataire', style: TextStyle(color: Colors.black54)),
                      Flexible(
                        child: Text(
                          email,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant', style: TextStyle(color: Colors.black54)),
                      Text(
                        '${montant.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    await _effectuerTransfert(email, montant);
  }

  Future<void> _effectuerTransfert(String email, double montant) async {
    setState(() {
      _isLoading   = true;
      _lastSuccess = null;
    });

    try {
      final result = await _apiService.transfer(email, montant);


      setState(() {
        _lastSuccess  = result['success'] == true;
        _lastMessage  = result['message'] ?? '';
        _nouveauSolde = result['nouveau_solde'] != null
            ? (result['nouveau_solde'] as num).toDouble()
            : null;
        _isLoading    = false;
      });

      if (_lastSuccess == true) {
        _montantController.clear();
        _recipientController.clear();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur de connexion');
    }
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
        title: const Text('Transfert d\'argent'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ email destinataire
            TextField(
              controller: _recipientController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email du destinataire',
                hintText: 'ex: bob@exemple.com',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 16),

            // Champ montant
            TextField(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            // Bouton de transfert
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmerEtTransferer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Transférer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Indicateur de chargement
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Traitement en cours...', style: TextStyle(color: Colors.grey)),
                ],
              ),

            // Résultat
            if (_lastSuccess != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      color: _lastSuccess! ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _lastSuccess! ? Icons.check_circle : Icons.error,
                  color: _lastSuccess! ? Colors.green : Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _lastMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _lastSuccess! ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (_lastSuccess! && _nouveauSolde != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nouveau solde', style: TextStyle(fontSize: 16)),
                  Text(
                    '${_nouveauSolde!.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _montantController.dispose();
    super.dispose();
  }
}
