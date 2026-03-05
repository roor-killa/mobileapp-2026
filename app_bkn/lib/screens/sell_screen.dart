import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Pour Clipboard
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
  late double _amount;
  bool _isLoading = false;
  final double minimumBalance = 10.0;

  @override
  void initState() {
    super.initState();
    _amount = 0.0;
  }

  Future<void> _handleSell() async {
    if (ApiService.currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vous devez être connecté'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final success = await context.read<TransactionProvider>().vendre(
        userId: ApiService.currentUserId!,
        montant: _amount,
      );
      
      if (!mounted) return;
      
      if (success) {
        await context.read<UserProvider>().refreshSolde();
        if (!mounted) return;
        
        // Récupérer la dernière transaction pour l'ID
        final transactions = context.read<TransactionProvider>().transactions;
        String? transactionId;
        if (transactions.isNotEmpty) {
          transactionId = transactions.first['id'];
        }
        
        _showSuccessDialog(transactionId);
      } else {
        final error = context.read<TransactionProvider>().error;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Vente échouée'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(String? transactionId) {
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
            
            // Affichage sécurisé de l'ID de transaction
            if (transactionId != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt, size: 16, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        const Text(
                          'Référence de transaction',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              transactionId,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.copy, size: 20, color: AppTheme.primaryBlue),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: transactionId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('📋 ID copié dans le presse-papiers'),
                                  backgroundColor: AppTheme.primaryBlue,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gardez cet ID pour le support client',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final double solde = userProvider.solde;
    
    final double maxVendable = solde > minimumBalance ? solde - minimumBalance : 0.0;
    
    if (_amount > maxVendable) {
      _amount = maxVendable;
    }
    if (_amount < 0) _amount = 0.0;

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
              _buildAmountCard(solde, maxVendable),
              const SizedBox(height: 24),
              _buildBalanceInfo(solde),
              const SizedBox(height: 24),
              _buildBonusCard(),
              const SizedBox(height: 40),
              _buildSellButton(maxVendable <= 0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(double solde, double maxVendable) {
    final bool peutVendre = maxVendable > 0.0;
    
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
                peutVendre ? _amount.toStringAsFixed(0) : '0', 
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
              color: peutVendre 
                  ? AppTheme.errorRed.withValues(alpha: 0.1)
                  : Colors.grey.shade200, 
              borderRadius: BorderRadius.circular(30)
            ),
            child: Text(
              peutVendre ? '≈ ${_amount.toStringAsFixed(0)} €' : '0 €', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: peutVendre ? AppTheme.errorRed : Colors.grey.shade600
              )
            ),
          ),
          const SizedBox(height: 24),
          
          if (peutVendre)
            Column(
              children: [
                Slider(
                  value: _amount,
                  min: 0.0,
                  max: maxVendable,
                  divisions: maxVendable > 0.0 ? maxVendable.toInt() : 1,
                  onChanged: (double value) => setState(() => _amount = value),
                  activeColor: AppTheme.errorRed,
                  inactiveColor: AppTheme.errorRed.withValues(alpha: 0.2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 BKN', 
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)
                    ),
                    Text(
                      '${maxVendable.toStringAsFixed(0)} BKN', 
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)
                    ),
                  ],
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Solde insuffisant',
                          style: TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vous devez garder au moins ${minimumBalance.toStringAsFixed(0)} BKN',
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
          if (peutVendre) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Après la vente, il vous restera ${(solde - _amount).toStringAsFixed(0)} BKN',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildSellButton(bool soldeInsuffisant) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: soldeInsuffisant || _amount == 0.0
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade400, Colors.grey.shade500]
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B6B), Color(0xFFFF3B30)]
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: (soldeInsuffisant || _amount == 0.0)
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10)
                )
              ],
      ),
      child: ElevatedButton(
        onPressed: (soldeInsuffisant || _amount == 0.0 || _isLoading) ? null : _handleSell,
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
            : Text(
                soldeInsuffisant ? 'SOLDE INSUFFISANT' : 
                _amount == 0.0 ? 'SÉLECTIONNEZ UN MONTANT' : 'VALIDER LA VENTE',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
      ),
    );
  }
}