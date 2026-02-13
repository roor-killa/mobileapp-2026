import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';
import 'package:app_bkn/providers/user_provider.dart';
import 'package:app_bkn/providers/transaction_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinataireController = TextEditingController();
  final _montantController = TextEditingController();
  
  bool _isLoading = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _destinataireController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await ApiService.getUsers();
    setState(() => _users = users);
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final montant = double.parse(_montantController.text);
    final success = await context.read<TransactionProvider>().transfer(
      expediteurId: ApiService.currentUserId!,
      destinataire: _destinataireController.text,
      montant: montant,
    );
    
    if (success && mounted) {
      await context.read<UserProvider>().refreshSolde();
      
      _showSuccessDialog(montant);
      _montantController.clear();
    } else if (mounted) {
      _showErrorDialog();
    }
    
    setState(() => _isLoading = false);
  }

  void _showSuccessDialog(double montant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.secondaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transfert réussi !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${montant.toStringAsFixed(0)} BKN',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'vers ${_destinataireController.text}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.errorRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          context.watch<TransactionProvider>().error ?? 'Transfert échoué',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TransactionProvider>().clearError();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final solde = userProvider.solde;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert BKN'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                _buildBalanceCard(solde)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Destinataire
                const Text(
                  'Destinataire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 12),
                
                _buildDestinataireField()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 24),
                
                // Montant
                const Text(
                  'Montant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 12),
                
                _buildMontantField()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 40),
                
                // Bouton Transfert
                _buildTransferButton()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                
                const SizedBox(height: 24),
                
                // Contacts rapides
                _buildQuickContacts()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double solde) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF5F7FA)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solde disponible',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ApiService.currentUserPseudo ?? '@user',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                solde.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BKN',
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestinataireField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _destinataireController,
        decoration: InputDecoration(
          hintText: '@pseudo ou email',
          prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _destinataireController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                  onPressed: () => _destinataireController.clear(),
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Destinataire requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMontantField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _montantController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: '0',
          prefixIcon: const Icon(Icons.euro, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          suffixText: 'BKN',
          suffixStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
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
          if (montant > context.read<UserProvider>().solde) {
            return 'Solde insuffisant';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTransferButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'TRANSFÉRER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildQuickContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Contacts récents',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              if (user['id'] == ApiService.currentUserId) return const SizedBox.shrink();
              
              return GestureDetector(
                onTap: () => _destinataireController.text = user['pseudo'],
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        child: Text(
                          user['prenom'][0],
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['prenom'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}