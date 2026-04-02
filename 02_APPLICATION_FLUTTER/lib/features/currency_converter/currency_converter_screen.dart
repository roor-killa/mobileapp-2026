import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/currency.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final List<String> currencies = ['EUR', 'USD', 'GBP', 'CAD', 'XAF'];
  late String _fromCurrency = 'EUR';
  late String _toCurrency = 'USD';
  late TextEditingController _amountController;
  late List<CurrencyConversion> _history;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');
    _history = [];
  }

  double _convert(double amount) {
    final key = '${_fromCurrency}_$_toCurrency';
    final rate = exchangeRates[key] ?? 1.0;
    return amount * rate;
  }

  void _addToHistory() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > 0) {
      final key = '${_fromCurrency}_$_toCurrency';
      final rate = exchangeRates[key] ?? 1.0;
      setState(() {
        _history.insert(
          0,
          CurrencyConversion(
            fromCurrency: _fromCurrency,
            toCurrency: _toCurrency,
            amount: amount,
            rate: rate,
            timestamp: DateTime.now(),
          ),
        );
        if (_history.length > 10) _history.removeLast();
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final convertedAmount = _convert(
      double.tryParse(_amountController.text) ?? 0,
    );

    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Convertisseur',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Conversion card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NEGsColors.bgWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NEGsColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: NEGsColors.primaryViolet.withValues(alpha: 0.08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // From currency
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'De',
                          style: TextStyle(
                            fontSize: 12,
                            color: NEGsColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          onChanged: (_) => setState(() {}),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: NEGsColors.bgSecondaryLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: NEGsColors.borderLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: NEGsColors.borderLight,
                              ),
                            ),
                            suffix: DropdownButton<String>(
                              value: _fromCurrency,
                              onChanged: (value) =>
                                  setState(() => _fromCurrency = value!),
                              items: currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(
                                    '$currency ${currencySymbols[currency]}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              underline: const SizedBox(),
                              isDense: true,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Swap button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: NEGsGradients.mainGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _swapCurrencies,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Icon(
                          Icons.swap_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // To currency
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vers',
                          style: TextStyle(
                            fontSize: 12,
                            color: NEGsColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: NEGsColors.bgSecondaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: NEGsColors.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    convertedAmount.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: NEGsColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              DropdownButton<String>(
                                value: _toCurrency,
                                onChanged: (value) =>
                                    setState(() => _toCurrency = value!),
                                items: currencies.map((currency) {
                                  return DropdownMenuItem(
                                    value: currency,
                                    child: Text(
                                      '$currency ${currencySymbols[currency]}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                underline: const SizedBox(),
                                isDense: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Exchange rate info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NEGsColors.primaryCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NEGsColors.primaryCyan),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Taux de change',
                          style: TextStyle(
                            fontSize: 12,
                            color: NEGsColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1 $_fromCurrency = ${(_convert(1)).toStringAsFixed(4)} $_toCurrency',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: NEGsColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.info_outline, color: NEGsColors.primaryCyan),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Convert button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _addToHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Convertir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // History
              if (_history.isNotEmpty) ...[
                const Text(
                  'Historique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: NEGsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final conversion = _history[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NEGsColors.bgWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NEGsColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${conversion.amount} ${conversion.fromCurrency} → ${conversion.convertedAmount.toStringAsFixed(2)} ${conversion.toCurrency}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: NEGsColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${conversion.timestamp.hour}:${conversion.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: NEGsColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: NEGsColors.textTertiary,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
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
