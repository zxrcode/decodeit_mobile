import 'package:flutter_test/flutter_test.dart';
import 'package:encoderinfo/main.dart';
import 'package:encoderinfo/core/di.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUp(() async {
    await GetIt.instance.reset();
    setupDependencies();
  });

  testWidgets('App launches test', (WidgetTester tester) async {
    await tester.pumpWidget(const DecodeItApp());
    expect(find.text('PCM Дыбыс'), findsOneWidget);
  });
}
