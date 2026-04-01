import 'package:flutter_test/flutter_test.dart';

import 'package:mobileapp_prjtst/models/tx.dart';

void main() {
  test('Tx.fromJson parses numeric fields safely', () {
    final tx = Tx.fromJson({
      'id': 7,
      'type': 'BUY',
      'amount_bkn': 12.5,
      'status': 'OK',
      'created_at': '2026-02-21T00:00:00Z',
    });

    expect(tx.id, 7);
    expect(tx.type, 'BUY');
    expect(tx.amountBkn, 12.5);
    expect(tx.status, 'OK');
    expect(tx.createdAt, contains('2026'));
  });
}
