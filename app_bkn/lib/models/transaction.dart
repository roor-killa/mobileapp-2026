import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final TransactionType type;
  final double montant;
  final DateTime date;
  final String description;
  final String? destinataire;
  final String? expediteur;

  Transaction({
    required this.id,
    required this.type,
    required this.montant,
    required this.date,
    required this.description,
    this.destinataire,
    this.expediteur,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui à ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Hier à ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String get sign => type == TransactionType.achat || type == TransactionType.reception ? '+' : '-';
  
  Color get color {
    switch (type) {
      case TransactionType.achat:
      case TransactionType.reception:
        return const Color(0xFF00C9A7);
      case TransactionType.vente:
      case TransactionType.transfert:
        return const Color(0xFFFF6B6B);
    }
  }

  IconData get icon {
    switch (type) {
      case TransactionType.achat:
        return Icons.arrow_downward;
      case TransactionType.vente:
        return Icons.arrow_upward;
      case TransactionType.transfert:
        return Icons.send;
      case TransactionType.reception:
        return Icons.call_received;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'montant': montant,
      'date': date.toIso8601String(),
      'description': description,
      'destinataire': destinataire,
      'expediteur': expediteur,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      montant: json['montant']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      description: json['description'],
      destinataire: json['destinataire'],
      expediteur: json['expediteur'],
    );
  }
}

enum TransactionType {
  achat,
  vente,
  transfert,
  reception;
}