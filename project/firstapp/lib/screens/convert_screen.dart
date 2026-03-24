import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final _amountController = TextEditingController();
  final _apiService       = ApiService();

  bool   _isLoading    = false;
  bool   _loadingRate  = true;
  double _rate         = 10.0;
  String _from         = 'EUR';
  String _to           = 'BKN';
  bool?  _lastSuccess;
  String _lastMessage  = '';
  double? _soldeEur;
  double? _soldeBkn;

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  Future<void> _loadRate() async {
    try {
      final rate = await _apiService.getExchangeRate();
      setState(() {
        _rate        = rate;
        _loadingRate = false;
      });
    } catch (_) {
      setState(() => _loadingRate = false);
    }
  }

  void _swapDevises() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to   = tmp;
      _amountController.clear();
      _lastSuccess = null;
    });
  }

  double get _montantConverti {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _from == 'EUR'
        ? amount * _rate
        : amount / _rate;
  }

  Future<void> _convertir() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _afficherErreur('Montant invalide');
      return;
    }

    setState(() {
      _isLoading   = true;
      _lastSuccess = null;
    });

    try {
      final result = await _apiService.convert(
        fromCurrency: _from,
        toCurrency:   _to,
        amount:       amount,
      );
      setState(() {
        _lastSuccess = result['success'] == true;
        _lastMessage = result['message'] ?? '';
        _soldeEur    = result['nouveau_solde'] != null
            ? (result['nouveau_solde'] as num).toDouble()
            : null;
        _soldeBkn    = result['nouveau_solde_bkn'] != null
            ? (result['nouveau_solde_bkn'] as num).toDouble()
            : null;
        _isLoading   = false;
      });
      if (_lastSuccess == true) _amountController.clear();
    } catch (_) {
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
      appBar: kDarkAppBar(title: 'Convertir EUR ↔ BKN', context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Taux de change
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  _loadingRate
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : Text(
                          'Taux : 1 EUR = ${_rate.toStringAsFixed(2)} BKN',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sélecteur de sens
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _deviseChip(_from, active: true),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _swapDevises,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.primaryLight,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _deviseChip(_to, active: false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Champ montant
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              decoration: kDarkInput(
                label: 'Montant à convertir',
                hint: '0.00',
                prefixIcon: Icon(
                  _from == 'EUR' ? Icons.euro : Icons.toll_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixText: _from,
              ),
            ),

            // Aperçu du montant converti
            if (_amountController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '≈ ${_montantConverti.toStringAsFixed(2)} $_to',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            kGradientButton(
              text: 'Convertir',
              onPressed: (_isLoading || _loadingRate) ? null : _convertir,
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

  Widget _deviseChip(String devise, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        devise,
        style: TextStyle(
          color: active ? AppColors.primaryLight : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
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
          if (ok && (_soldeEur != null || _soldeBkn != null)) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            if (_soldeEur != null)
              _soldeRow('Solde EUR', '${_soldeEur!.toStringAsFixed(2)} €'),
            if (_soldeBkn != null) ...[
              const SizedBox(height: 8),
              _soldeRow('Solde BKN', '${_soldeBkn!.toStringAsFixed(2)} BKN'),
            ],
          ],
        ],
      ),
    );
  }

  Widget _soldeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
