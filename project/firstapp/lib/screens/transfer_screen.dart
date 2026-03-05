import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transfer_response.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../login_screen.dart' show LoginScreen; // Import nécessaire pour la déconnexion

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _emailDestinataireController = TextEditingController();
  
  // Utilisation du Singleton
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoadingHistory = true;
  double? _soldeActuel;
  List<Transaction> _history = [];
  
  // Utilisation d'un type dynamique pour éviter les erreurs de comparaison String/int
  dynamic _currentUserId;

  @override
  void initState() {
    super.initState();
    _chargerDonneesInitiales();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _emailDestinataireController.dispose();
    super.dispose();
  }

  /// Déconnexion de l'utilisateur
  void _deconnexion() {
    _apiService.token = null; // Efface le token
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _chargerDonneesInitiales() async {
    if (mounted) setState(() => _isLoadingHistory = true);
    
    // On récupère l'ID utilisateur stocké dans le service lors du login
    _currentUserId = _apiService.currentUserId;

    await Future.wait([
      _chargerSoldeInitial(),
      _chargerHistorique(),
    ]);
    
    if (mounted) setState(() => _isLoadingHistory = false);
  }

  Future<void> _chargerSoldeInitial() async {
    try {
      final solde = await _apiService.getSoldeActuel();
      if (mounted) {
        setState(() {
          _soldeActuel = solde;
        });
      }
    } catch (e) {
      print('Erreur solde: $e');
    }
  }

  Future<void> _chargerHistorique() async {
    try {
      final transactions = await _apiService.getTransactions();
      if (mounted) {
        setState(() {
          _history = transactions;
        });
      }
    } catch (e) {
      print('Erreur historique: $e');
    }
  }

  Future<void> _effectuerTransfert() async {
    final email = _emailDestinataireController.text.trim();
    final montantText = _montantController.text.trim();

    if (email.isEmpty || montantText.isEmpty) {
      _afficherErreur('Veuillez remplir tous les champs');
      return;
    }

    final montant = double.tryParse(montantText);
    if (montant == null || montant <= 0) {
      _afficherErreur('Montant invalide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.transfererMontant(
        email: email,
        montant: montant,
      );

      if (!mounted) return;

      if (response.success) {
        setState(() {
          _soldeActuel = response.nouveauSolde;
          _isLoading = false;
        });
        
        _montantController.clear();
        _emailDestinataireController.clear();
        
        _showSuccessDialog(response);
        _chargerHistorique(); // Rafraîchissement automatique
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _afficherErreur('Erreur : $e');
    }
  }

  void _showSuccessDialog(TransferResponse data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text("Transfert Réussi", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data.message, textAlign: TextAlign.center),
              const Divider(height: 30),
              _buildDialogRow("Ancien solde :", "${data.montantTotal.toStringAsFixed(2)} €"),
              _buildDialogRow("Montant envoyé :", "- ${data.montantTransfere.toStringAsFixed(2)} €", color: Colors.red),
              const Divider(),
              _buildDialogRow("Nouveau solde :", "${data.nouveauSolde.toStringAsFixed(2)} €", isBold: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
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
        title: const Text('Transfert d\'argent'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: _chargerDonneesInitiales,
            tooltip: "Actualiser",
          ),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: _deconnexion,
            tooltip: "Déconnexion",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _chargerDonneesInitiales,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSoldeCard(),
              const SizedBox(height: 30),
              _buildEmailInput(),
              const SizedBox(height: 20),
              _buildMontantInput(),
              const SizedBox(height: 20),
              _buildTransferButton(),
              const SizedBox(height: 40),
              const Text(
                'Historique des transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoldeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Solde disponible', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 10),
            Text(
              _soldeActuel != null ? '${_soldeActuel!.toStringAsFixed(2)} €' : '--- €',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return TextField(
      controller: _emailDestinataireController,
      decoration: InputDecoration(
        labelText: 'Email du destinataire',
        prefixIcon: const Icon(Icons.alternate_email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildMontantInput() {
    return TextField(
      controller: _montantController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      decoration: InputDecoration(
        labelText: 'Montant (€)',
        prefixIcon: const Icon(Icons.euro),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildTransferButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _effectuerTransfert,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : const Text('Envoyer l\'argent', style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoadingHistory) {
      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
    }

    if (_history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Aucune transaction trouvée.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final tx = _history[index];
        
        // Comparaison robuste en transformant les deux IDs en String
        bool isSent = tx.senderId.toString() == _currentUserId.toString();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSent ? Colors.red.shade50 : Colors.green.shade50,
              child: Icon(
                isSent ? Icons.north_east : Icons.south_west, 
                color: isSent ? Colors.red : Colors.green
              ),
            ),
            title: Text(isSent ? "Vers ${tx.receiverName}" : "De ${tx.senderName}"),
            subtitle: Text(tx.date.substring(0, 10)),
            trailing: Text(
              "${isSent ? '-' : '+'}${tx.amount.toStringAsFixed(2)} €",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isSent ? Colors.red : Colors.green
              ),
            ),
          ),
        );
      },
    );
  }
}