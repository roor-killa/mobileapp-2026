class Budget {
  final String id;
  final String category;
  final double limit;
  double spent;
  final String icon;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    this.spent = 0,
    required this.icon,
  });

  double get remainingBudget => limit - spent;
  double get percentageUsed => spent / limit;
  bool get isExceeded => spent > limit;
  bool get isNearLimit => percentageUsed > 0.80;

  String get status {
    if (isExceeded) return 'Dépassé';
    if (isNearLimit) return 'Limite proche';
    return 'En cours';
  }
}
