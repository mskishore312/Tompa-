import 'package:flutter_test/flutter_test.dart';
import 'package:tompa/main.dart';

void main() {
  testWidgets('TOMPA app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const TompaApp());
    expect(find.text('TOMPA'), findsOneWidget);
  });
}
