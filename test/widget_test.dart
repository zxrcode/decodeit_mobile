import 'package:flutter_test/flutter_test.dart';
import 'package:encoderinfo/main.dart';

void main() {
  testWidgets('App launches test', (WidgetTester tester) async {
    await tester.pumpWidget(const DecodeItApp());
    expect(find.text('Decode It! Mobile'), findsOneWidget);
  });
}
