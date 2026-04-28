import 'package:flutter_test/flutter_test.dart';
import 'package:namma_shield/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NammaShieldApp());
    await tester.pumpAndSettle();

    expect(find.byType(NammaShieldApp), findsOneWidget);
  });
}
