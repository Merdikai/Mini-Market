import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mini_market/main.dart';
import 'package:mini_market/providers/store_provider.dart';

void main() {
  testWidgets('Mini Market app loads the home screen with luxury products', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => StoreProvider(),
        child: const MiniMarketApp(),
      ),
    );

    // Let the animations settle
    await tester.pumpAndSettle();

    expect(find.text('MINI MARKET'), findsOneWidget);
    expect(find.text('Ora Chrono Geneva 01'), findsWidgets);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
