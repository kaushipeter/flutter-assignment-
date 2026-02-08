import 'package:flutter_test/flutter_test.dart';
import 'package:aura_mobile/main.dart';

void main() {
  testWidgets('App starts and shows Logo/Brand text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuraApp());

    // Verify that the brand name "AURA" is present
    expect(find.text('AURA'), findsOneWidget);
  });
}
