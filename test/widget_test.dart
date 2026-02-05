// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:money_gua/main.dart';

void main() {
  testWidgets('Money Gua app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyGuaApp());

    // Verify that the app title is displayed.
    expect(find.text('金钱卦 (Money Gua)'), findsOneWidget);

    // Verify that the analyze button is present.
    expect(find.text('解读卦象'), findsOneWidget);
  });
}
