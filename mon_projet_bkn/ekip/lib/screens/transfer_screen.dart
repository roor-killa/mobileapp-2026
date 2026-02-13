import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transfer_response.dart';
import '../services/api_service.dart';

class TransferScreen extends StatefulWidget {
  // On ajoute ces variables pour savoir "qui" est connecté
  final int userId;
  final String userName;

  const TransferScreen({
    super.key, 
    required this.userId, 
    required this.userName
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  // Contrôleur pour le champ de saisie
  final TextEditingController _montantController = TextEditingController();
  
  // Service API
  final ApiService _apiService = ApiService();

  // État de l'application
  bool _isLoading = false;          // Chargement en cours ?
  TransferResponse? _lastResponse;  // Dernière réponse reçue
  double? _soldeActuel;             // Solde actuel

  @override
  void initState() {
    super.initState();
    _chargerSoldeInitial();
  }

  // Charge le solde au démarrage
  Future<void> _chargerSoldeInitial() async {
    // On utilise widget.userId pour récupérer le bon solde
    final solde = await _apiService.getSoldeActuel(widget.userId);
    setState(() {
      _soldeActuel = solde;
    });
  }

  // ÉTAPE 1 : Action déclenchée par le bouton "Transférer"
  Future<void> _effectuerTransfert() async {
    // Validation de la saisie
    final montantText = _montantController.text.trim();
    if (montantText.isEmpty) {
      _afficherErreur("Veuillez entrer un montant");
      return;
    }

    final montant = double.tryParse(montantText);
    if (montant == null || montant <= 0) {
      _afficherErreur("Montant invalide");
      return;
    }

    print("Transfert lancé par ${widget.userName} (ID: ${widget.userId})");
    print("Montant saisi : $montant");

    // Active le loader
    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      // Appel API en passant l'ID de l'utilisateur connecté
      final response = await _apiService.transfererMontant(widget.userId, montant);

      // ÉTAPE 6 : Mise à jour de l'interface avec les données
      print("Succès ? ${response.success} | Nouveau solde reçu : ${response.nouveauSolde}");
      
      setState(() {
        _lastResponse = response;
        if (response.success) {
          _soldeActuel = response.nouveauSolde;
          _montantController.clear(); // Vider le champ après succès
        }
        _isLoading = false;
      });

    } catch (e) {
      print("Erreur : $e");
      setState(() {
        _isLoading = false;
      });
      _afficherErreur("Erreur lors du transfert");
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
        // Titre personnalisé pour savoir qui est connecté
        title: Text("Transfert (${widget.userName})"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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

  // --- WIDGETS ---

  // Card affichant le solde actuel
  Widget _buildSoldeCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Solde disponible de ${widget.userName}",
              style: const TextStyle(
                fontSize: 16, 
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _soldeActuel != null 
                  ? "${_soldeActuel!.toStringAsFixed(2)} €" 
                  : "Chargement...",
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

  // ÉTAPE 0 : Champ de saisie du montant
  Widget _buildMontantInput() {
    return TextField(
      controller: _montantController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: "Montant à transférer",
        hintText: "Ex: 50.00",
        prefixIcon: const Icon(Icons.euro),
        suffixText: "EUR",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      style: const TextStyle(fontSize: 20),
    );
  }

  // ÉTAPE 1 : Bouton de transfert
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
        "Transférer",
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Indicateur de chargement
  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(
          "Traitement en cours...",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ÉTAPE 6 : Affichage du résultat
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
              _buildDetailRow("Solde initial", "${response.montantTotal.toStringAsFixed(2)} €"),
              _buildDetailRow("Montant transféré", "- ${response.montantTransfere.toStringAsFixed(2)} €"),
              _buildDetailRow(
                "Nouveau solde", 
                "${response.nouveauSolde.toStringAsFixed(2)} €",
                isBold: true,
              ),
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
