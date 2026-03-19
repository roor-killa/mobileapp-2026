import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientController = TextEditingController();
  final _montantController   = TextEditingController();
  final _apiService          = ApiService();

  bool    _isLoading    = false;
  bool?   _lastSuccess;
  String  _lastMessage  = '';
  double? _nouveauSolde;

  Future<void> _confirmerEtTransferer() async {
    final email       = _recipientController.text.trim();
    final montantText = _montantController.text.trim();

    if (email.isEmpty) {
      _afficherErreur("Veuillez entrer l'email du destinataire");
      return;
    }

    final montant = double.tryParse(montantText);
    if (montant == null || montant <= 0) {
      _afficherErreur('Montant invalide');
      return;
    }

    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Confirmer le transfert',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _confirmRow('Destinataire', email),
                    const Divider(color: AppColors.border, height: 24),
                    _confirmRow(
                      'Montant',
                      '${montant.toStringAsFixed(2)} €',
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: kGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirme != true) return;
    await _effectuerTransfert(email, montant);
  }

  Widget _confirmRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlight ? AppColors.primaryLight : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: highlight ? 20 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _effectuerTransfert(String email, double montant) async {
    setState(() {
      _isLoading   = true;
      _lastSuccess = null;
    });

    try {
      final result = await _apiService.transfer(email, montant);
      setState(() {
        _lastSuccess  = result['success'] == true;
        _lastMessage  = result['message'] ?? '';
        _nouveauSolde = result['nouveau_solde'] != null
            ? (result['nouveau_solde'] as num).toDouble()
            : null;
        _isLoading = false;
      });
      if (_lastSuccess == true) {
        _montantController.clear();
        _recipientController.clear();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur de connexion');
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: kDarkAppBar(title: "Envoyer de l'argent", context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            TextField(
              controller: _recipientController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: kDarkInput(
                label: 'Email du destinataire',
                hint: 'ex: bob@exemple.com',
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _montantController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              decoration: kDarkInput(
                label: 'Montant',
                hint: '0.00',
                prefixIcon: const Icon(Icons.euro, color: AppColors.textSecondary),
                suffixText: 'EUR',
              ),
            ),

            const SizedBox(height: 28),

            kGradientButton(
              text: 'Envoyer',
              onPressed: _isLoading ? null : _confirmerEtTransferer,
              isLoading: _isLoading,
            ),

            if (_lastSuccess != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final ok = _lastSuccess!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ok
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ok
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.error_rounded,
                color: ok ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _lastMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ok ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
          if (ok && _nouveauSolde != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nouveau solde',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  '${_nouveauSolde!.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _montantController.dispose();
    super.dispose();
  }
}
