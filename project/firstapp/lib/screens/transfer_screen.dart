import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_scanner_screen.dart'; // QR Scanner
import 'recharger_screen.dart'; // Nouveau écran pour Stripe

class TransferScreen extends StatefulWidget {
  final String token;
  final int currentUserId;

  const TransferScreen({
    super.key,
    required this.token,
    required this.currentUserId,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _idRecepteurController = TextEditingController();
  late final ApiService _apiService;

  bool _isLoading = false;
  double? _soldeActuel;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(token: widget.token);
    _chargerSoldeInitial();
  }

  Future<void> _chargerSoldeInitial() async {
    final solde = await _apiService.getSoldeActuel();
    setState(() {
      _soldeActuel = solde;
    });
  }

  void _onBoutonPressed() {
    final montant = double.tryParse(_montantController.text.trim());
    final idRecepteur = int.tryParse(_idRecepteurController.text.trim());

    if (montant == null || montant <= 0) {
      return _afficherErreur('Montant invalide');
    }

    if (idRecepteur != null && idRecepteur > 0) {
      _effectuerTransfert(montant, idRecepteur);
    } else {
      _afficherErreur('ID destinataire invalide');
    }
  }

  Future<void> _effectuerTransfert(double montant, int idRecepteur) async {
    setState(() => _isLoading = true);
    try {
      final reponse = await _apiService.transfererVersUtilisateur(montant, idRecepteur);
      if (reponse.success) {
        setState(() {
          _soldeActuel = reponse.nouveauSolde;
        });
        _montantController.clear();
        _idRecepteurController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfert réussi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _afficherErreur(reponse.message);
      }
    } catch (e) {
      _afficherErreur('Erreur lors du transfert');
    } finally {
      setState(() => _isLoading = false);
    }
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Transfert / Rechargement'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Solde disponible'),
                    const SizedBox(height: 10),
                    Text(
                      _soldeActuel?.toStringAsFixed(2) ?? 'Chargement...',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Mon QR Code (pour recevoir)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Center(
              child: QrImageView(
                data: '{"user_id": ${widget.currentUserId}}',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _montantController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _idRecepteurController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID destinataire',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Bouton scanner QR
            ElevatedButton(
              onPressed: () async {
                final scannedUserId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrScannerScreen(),
                  ),
                );
                if (scannedUserId != null) {
                  _idRecepteurController.text = scannedUserId.toString();
                }
              },
              child: const Text('Scanner QR'),
            ),

            const SizedBox(height: 20),

            // 🔹 Nouveau bouton Recharger mon compte
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RechargerScreen(
                      userId: widget.currentUserId,
                      token: widget.token,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Recharger mon compte'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _isLoading ? null : _onBoutonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Transférer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montantController.dispose();
    _idRecepteurController.dispose();
    super.dispose();
  }
}