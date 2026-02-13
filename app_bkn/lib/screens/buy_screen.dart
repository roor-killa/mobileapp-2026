import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';
import 'package:app_bkn/providers/user_provider.dart';
import 'package:app_bkn/providers/transaction_provider.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 300.0;
  String _selectedMethod = 'Stripe';
  
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  
  bool _isLoading = false;

  final List<String> _paymentMethods = ['Stripe', 'Offline', 'QR Code'];
  final List<IconData> _paymentIcons = [Icons.payment, Icons.offline_bolt, Icons.qr_code];

  @override
  void initState() {
    super.initState();
    _cardController.text = '444 ';
  }

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _handleBuy() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final success = await context.read<TransactionProvider>().acheter(
      userId: ApiService.currentUserId!,
      montant: _amount,
      methode: _selectedMethod,
    );
    
    if (success && mounted) {
      await context.read<UserProvider>().refreshSolde();
      
      _showSuccessDialog();
    } else if (mounted) {
      _showErrorDialog();
    }
    
    setState(() => _isLoading = false);
  }

  void _showSuccessDialog() {
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
              'Achat réussi !',
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
              '${_amount.toStringAsFixed(0)} BKN',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ajoutés à votre solde',
              style: const TextStyle(
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
          context.watch<TransactionProvider>().error ?? 'Achat échoué',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acheter des BKN'),
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
                // Montant Card
                _buildAmountCard()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Payment Method
                const Text(
                  'Méthode de paiement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 16),
                
                _buildPaymentMethods()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideX(begin: -0.1, end: 0),
                
                if (_selectedMethod == 'Stripe') ...[
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Numéro CB',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
                  
                  const SizedBox(height: 12),
                  
                  _buildCardField()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms),
                  
                  const SizedBox(height: 16),
                  
                  _buildExpiryField()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms),
                ],
                
                const SizedBox(height: 40),
                
                // Buy Button
                _buildBuyButton()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF5F7FA)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Achat',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
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
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BKN',
                style: TextStyle(
                  fontSize: 24,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '≈ ${_amount.toStringAsFixed(0)} €',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _amount,
            min: 50,
            max: 1000,
            divisions: 19,
            onChanged: (value) => setState(() => _amount = value),
            activeColor: AppTheme.primaryBlue,
            inactiveColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50 BKN', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text('1000 BKN', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Row(
      children: List.generate(_paymentMethods.length, (index) {
        final isSelected = _selectedMethod == _paymentMethods[index];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMethod = _paymentMethods[index]),
            child: Container(
              margin: EdgeInsets.only(right: index < _paymentMethods.length - 1 ? 12 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ] : null,
              ),
              child: Column(
                children: [
                  Icon(
                    _paymentIcons[index],
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _paymentMethods[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _cardController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: '444 1234 5678 9012',
          prefixIcon: const Icon(Icons.credit_card, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Numéro de carte requis';
          }
          if (value.length < 16) {
            return 'Numéro de carte invalide';
          }
          return null;
        },
        onChanged: (value) {
          if (!value.startsWith('444 ')) {
            _cardController.text = '444 ';
            _cardController.selection = TextSelection.collapsed(offset: 4);
          }
        },
      ),
    );
  }

  Widget _buildExpiryField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _expiryController,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          hintText: 'MM/AA',
          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date d\'expiration requise';
          }
          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
            return 'Format invalide (MM/AA)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBuyButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleBuy,
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
                'ACHETER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}