import 'package:firstapp/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Transaction.fromJson parses minimal JSON', () {
    final json = {
      'id': 1,
      'from_account_id': 10,
      'to_account_id': 20,
      'transaction_type': 'transfer',
      'amount': '123.45',
      'description': 'Test',
      'status': 'completed',
      'reference_number': 'TRF123',
      'transaction_date': '2025-03-01T12:00:00Z',
      'direction': 'outgoing',
      'from_account': {
        'id': 10,
        'owner': {'name': 'Jean Dupont'},
      },
      'to_account': {
        'id': 20,
        'owner': {'name': 'Marie Martin'},
      },
    };

    final t = Transaction.fromJson(json);

    expect(t.id, 1);
    expect(t.amount, 123.45);
    expect(t.direction, 'outgoing');
    expect(t.fromOwnerName, 'Jean Dupont');
    expect(t.toOwnerName, 'Marie Martin');
  });

  test('Account.fromJson parses correctly', () {
    final json = {
      'id': 1,
      'account_number': 'ACC0001',
      'account_type': 'Compte Chèques',
      'balance': '1000.50',
      'currency': 'EUR',
      'iban': 'FR761234',
      'is_active': true,
    };

    final a = Account.fromJson(json);

    expect(a.id, 1);
    expect(a.accountType, 'Compte Chèques');
    expect(a.balance, 1000.50);
    expect(a.isActive, true);
  });
}

