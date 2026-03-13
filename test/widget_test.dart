import 'package:flutter_test/flutter_test.dart';
import 'package:memory_card_game/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const KiokiApp());
    expect(find.text('KIOKI'), findsOneWidget);
  });
}
