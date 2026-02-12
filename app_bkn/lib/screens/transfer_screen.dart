import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinataireController = TextEditingController();
  final _montantController = TextEditingController();
  
  double soldeDisponible = 1500.0;

  @override
  void dispose() {
    _destinataireController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transférer des BKN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte solde
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Solde disponible',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${soldeDisponible.toStringAsFixed(0)} BKN',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2472),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Destinataire
              const Text(
                'Destinataire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2472),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _destinataireController,
                decoration: InputDecoration(
                  hintText: 'Email, téléphone ou @pseudo',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Destinataire requis';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Montant
              const Text(
                'Montant en BKN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2472),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: const Icon(Icons.money),
                  suffixText: 'BKN',
                  suffixStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Montant requis';
                  }
                  final montant = double.tryParse(value);
                  if (montant == null) {
                    return 'Montant invalide';
                  }
                  if (montant <= 0) {
                    return 'Montant doit être positif';
                  }
                  if (montant > soldeDisponible) {
                    return 'Solde insuffisant';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 8),
              Text(
                '≈ ${_montantController.text.isEmpty ? '0' : _montantController.text} €',
                style: const TextStyle(color: Colors.grey),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton transférer
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D96FF),
                  ),
                  child: const Text(
                    'TRANSFÉRER',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTransfer() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer le transfert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Destinataire: ${_destinataireController.text}'),
              const SizedBox(height: 8),
              Text('Montant: ${_montantController.text} BKN'),
              Text('≈ ${_montantController.text} €'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transfert effectué avec succès'),
                    backgroundColor: Color(0xFF00C9A7),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
    }
  }
}