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
  final TextEditingController _cvvController = TextEditingController(); // AJOUT
  
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
    _cvvController.dispose(); // AJOUT
    super.dispose();
  }

  // Fonction pour formater automatiquement la date d'expiration
  void _formatExpiryDate(String value) {
    // Enlever tous les caractères non chiffres
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.length >= 3) {
      // Format MM/YY
      String month = digits.substring(0, 2);
      String year = digits.substring(2, digits.length > 4 ? 4 : digits.length);
      
      // Valider le mois (01-12)
      int monthInt = int.tryParse(month) ?? 0;
      if (monthInt > 12) {
        month = '12';
      } else if (monthInt < 1 && digits.length >= 2) {
        month = '01';
      }
      
      String formatted = month;
      if (year.isNotEmpty) {
        formatted += '/$year';
      }
      
      // Mettre à jour le texte sans déclencher un nouveau formatage
      if (_expiryController.text != formatted) {
        _expiryController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    } else {
      // Moins de 2 chiffres
      if (_expiryController.text != digits) {
        _expiryController.value = TextEditingValue(
          text: digits,
          selection: TextSelection.collapsed(offset: digits.length),
        );
      }
    }
  }

  // Fonction pour formater le numéro de carte
  void _formatCardNumber(String value) {
    // Enlever tous les caractères non chiffres
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Formater par groupes de 4
    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(digits[i]);
    }
    
    // Mettre à jour le texte
    if (_cardController.text != formatted.toString()) {
      _cardController.value = TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _handleBuy() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final success = await context.read<TransactionProvider>().acheter(
      userId: ApiService.currentUserId!,
      montant: _amount,
      methode: _selectedMethod,
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
            const Text(
              'ajoutés à votre solde',
              style: TextStyle(
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
    final error = context.read<TransactionProvider>().error;
    
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
          error ?? 'Achat échoué',
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
                    'Numéro de carte',
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
                  
                  Row(
                    children: [
                      // Champ Date d'expiration avec formatage automatique
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date expiration',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildExpiryField()
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 500.ms),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Champ CVV (nouveau)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CVV',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCVVField()
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 550.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
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
          hintText: '4444 1234 5678 9012',
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
          String digits = value.replaceAll(' ', '');
          if (digits.length < 16) {
            return 'Numéro de carte invalide';
          }
          return null;
        },
        onChanged: _formatCardNumber, // Formatage automatique
        maxLength: 19, // 16 chiffres + 3 espaces
      ),
    );
  }

  // ✅ NOUVEAU : Champ date d'expiration avec formatage automatique
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
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'MM/AA',
          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          counterText: '', // Cache le compteur
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date d\'expiration requise';
          }
          // Enlever tous les caractères non chiffres pour la validation
          String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.length < 4) {
            return 'Format invalide (MM/AA)';
          }
          
          // Valider le mois
          int month = int.tryParse(digits.substring(0, 2)) ?? 0;
          if (month < 1 || month > 12) {
            return 'Mois invalide';
          }
          
          // Valider que la date n'est pas passée (optionnel)
          int year = int.tryParse('20${digits.substring(2, 4)}') ?? 0;
          DateTime now = DateTime.now();
          if (year < now.year || (year == now.year && month < now.month)) {
            return 'Carte expirée';
          }
          
          return null;
        },
        onChanged: _formatExpiryDate, // Formatage automatique avec le /
        maxLength: 5, // MM/AA = 5 caractères
      ),
    );
  }

  // ✅ NOUVEAU : Champ CVV
  Widget _buildCVVField() {
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
        controller: _cvvController,
        keyboardType: TextInputType.number,
        obscureText: true, // Masquer le CVV
        decoration: InputDecoration(
          hintText: '123',
          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'CVV requis';
          }
          if (value.length < 3) {
            return 'CVV invalide';
          }
          return null;
        },
        maxLength: 4, // 3 ou 4 chiffres
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