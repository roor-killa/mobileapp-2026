class HistoryEntry {
  final String coinId;
  final DateTime createdAt;
  final double currentPrice;
  final int horizonDays;
  final List<double> predictedPrices;
  final String model;

  const HistoryEntry({
    required this.coinId,
    required this.createdAt,
    required this.currentPrice,
    required this.horizonDays,
    required this.predictedPrices,
    required this.model,
  });

  double get predictedLast =>
      predictedPrices.isEmpty ? currentPrice : predictedPrices.last;

  Map<String, dynamic> toJson() => {
        "coinId": coinId,
        "createdAt": createdAt.toIso8601String(),
        "currentPrice": currentPrice,
        "horizonDays": horizonDays,
        "predictedPrices": predictedPrices,
        "model": model,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      coinId: json["coinId"] as String,
      createdAt: DateTime.parse(json["createdAt"] as String),
      currentPrice: (json["currentPrice"] as num).toDouble(),
      horizonDays: (json["horizonDays"] as num).toInt(),
      predictedPrices: (json["predictedPrices"] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      model: (json["model"] as String?) ?? "unknown",
    );
  }
}
