import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/transfer_response.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  double? _soldeActuel;
  bool _isLoading = false;
  TransferResponse? _lastResponse;

  @override
  void initState() {
    super.initState();
    _chargerSoldeInitial();
  }

  Future<void> _chargerSoldeInitial() async {
    // 1. AFFICHAGE INSTANTANÉ (Mémoire du téléphone)
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soldeActuel = prefs.getDouble('solde') ?? 0.00;
    });

    // 2. VÉRIFICATION SILENCIEUSE EN ARRIÈRE-PLAN (La magie Revolut !)
    final vraiSolde = await _apiService.getLiveBalance();
    
    // Si Laravel a répondu et que le solde est différent
    if (vraiSolde != null && vraiSolde != _soldeActuel) {
      setState(() {
        _soldeActuel = vraiSolde; // On met à jour le chiffre à l'écran
      });
      // On sauvegarde ce nouveau solde tout frais dans le coffre-fort
      await prefs.setDouble('solde', vraiSolde); 
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _afficherDialogRechargement() {
    final TextEditingController _topupController = TextEditingController();
    bool _isToppingUp = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Recharger le compte'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Simulez un dépôt par carte bancaire. Minimum 5 €.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _topupController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Montant à déposer', prefixIcon: Icon(Icons.credit_card), suffixText: '€', border: OutlineInputBorder()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isToppingUp ? null : () => Navigator.pop(context),
                  child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: _isToppingUp ? null : () async {
                    final montant = double.tryParse(_topupController.text.trim());
                    if (montant == null || montant < 5.0) {
                      _afficherErreur("Veuillez entrer au moins 5 €");
                      return;
                    }
                    setStateDialog(() => _isToppingUp = true);
                    final result = await _apiService.topUp(montant);

                    if (result['success'] == true) {
                      Navigator.pop(context);
                      setState(() => _soldeActuel = double.parse(result['nouveau_solde'].toString()));
                      
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble('solde', _soldeActuel!); // Mise à jour locale

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.green));
                    } else {
                      setStateDialog(() => _isToppingUp = false);
                      _afficherErreur(result['message'] ?? 'Erreur lors du rechargement');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isToppingUp ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Valider', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _effectuerTransfert() async {
    final montantText = _montantController.text.trim();
    final emailText = _emailController.text.trim();

    if (emailText.isEmpty) {
      _afficherErreur("Veuillez entrer l'email du destinataire");
      return;
    }
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
      final response = await _apiService.transfererMontant(emailText, montant); 
      
      setState(() {
        _lastResponse = response;
        if (response.success) {
          _soldeActuel = response.nouveauSolde;
          _montantController.clear();
          _emailController.clear();
          SharedPreferences.getInstance().then((prefs) => prefs.setDouble('solde', _soldeActuel!));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Une erreur est survenue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // L'AppBar et la fonction _logout ont été supprimés !
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSoldeCard(),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email du destinataire', prefixIcon: const Icon(Icons.alternate_email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _montantController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Montant à transférer', prefixIcon: const Icon(Icons.euro), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _effectuerTransfert,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Transférer', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
            if (_lastResponse != null) ...[
              const SizedBox(height: 30),
              _buildResultCard(_lastResponse!),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSoldeCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Solde disponible', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 10),
            Text(_soldeActuel != null ? '${_soldeActuel!.toStringAsFixed(2)} €' : 'Chargement...', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _afficherDialogRechargement,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Recharger par carte', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(TransferResponse response) {
    final bool success = response.success;
    return Card(
      color: success ? Colors.green.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: success ? Colors.green.shade200 : Colors.red.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(success ? Icons.check_circle : Icons.error, color: success ? Colors.green : Colors.red),
                const SizedBox(width: 10),
                Expanded(child: Text(response.message, style: TextStyle(color: success ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold))),
              ],
            ),
            if (success) ...[
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Montant transféré'), Text('- ${response.montantTransfere.toStringAsFixed(2)} €')]),
              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Nouveau solde', style: TextStyle(fontWeight: FontWeight.bold)), Text('${response.nouveauSolde.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
            ]
          ],
        ),
      ),
    );
  }
}