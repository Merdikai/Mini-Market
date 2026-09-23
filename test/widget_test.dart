// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mini_market/main.dart';
import 'package:mini_market/providers/store_provider.dart';

void main() {
  testWidgets('Mini Market app loads the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => StoreProvider(),
        child: const MiniMarketApp(),
      ),
    );

    expect(find.text('Mini Market'), findsOneWidget);
    expect(find.text('Phone X'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
