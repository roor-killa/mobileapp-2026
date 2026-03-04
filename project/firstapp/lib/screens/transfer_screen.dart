import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transfer_response.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  // Contrôleur pour le champ de saisie
  final TextEditingController _montantController = TextEditingController();
  
  // Service API
  final ApiService _apiService = ApiService();
  
  // État de l'application
  bool _isLoading = false; // Chargement en cours ?
  TransferResponse? _lastResponse; // Dernière réponse reçue
  double? _soldeActuel; // Solde actuel
  
  @override
  void initState() {
    super.initState();
    _chargerSoldeInitial();
  }
  
  /// Charge le VRAI solde au démarrage depuis PostgreSQL
  Future<void> _chargerSoldeInitial() async {
    // 1. On récupère le badge secret dans le coffre
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // 2. On utilise la fonction getUser que Gemini t'a préparée !
      // Elle envoie le Token à Laravel pour récupérer les infos du client
      final userData = await _apiService.getUser(token);

      // 3. Si Laravel nous répond bien, on met à jour l'écran
      if (userData['solde'] != null) {
        setState(() {
          // On transforme le solde de la base de données en nombre à virgule pour Flutter
          _soldeActuel = double.parse(userData['solde'].toString());
        });
      }
    } else {
      print("Erreur : Aucun token trouvé, l'utilisateur n'est pas connecté.");
    }
  }
      
  /// ÉTAPE 1 : Action déclenchée par le bouton "Transférer"
  Future<void> _effectuerTransfert() async {
    // Validation de la saisie
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

    // Active le loader
    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });
    
    try {
      // ÉTAPES 2-5 : Appel API et récupération du JSON
      final response = await _apiService.transfererMontant(montant);
      
      // ÉTAPE 6 : Mise à jour de l'interface avec les données
      print('✅ ÉTAPE 6 : Affichage des données');
      setState(() {
        _lastResponse = response;
        _soldeActuel = response.nouveauSolde;
        _isLoading = false;
      });
      
      // Vider le champ après succès
      if (response.success) {
        _montantController.clear();
      }
      
    } catch (e) {
      print('❌ Erreur : $e');
      setState(() {
        _isLoading = false;
      });
      _afficherErreur('Erreur lors du transfert');
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
      appBar: AppBar(
        title: const Text('Transfert d\'argent'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Affichage du solde actuel
            _buildSoldeCard(),
            
            const SizedBox(height: 30),
            
            // ÉTAPE 0 : Champ de saisie du montant
            _buildMontantInput(),
            
            const SizedBox(height: 20),
            
            // ÉTAPE 1 : Bouton de transfert
            _buildTransferButton(),
            
            const SizedBox(height: 30),
            
            // ÉTAPE 6 : Affichage du résultat
            if (_lastResponse != null) _buildResultCard(),
            
            // Indicateur de chargement
            if (_isLoading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }
  

 /// Card affichant le solde actuel et le bouton de rechargement
  Widget _buildSoldeCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              _soldeActuel != null 
                  ? '${_soldeActuel!.toStringAsFixed(2)} €'
                  : 'Chargement...',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),
            
            // NOUVEAU : Le bouton pour recharger
            ElevatedButton.icon(
              onPressed: _afficherDialogRechargement,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Recharger par carte', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Vert pour l'ajout d'argent
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Affiche une Pop-up pour simuler un dépôt par carte
  void _afficherDialogRechargement() {
    final TextEditingController _topupController = TextEditingController();
    bool _isToppingUp = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer en cliquant à côté
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
                    decoration: const InputDecoration(
                      labelText: 'Montant à déposer',
                      prefixIcon: Icon(Icons.credit_card),
                      suffixText: '€',
                      border: OutlineInputBorder(),
                    ),
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

                    // On appelle la fonction de l'API !
                    final result = await _apiService.topUp(montant);

                    if (result['success'] == true) {
                      Navigator.pop(context); // On ferme la fenêtre
                      
                      // On met à jour le gros chiffre bleu sur l'écran
                      setState(() {
                        _soldeActuel = double.parse(result['nouveau_solde'].toString());
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
                      );
                    } else {
                      setStateDialog(() => _isToppingUp = false);
                      _afficherErreur(result['message'] ?? 'Erreur lors du rechargement');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isToppingUp 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Valider', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }
  /// ÉTAPE 0 : Champ de saisie du montant
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      style: const TextStyle(fontSize: 20),
    );
  }
  
  /// ÉTAPE 1 : Bouton de transfert
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
        'Transférer',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
  
  /// Indicateur de chargement (étapes 2-5)
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
  
  /// ÉTAPE 6 : Affichage du résultat
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