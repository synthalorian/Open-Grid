import 'package:flutter_test/flutter_test.dart';
import 'package:gridtape/main.dart';

void main() {
  testWidgets('GridTape app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GridTapeApp());
    expect(find.text('GRIDTAPE'), findsOneWidget);
  });
}
