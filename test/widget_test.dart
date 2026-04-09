import 'package:flutter_test/flutter_test.dart';
import 'package:open_grid/main.dart';

void main() {
  testWidgets('Open Grid app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const OpenGridApp());
    expect(find.text('OPEN GRID'), findsOneWidget);
  });
}
