import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:secondapp/main.dart';

void main() {
  testWidgets('SecondApp démarre', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
