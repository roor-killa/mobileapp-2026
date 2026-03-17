import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transfer_response.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../login_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _emailDestinataireController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoadingHistory = true;
  double? _soldeActuel;
  List<Transaction> _history = [];
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

  void _deconnexion() {
    _apiService.token = null;
    _apiService.currentUserId = null;
    _apiService.userName = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _chargerDonneesInitiales() async {
    if (mounted) setState(() => _isLoadingHistory = true);
    _currentUserId = _apiService.currentUserId;
    await Future.wait([_chargerSoldeInitial(), _chargerHistorique()]);
    if (mounted) setState(() => _isLoadingHistory = false);
  }

  Future<void> _chargerSoldeInitial() async {
    try {
      final solde = await _apiService.getSoldeActuel();
      if (mounted) setState(() => _soldeActuel = solde);
    } catch (e) {
      print('Erreur solde: $e');
    }
  }

  Future<void> _chargerHistorique() async {
    try {
      final transactions = await _apiService.getTransactions();
      if (mounted) setState(() => _history = transactions);
    } catch (e) {
      print('Erreur historique: $e');
    }
  }

  /// ÉTAPE 1 : Vérification des champs et ouverture du PIN
  void _preparerTransfert() {
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

    _afficherSaisiePIN(email, montant);
  }

  /// ÉTAPE 2 : Fenêtre de saisie du code PIN
  void _afficherSaisiePIN(String email, double montant) {
    String pinSaisi = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 40, color: Colors.blue),
            const SizedBox(height: 15),
            const Text("Validation sécurisée", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Entrez votre code PIN pour envoyer $montant €"),
            const SizedBox(height: 20),
            TextField(
              maxLength: 4,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 20),
              decoration: const InputDecoration(counterText: "", hintText: "****"),
              onChanged: (val) => pinSaisi = val,
              onSubmitted: (val) {
                Navigator.pop(context);
                _executerTransfertFinal(email, montant, val);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executerTransfertFinal(email, montant, pinSaisi);
              },
              child: const Text("Confirmer le transfert"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ÉTAPE 3 : Envoi final à l'API
  Future<void> _executerTransfertFinal(String email, double montant, String pin) async {
    setState(() => _isLoading = true); // Le chargement commence ici

    try {
      final response = await _apiService.transfererMontant(
        email: email,
        montant: montant,
        pin: pin,
      );

      if (!mounted) return;

      setState(() => _isLoading = false); // ARRÊT du chargement en cas de succès

      if (response.success) {
        _showSuccessDialog(response);
        _chargerHistorique();
      } else {
        // Si le PIN est faux, le serveur répond success: false
        _afficherErreur(response.message);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false); // ARRÊT du chargement en cas d'erreur
      _afficherErreur("Erreur de connexion : $e");
    }
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Wallet'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _chargerDonneesInitiales),
          IconButton(icon: const Icon(Icons.logout), onPressed: _deconnexion),
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
              const Text('Historique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text(
              "Bonjour, ${_apiService.userName ?? 'Utilisateur'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey),
            ),
            const Divider(height: 25),
            const Text('Solde disponible', style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 5),
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
        labelText: 'Email destinataire',
        prefixIcon: const Icon(Icons.alternate_email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }

  Widget _buildTransferButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _preparerTransfert,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading 
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text('Envoyer l\'argent', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoadingHistory) return const Center(child: CircularProgressIndicator());
    if (_history.isEmpty) return const Center(child: Text("Aucune transaction."));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final tx = _history[index];
        bool isSent = tx.senderId.toString() == _currentUserId.toString();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSent ? Colors.red.shade50 : Colors.green.shade50,
              child: Icon(isSent ? Icons.north : Icons.south, color: isSent ? Colors.red : Colors.green),
            ),
            title: Text(isSent ? "Vers ${tx.receiverName}" : "De ${tx.senderName}"),
            subtitle: Text(tx.date.substring(0, 10)),
            trailing: Text(
              "${isSent ? '-' : '+'}${tx.amount.toStringAsFixed(2)} €",
              style: TextStyle(fontWeight: FontWeight.bold, color: isSent ? Colors.red : Colors.green),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(TransferResponse data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Succès !"),
        content: Text(data.message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  void _afficherErreur(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}