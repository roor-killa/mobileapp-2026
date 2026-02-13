import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';
import 'package:app_bkn/providers/user_provider.dart';
import 'package:app_bkn/providers/transaction_provider.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  double _amount = 200.0;
  bool _isLoading = false;

  Future<void> _handleSell() async {
    setState(() => _isLoading = true);
    
    final success = await context.read<TransactionProvider>().vendre(
      userId: ApiService.currentUserId!,
      montant: _amount,
    );
    
    if (!mounted) return;
    
    if (success) {
      await context.read<UserProvider>().refreshSolde();
      if (!mounted) return;
      _showSuccessDialog();
    } else {
      if (!mounted) return;
      _showErrorDialog();
    }
    
    setState(() => _isLoading = false);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppTheme.secondaryGreen, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Vente réussie !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_amount.toStringAsFixed(0)} BKN',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)
            ),
            const SizedBox(height: 8),
            const Text('vendus avec succès', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { 
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    final error = context.read<TransactionProvider>().error;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppTheme.errorRed, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Erreur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          error ?? 'Vente échouée',
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
        title: const Text('Vendre des BKN'), 
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountCard(solde),
              const SizedBox(height: 24),
              _buildBalanceInfo(solde),
              const SizedBox(height: 24),
              _buildBonusCard(),
              const SizedBox(height: 40),
              _buildSellButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(double solde) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight, 
          colors: [Colors.white, Color(0xFFF5F7FA)]
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Vente', 
            style: TextStyle(
              fontSize: 16, 
              color: AppTheme.textSecondary, 
              fontWeight: FontWeight.w600
            )
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _amount.toStringAsFixed(0), 
                style: const TextStyle(
                  fontSize: 56, 
                  fontWeight: FontWeight.bold, 
                  color: AppTheme.textPrimary, 
                  letterSpacing: -2
                )
              ),
              const SizedBox(width: 8),
              const Text(
                'BKN', 
                style: TextStyle(
                  fontSize: 24, 
                  color: AppTheme.textSecondary, 
                  fontWeight: FontWeight.w600
                )
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(30)
            ),
            child: Text(
              '≈ ${_amount.toStringAsFixed(0)} €', 
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: AppTheme.errorRed
              )
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _amount,
            min: 50,
            max: solde > 1000 ? 1000 : solde,
            divisions: 19,
            onChanged: (value) => setState(() => _amount = value),
            activeColor: AppTheme.errorRed,
            inactiveColor: AppTheme.errorRed.withValues(alpha: 0.2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50 BKN', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(
                '${solde > 1000 ? 1000 : solde.toStringAsFixed(0)} BKN', 
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(double solde) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Solde disponible',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)
          ),
          Text(
            '${solde.toStringAsFixed(0)} BKN',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)
          ),
        ],
      ),
    );
  }

  Widget _buildBonusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F9FF), Color(0xFFE6F7FF)]
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.bolt, color: AppTheme.secondaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Solution de disposition',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'L\'acheteur a trouvé un bon prix',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
            ),
            child: const Text(
              '100 € de bonus disponible',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryGreen)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFF3B30)]
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSell,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'VALIDER LA VENTE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
      ),
    );
  }
}