import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/budget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late List<Budget> _budgets;

  @override
  void initState() {
    super.initState();
    _budgets = [
      Budget(
        id: '1',
        category: 'Alimentation',
        limit: 500,
        spent: 350,
        icon: '🍔',
      ),
      Budget(id: '2', category: 'Loisirs', limit: 200, spent: 180, icon: '🎬'),
      Budget(
        id: '3',
        category: 'Transport',
        limit: 150,
        spent: 120,
        icon: '🚗',
      ),
      Budget(id: '4', category: 'Santé', limit: 100, spent: 45, icon: '⚕️'),
      Budget(
        id: '5',
        category: 'Vêtements',
        limit: 300,
        spent: 280,
        icon: '👔',
      ),
      Budget(
        id: '6',
        category: 'Abonnements',
        limit: 100,
        spent: 110,
        icon: '📱',
      ),
    ];
  }

  double get _totalBudget {
    return _budgets.fold(0, (sum, b) => sum + b.limit);
  }

  double get _totalSpent {
    return _budgets.fold(0, (sum, b) => sum + b.spent);
  }

  void _editBudget(int index) {
    final budget = _budgets[index];
    final limitController = TextEditingController(
      text: budget.limit.toString(),
    );
    final spentController = TextEditingController(
      text: budget.spent.toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: NEGsColors.bgWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modifier ${budget.category}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NEGsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Limite mensuelle (€)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: NEGsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
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
              'Montant dépensé (€)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: NEGsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: spentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
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
                      _budgets[index] = Budget(
                        id: budget.id,
                        category: budget.category,
                        limit: double.parse(limitController.text),
                        spent: double.parse(spentController.text),
                        icon: budget.icon,
                      );
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Budget mis à jour'),
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
                    'Enregistrer',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budget mensuel',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Overview cards
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                            'Budget total',
                            style: TextStyle(
                              fontSize: 12,
                              color: NEGsColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '€${_totalBudget.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: NEGsColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
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
                            'Dépensé',
                            style: TextStyle(
                              fontSize: 12,
                              color: NEGsColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '€${_totalSpent.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: NEGsColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
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
                            'Restant',
                            style: TextStyle(
                              fontSize: 12,
                              color: NEGsColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '€${(_totalBudget - _totalSpent).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: (_totalBudget - _totalSpent) > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Par catégorie',
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
                itemCount: _budgets.length,
                itemBuilder: (context, index) {
                  final budget = _budgets[index];
                  final statusColor = budget.isExceeded
                      ? Colors.red
                      : budget.isNearLimit
                      ? Colors.orange
                      : Colors.green;

                  return GestureDetector(
                    onTap: () => _editBudget(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NEGsColors.bgWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: budget.isExceeded
                              ? Colors.red
                              : NEGsColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      budget.icon,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            budget.category,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: NEGsColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '€${budget.spent.toStringAsFixed(2)} / €${budget.limit.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: NEGsColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${(budget.percentageUsed * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      budget.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: budget.percentageUsed > 1
                                  ? 1
                                  : budget.percentageUsed,
                              minHeight: 8,
                              backgroundColor: NEGsColors.borderLight,
                              valueColor: AlwaysStoppedAnimation(statusColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
