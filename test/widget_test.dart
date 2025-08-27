import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tour_group_expense/main.dart'; // তোমার main.dart root widget import

void main() {
  testWidgets('App loads and shows Home Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // const ছাড়া safe

    // Verify that the bottom navigation bar tabs are visible.
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
  });
}
