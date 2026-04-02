class SplitBill {
  final String id;
  final String title;
  final double totalAmount;
  final List<String> participants;
  final Map<String, double> amounts;
  final DateTime date;

  SplitBill({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.participants,
    required this.amounts,
    required this.date,
  });

  Map<String, double> calculateSplit(String method) {
    if (method == 'equal') {
      final perPerson = totalAmount / participants.length;
      return {for (var p in participants) p: perPerson};
    }
    return amounts;
  }

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
