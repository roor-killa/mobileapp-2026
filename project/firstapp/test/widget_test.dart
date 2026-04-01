import 'package:flutter_test/flutter_test.dart';
import 'package:firstapp/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AppLoader());
    await tester.pump();
    // Vérifie que l'app se lance sans exception
    expect(tester.takeException(), isNull);
  });
}
