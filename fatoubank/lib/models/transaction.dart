import 'package:flutter/material.dart';
import 'package:fatoubank/models/transaction_type.dart';

class Transaction {
  final String name;
  final double amount;
  final String date;
  final TransactionType type;
  final IconData icon;

  Transaction({
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
  });
}