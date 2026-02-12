import 'package:flutter/material.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Valeurs par défaut
  double _amount = 300.0;
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acheter des BKN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte montant
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Achat',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_amount.toStringAsFixed(0)} BKN',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2472),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tarif : ${_amount.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C9A7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Titre CB
              const Text(
                'Numéro CB',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2472),
                ),
              ),
              const SizedBox(height: 8),

              // Champ CB avec 444 prefix (comme storyboard)
              TextFormField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                initialValue: null,
                decoration: InputDecoration(
                  hintText: '444 1234 5678 9012',
                  prefixIcon: const Icon(Icons.credit_card),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  // Auto-formatage CB
                  if (value.isEmpty) {
                    _cardController.text = '444 ';
                    _cardController.selection = TextSelection.collapsed(offset: 4);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Date d'expiration
              TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: '05/28',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bouton Valider
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implémenter Stripe/Offline/QR
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Méthode de paiement'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.payment, color: Color(0xFF0A2472)),
                              title: const Text('Stripe'),
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Paiement Stripe...')),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.offline_bolt, color: Color(0xFF0A2472)),
                              title: const Text('Offline'),
                              onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                              leading: const Icon(Icons.qr_code, color: Color(0xFF0A2472)),
                              title: const Text('QR Code'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/scan');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'VALIDER',
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
}