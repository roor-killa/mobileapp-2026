import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transfer_response.dart';
import '../models/utilisateur.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Version autonome (navigation directe) — conservée pour compatibilité.
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const TransferTab(),
    );
  }
}

/// Contenu du transfert — utilisé dans DashboardScreen comme onglet.
class TransferTab extends StatefulWidget {
  const TransferTab({super.key});

  @override
  State<TransferTab> createState() => _TransferTabState();
}

class _TransferTabState extends State<TransferTab> {
  final TextEditingController _montantController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _loadingUsers = true;
  TransferResponse? _lastResponse;
  List<Utilisateur> _utilisateurs = [];
  List<int> _favorisIds = [];
  Utilisateur? _destinataire;
  bool _showFavorisOnly = false;

  Utilisateur get _user => AuthService.utilisateurConnecte!;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final users = await DatabaseService.instance.getTousLesUtilisateurs(_user.id!);
    final favoris = await DatabaseService.instance.getFavoris(_user.id!);
    if (mounted) {
      setState(() {
        _utilisateurs = users;
        _favorisIds = favoris;
        _loadingUsers = false;
      });
    }
  }

  List<Utilisateur> get _utilisateursFiltres {
    if (!_showFavorisOnly) return _utilisateurs;
    return _utilisateurs.where((u) => _favorisIds.contains(u.id)).toList();
  }

  Future<void> _toggleFavori(Utilisateur u) async {
    await DatabaseService.instance.toggleFavori(_user.id!, u.id!);
    final favoris = await DatabaseService.instance.getFavoris(_user.id!);
    if (mounted) setState(() => _favorisIds = favoris);
  }

  Future<bool?> _afficherConfirmation(double montant) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer le virement'),
        content: Text(
          'Envoyer ${montant.toStringAsFixed(2)} € à ${_destinataire!.nom} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _effectuerTransfert() async {
    if (_destinataire == null) {
      _afficherErreur('Veuillez choisir un destinataire');
      return;
    }

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

    final confirme = await _afficherConfirmation(montant);
    if (confirme != true) return;

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      final response =
          await _apiService.transfererMontant(montant, _user, _destinataire!);

      if (!mounted) return;
      setState(() {
        _lastResponse = response;
        _isLoading = false;
      });

      if (response.success) {
        _montantController.clear();
        setState(() => _destinataire = null);
        _chargerDonnees();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du transfert');
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSoldeCard(),
          const SizedBox(height: 24),
          _buildDestinataireSection(),
          const SizedBox(height: 16),
          _buildMontantInput(),
          const SizedBox(height: 20),
          _buildTransferButton(),
          const SizedBox(height: 30),
          if (_lastResponse != null) _buildResultCard(),
          if (_isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildSoldeCard() {
    return Card(
      elevation: 4,
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Solde disponible',
                style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 10),
            Text(
              '${_user.soldeActuel.toStringAsFixed(2)} €',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinataireSection() {
    if (_loadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_utilisateurs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Aucun autre compte disponible.\nCréez d\'autres comptes pour effectuer des transferts.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton favoris
        if (_favorisIds.isNotEmpty)
          Row(
            children: [
              const Text(
                'Destinataire',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _showFavorisOnly = !_showFavorisOnly),
                icon: Icon(
                  _showFavorisOnly ? Icons.star : Icons.star_border,
                  size: 18,
                  color: _showFavorisOnly ? Colors.amber : Colors.grey,
                ),
                label: Text(
                  _showFavorisOnly ? 'Tous' : 'Favoris',
                  style: TextStyle(
                    color: _showFavorisOnly ? Colors.amber : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

        // Liste des destinataires
        ..._utilisateursFiltres.map((u) {
          final isSelected = _destinataire?.id == u.id;
          final isFavori = _favorisIds.contains(u.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: isSelected ? 3 : 1,
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              onTap: () => setState(() => _destinataire = isSelected ? null : u),
              leading: CircleAvatar(
                backgroundColor:
                    isSelected ? AppColors.primary : Colors.grey.shade200,
                child: Text(
                  u.nom.isNotEmpty ? u.nom[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                u.nom,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
              subtitle: Text(
                u.email,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  IconButton(
                    icon: Icon(
                      isFavori ? Icons.star : Icons.star_border,
                      color: isFavori ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => _toggleFavori(u),
                    tooltip: isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
                  ),
                ],
              ),
            ),
          );
        }),

        if (_utilisateursFiltres.isEmpty && _showFavorisOnly)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Aucun favori — appuyez sur ⭐ pour en ajouter',
                style: TextStyle(color: Colors.black45),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMontantInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        // Boutons montants rapides
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [10, 20, 50, 100, 200, 500].map((montant) {
            return OutlinedButton(
              onPressed: () {
                _montantController.text = montant.toString();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '$montant €',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransferButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _effectuerTransfert,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Transférer',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                Icon(isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    response.message,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),
            if (isSuccess) ...[
              const Divider(height: 30),
              _buildDetailRow('Solde initial',
                  '${response.montantTotal.toStringAsFixed(2)} €'),
              _buildDetailRow('Montant envoyé',
                  '- ${response.montantTransfere.toStringAsFixed(2)} €'),
              _buildDetailRow('Nouveau solde',
                  '${response.nouveauSolde.toStringAsFixed(2)} €',
                  isBold: true),
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
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  color: isBold ? AppColors.primary : Colors.black,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
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
