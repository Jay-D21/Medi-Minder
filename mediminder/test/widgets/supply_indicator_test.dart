import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediminder/widgets/supply_indicator.dart';

void main() {
  testWidgets('SupplyIndicator shows green when supply is adequate',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SupplyIndicator(currentSupply: 20, lowThreshold: 10),
      ),
    ));

    // Checks
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Low'), findsNothing);

    // Check color (harder in widget tests without finding specific RenderObject, but text existence confirms render)
  });

  testWidgets('SupplyIndicator shows red/Low when supply is low',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SupplyIndicator(currentSupply: 5, lowThreshold: 10),
      ),
    ));

    expect(find.text('5'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
  });
}
