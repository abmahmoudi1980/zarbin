// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbin/main.dart';
import 'package:zarbin/providers/auth_provider.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
import 'package:zarbin/providers/dashboard_provider.dart';
import 'package:zarbin/providers/transaction_provider.dart';
import 'package:zarbin/services/api_client.dart';
import 'package:zarbin/services/secure_storage.dart';
import 'package:zarbin/services/database_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ZarbinApp(
      authProvider: AuthProvider(apiClient: ApiClient(), secureStorage: SecureStorage()),
      marketRateProvider: MarketRateProvider(apiClient: ApiClient()),
      dashboardProvider: DashboardProvider(apiClient: ApiClient()),
      transactionProvider: TransactionProvider(apiClient: ApiClient(), databaseService: DatabaseService()),
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
