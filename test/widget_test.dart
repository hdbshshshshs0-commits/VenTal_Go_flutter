import 'package:flutter_test/flutter_test.dart';
import 'package:vental_go/app/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const SuperApp());
    await tester.pump();
  });
}
