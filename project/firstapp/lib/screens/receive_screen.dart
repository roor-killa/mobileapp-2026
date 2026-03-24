import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _amountController = TextEditingController();
  final _authService      = AuthService();
  final _apiService       = ApiService();

  String? _qrData;
  String? _userEmail;
  double? _montant;
  String  _currency     = 'EUR';
  bool    _loadingEmail = true;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    String? email = await _authService.getEmail();

    if (email == null) {
      email = await _apiService.getCurrentUserEmail();
      await _authService.saveEmail(email);
    }

    setState(() {
      _userEmail    = email;
      _loadingEmail = false;
    });
  }

  void _genererQr() {
    final montant = double.tryParse(_amountController.text.trim());
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez entrer un montant valide'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_userEmail == null) return;

    setState(() {
      _montant = montant;
      _qrData  = jsonEncode({
        'email':    _userEmail,
        'amount':   montant,
        'currency': _currency,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: kDarkAppBar(title: 'Recevoir', context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Sélecteur de devise
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_exchange, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  const Text('Devise', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const Spacer(),
                  _currencyToggle('EUR'),
                  const SizedBox(width: 8),
                  _currencyToggle('BKN'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              decoration: kDarkInput(
                label: 'Montant à recevoir',
                hint: '0.00',
                prefixIcon: Icon(
                  _currency == 'EUR' ? Icons.euro : Icons.toll_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixText: _currency,
              ),
            ),

            const SizedBox(height: 20),

            kGradientButton(
              text: 'Générer le QR Code',
              onPressed: (_loadingEmail || _userEmail == null) ? null : _genererQr,
              isLoading: _loadingEmail,
            ),

            if (_qrData != null) ...[
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${_montant!.toStringAsFixed(2)} $_currency',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D0F1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7B7F9E)),
                    ),
                    const SizedBox(height: 20),
                    QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 220,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Faites scanner ce QR code\npour recevoir le paiement',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF7B7F9E), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _currencyToggle(String currency) {
    final selected = _currency == currency;
    return GestureDetector(
      onTap: () => setState(() {
        _currency = currency;
        _qrData   = null; // reset QR si on change de devise
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          currency,
          style: TextStyle(
            color: selected ? AppColors.primaryLight : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
