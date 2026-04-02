// This is a basic Flutter widget test for NEG's Banking App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:negs_bank/main.dart';

void main() {
  testWidgets('NEG\'s app launches splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NEGsApp());

    // Verify that splash screen appears
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.text('NEG\'s'), findsWidgets);

    // Wait for splash to complete
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
