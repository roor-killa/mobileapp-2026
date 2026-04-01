class BalancePoint {
  const BalancePoint({required this.month, required this.value});

  final String month;
  final double value;

  factory BalancePoint.fromJson(Map<String, dynamic> json) {
    return BalancePoint(
      month: json['month'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DashboardTransaction {
  const DashboardTransaction({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.time,
  });

  final int id;
  final String name;
  final String category;
  final double amount;
  final String time;

  factory DashboardTransaction.fromJson(Map<String, dynamic> json) {
    return DashboardTransaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      time: json['time'] as String? ?? '',
    );
  }
}

class Insight {
  const Insight({
    required this.title,
    required this.value,
    required this.description,
    required this.trend,
  });

  final String title;
  final String value;
  final String description;
  final String trend;

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      title: json['title'] as String? ?? '',
      value: json['value'] as String? ?? '',
      description: json['description'] as String? ?? '',
      trend: json['trend'] as String? ?? '',
    );
  }
}

class DashboardPayload {
  const DashboardPayload({
    required this.balanceData,
    required this.transactions,
    required this.insights,
  });

  final List<BalancePoint> balanceData;
  final List<DashboardTransaction> transactions;
  final List<Insight> insights;

  factory DashboardPayload.fromJson(Map<String, dynamic> json) {
    final balanceRaw = json['balanceData'] as List<dynamic>? ?? [];
    final txRaw = json['transactions'] as List<dynamic>? ?? [];
    final insRaw = json['insights'] as List<dynamic>? ?? [];

    return DashboardPayload(
      balanceData: balanceRaw
          .whereType<Map<String, dynamic>>()
          .map(BalancePoint.fromJson)
          .toList(),
      transactions: txRaw
          .whereType<Map<String, dynamic>>()
          .map(DashboardTransaction.fromJson)
          .toList(),
      insights: insRaw
          .whereType<Map<String, dynamic>>()
          .map(Insight.fromJson)
          .toList(),
    );
  }
}
