import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/split_bill.dart';

class ExpenseSharingScreen extends StatefulWidget {
  const ExpenseSharingScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseSharingScreen> createState() => _ExpenseSharingScreenState();
}

class _ExpenseSharingScreenState extends State<ExpenseSharingScreen> {
  late List<SplitBill> _splitBills;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final List<String> _participants = [];
  String _splitMethod = 'equal';

  @override
  void initState() {
    super.initState();
    _splitBills = [
      SplitBill(
        id: '1',
        title: 'Restaurant - Vendredi soir',
        totalAmount: 87.50,
        participants: ['Vous', 'Marie', 'Pierre'],
        amounts: {'Vous': 29.17, 'Marie': 29.17, 'Pierre': 29.16},
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SplitBill(
        id: '2',
        title: 'Cinéma - Film Marvel',
        totalAmount: 45.00,
        participants: ['Vous', 'Sophie'],
        amounts: {'Vous': 22.50, 'Sophie': 22.50},
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  void _showCreateSplitDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: NEGsColors.bgWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Partager une dépense',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: NEGsColors.bgSecondaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Montant total (€)',
                  filled: true,
                  fillColor: NEGsColors.bgSecondaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Vous', 'Marie', 'Pierre', 'Sophie', 'Thomas'].map((
                  name,
                ) {
                  final isSelected = _participants.contains(name);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _participants.remove(name);
                        } else {
                          _participants.add(name);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NEGsColors.primaryViolet
                            : NEGsColors.bgSecondaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? NEGsColors.primaryViolet
                              : NEGsColors.borderLight,
                        ),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : NEGsColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Méthode de partage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _splitMethod = 'equal'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _splitMethod == 'equal'
                              ? NEGsColors.primaryViolet
                              : NEGsColors.bgSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _splitMethod == 'equal'
                                ? NEGsColors.primaryViolet
                                : NEGsColors.borderLight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Parts égales',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _splitMethod == 'equal'
                                  ? Colors.white
                                  : NEGsColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _splitMethod = 'custom'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _splitMethod == 'custom'
                              ? NEGsColors.primaryViolet
                              : NEGsColors.bgSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _splitMethod == 'custom'
                                ? NEGsColors.primaryViolet
                                : NEGsColors.borderLight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Personnalisé',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _splitMethod == 'custom'
                                  ? Colors.white
                                  : NEGsColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                      if (_titleController.text.isEmpty ||
                          _amountController.text.isEmpty ||
                          _participants.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Remplissez tous les champs'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final newSplit = SplitBill(
                        id: DateTime.now().toString(),
                        title: _titleController.text,
                        totalAmount: double.parse(_amountController.text),
                        participants: ['Vous', ..._participants],
                        amounts: {},
                        date: DateTime.now(),
                      );

                      setState(() {
                        _splitBills.insert(0, newSplit);
                        _titleController.clear();
                        _amountController.clear();
                        _participants.clear();
                      });

                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dépense partagée créée'),
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
                      'Créer le partage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSplitDetails(SplitBill split) {
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
            Text(
              split.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NEGsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NEGsColors.bgSecondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Montant total',
                    style: TextStyle(
                      fontSize: 12,
                      color: NEGsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${split.totalAmount.toStringAsFixed(2)}',
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
            const Text(
              'Détails du partage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NEGsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: split.participants.length,
              itemBuilder: (context, index) {
                final participant = split.participants[index];
                final amount = split.totalAmount / split.participants.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        participant,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NEGsColors.textPrimary,
                        ),
                      ),
                      Text(
                        '€${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: NEGsColors.primaryViolet,
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Résumé copié dans le presse-papiers'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Partager le résumé',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
                    'Partager les dépenses',
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
                          'Total partagé ce mois',
                          style: TextStyle(
                            fontSize: 12,
                            color: NEGsColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${_splitBills.fold(0.0, (sum, s) => sum + s.totalAmount).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: NEGsColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _splitBills.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 48,
                            color: NEGsColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucun partage',
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
                      itemCount: _splitBills.length,
                      itemBuilder: (context, index) {
                        final split = _splitBills[index];
                        return GestureDetector(
                          onTap: () => _showSplitDetails(split),
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
                                    color: NEGsColors.primaryViolet.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.people,
                                      color: NEGsColors.primaryViolet,
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
                                        split.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: NEGsColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${split.participants.length} personnes • ${split.formattedDate}',
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
                                      '€${split.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: NEGsColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '€${(split.totalAmount / split.participants.length).toStringAsFixed(2)}/p',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: NEGsColors.textSecondary,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _showCreateSplitDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Nouveau partage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
