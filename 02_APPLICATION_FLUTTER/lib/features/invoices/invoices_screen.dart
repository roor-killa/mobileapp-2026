import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/invoice.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final List<String> categories = [
    'Électricité',
    'Eau',
    'Internet',
    'Téléphone',
    'Loyer',
    'Impôts',
  ];

  late List<Invoice> _invoices;
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _invoices = [
      Invoice(
        id: '1',
        name: 'EDF - Facture électricité',
        category: 'Électricité',
        amount: 145.50,
        dueDate: DateTime(2026, 4, 15),
        paidDate: DateTime(2026, 4, 10),
        reference: 'EDF-2026-04-001',
      ),
      Invoice(
        id: '2',
        name: 'Veolia - Facture eau',
        category: 'Eau',
        amount: 65.00,
        dueDate: DateTime(2026, 4, 20),
        reference: 'VEOLIA-2026-04-001',
      ),
      Invoice(
        id: '3',
        name: 'Orange - Internet et téléphone',
        category: 'Internet',
        amount: 49.99,
        dueDate: DateTime(2026, 3, 28),
        paidDate: DateTime(2026, 3, 25),
        reference: 'ORANGE-2026-03-001',
      ),
      Invoice(
        id: '4',
        name: 'SFR - Facture mobile',
        category: 'Téléphone',
        amount: 29.99,
        dueDate: DateTime(2026, 4, 5),
        reference: 'SFR-2026-04-001',
      ),
      Invoice(
        id: '5',
        name: 'Propriétaire - Loyer avril',
        category: 'Loyer',
        amount: 900.00,
        dueDate: DateTime(2026, 4, 1),
        paidDate: DateTime(2026, 3, 31),
        reference: 'LOYER-2026-04-001',
      ),
    ];
  }

  List<Invoice> get _filteredInvoices {
    if (_selectedCategory == 'Tous') {
      return _invoices;
    }
    return _invoices.where((i) => i.category == _selectedCategory).toList();
  }

  double get _totalDue {
    return _filteredInvoices
        .where((i) => !i.isPaid)
        .fold(0, (sum, i) => sum + i.amount);
  }

  void _markAsPaid(int index) {
    final invoice = _filteredInvoices[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: NEGsColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmer le paiement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NEGsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NEGsColors.bgSecondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Montant: €${invoice.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: NEGsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Référence: ${invoice.reference}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: NEGsColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: NEGsGradients.mainGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final idx = _invoices.indexWhere(
                        (i) => i.id == invoice.id,
                      );
                      if (idx != -1) {
                        _invoices[idx] = Invoice(
                          id: invoice.id,
                          name: invoice.name,
                          category: invoice.category,
                          amount: invoice.amount,
                          dueDate: invoice.dueDate,
                          paidDate: DateTime.now(),
                          reference: invoice.reference,
                        );
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paiement confirmé'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Payer maintenant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: NEGsColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: NEGsColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Factures',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NEGsColors.bgWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NEGsColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Montant à payer',
                          style: TextStyle(
                            fontSize: 12,
                            color: NEGsColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${_totalDue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: NEGsColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['Tous', ...categories].map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? NEGsColors.primaryViolet
                                    : NEGsColors.bgWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? NEGsColors.primaryViolet
                                      : NEGsColors.borderLight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : NEGsColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredInvoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt,
                            size: 48,
                            color: NEGsColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucune facture',
                            style: TextStyle(
                              fontSize: 16,
                              color: NEGsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = _filteredInvoices[index];
                        final statusColor = invoice.isPaid
                            ? Colors.green
                            : invoice.isOverdue
                            ? Colors.red
                            : Colors.orange;

                        return GestureDetector(
                          onTap: invoice.isPaid
                              ? null
                              : () => _markAsPaid(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NEGsColors.bgWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: NEGsColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      invoice.isPaid
                                          ? Icons.check_circle
                                          : Icons.receipt,
                                      color: statusColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invoice.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: NEGsColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Échéance: ${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: NEGsColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '€${invoice.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: NEGsColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      invoice.statusLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
