class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Account {
  final int id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String currency;
  final String iban;
  final bool isActive;

  Account({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.iban,
    required this.isActive,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      accountNumber: json['account_number'],
      accountType: json['account_type'],
      balance: double.parse(json['balance'].toString()),
      currency: json['currency'],
      iban: json['iban'],
      isActive: json['is_active'],
    );
  }
}

class Transaction {
  final int id;
  final int fromAccountId;
  final int? toAccountId;
  final String transactionType;
  final double amount;
  final String description;
  final String status;
  final String referenceNumber;
  final DateTime transactionDate;
  final String? direction;
  final String? fromOwnerName;
  final String? toOwnerName;

  Transaction({
    required this.id,
    required this.fromAccountId,
    this.toAccountId,
    required this.transactionType,
    required this.amount,
    required this.description,
    required this.status,
    required this.referenceNumber,
    required this.transactionDate,
    this.direction,
    this.fromOwnerName,
    this.toOwnerName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    String? readOwnerName(dynamic accountJson) {
      try {
        final acc = accountJson as Map<String, dynamic>?;
        final owner = acc?['owner'] as Map<String, dynamic>?;
        final name = owner?['name'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      } catch (_) {
        // ignore
      }
      return null;
    }

    return Transaction(
      id: json['id'],
      fromAccountId: json['from_account_id'],
      toAccountId: json['to_account_id'],
      transactionType: json['transaction_type'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'] ?? '',
      status: json['status'],
      referenceNumber: json['reference_number'],
      transactionDate: DateTime.parse(json['transaction_date']),
      direction: json['direction'],
      fromOwnerName: readOwnerName(json['from_account']),
      toOwnerName: readOwnerName(json['to_account']),
    );
  }
}

class BeneficiaryAccount {
  final int id;
  final String accountType;
  final String accountNumber;
  final String iban;
  final String currency;
  final String ownerName;
  /// ID de l'utilisateur propriétaire du compte (pour demandes d'argent).
  final int? ownerId;

  BeneficiaryAccount({
    required this.id,
    required this.accountType,
    required this.accountNumber,
    required this.iban,
    required this.currency,
    required this.ownerName,
    this.ownerId,
  });

  factory BeneficiaryAccount.fromJson(Map<String, dynamic> json) {
    final owner = (json['owner'] as Map<String, dynamic>?) ?? const {};
    return BeneficiaryAccount(
      id: json['id'],
      accountType: json['account_type'] ?? '',
      accountNumber: json['account_number'] ?? '',
      iban: json['iban'] ?? '',
      currency: json['currency'] ?? 'EUR',
      ownerName: owner['name'] ?? 'Bénéficiaire',
      ownerId: owner['id'] is int ? owner['id'] as int : null,
    );
  }
}
