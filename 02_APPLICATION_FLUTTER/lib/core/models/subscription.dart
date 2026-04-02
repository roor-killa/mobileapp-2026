class Subscription {
  final String id;
  final String name;
  final String icon;
  final double monthlyPrice;
  DateTime? nextBillingDate;
  bool isActive;

  Subscription({
    required this.id,
    required this.name,
    required this.icon,
    required this.monthlyPrice,
    required this.nextBillingDate,
    this.isActive = true,
  });

  String get nextBillingDisplay {
    if (nextBillingDate == null) return 'Inactive';
    return '${nextBillingDate!.day}/${nextBillingDate!.month}/${nextBillingDate!.year}';
  }
}
