import 'package:uuid/uuid.dart';

class Transaction {
  final String id;
  final String name;
  final String amount;
  final String emoji;
  final DateTime date;
  final bool isIncome;
  final String category;

  Transaction({
    String? id,
    required this.name,
    required this.amount,
    required this.emoji,
    required this.date,
    required this.isIncome,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  static List<Transaction> mockTransactions = [
    Transaction(
      name: 'Netflix',
      amount: '-€12.99',
      emoji: '🎬',
      date: DateTime.now(),
      isIncome: false,
      category: 'Entertainment',
    ),
    Transaction(
      name: 'Salary',
      amount: '+€3,000',
      emoji: '💰',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isIncome: true,
      category: 'Income',
    ),
    Transaction(
      name: 'Amazon',
      amount: '-€45.50',
      emoji: '📦',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isIncome: false,
      category: 'Shopping',
    ),
    Transaction(
      name: 'Starbucks',
      amount: '-€5.20',
      emoji: '☕',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      isIncome: false,
      category: 'Food',
    ),
    Transaction(
      name: 'Transfer from John',
      amount: '+€50',
      emoji: '🤝',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isIncome: true,
      category: 'Transfer',
    ),
  ];
}
