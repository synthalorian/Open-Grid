import 'package:flutter_test/flutter_test.dart';
import 'package:open_grid/main.dart';

void main() {
  testWidgets('GridTape app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GridTapeApp());
    expect(find.text('GRIDTAPE'), findsOneWidget);
  });
}
