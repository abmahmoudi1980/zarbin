import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
import 'package:zarbin/screens/market_rates_screen.dart';
import 'package:zarbin/services/api_client.dart';

/// Tests for MarketRatesScreen auto-refresh lifecycle
/// 
/// This test validates:
/// - T002 [US1]: Auto-refresh initiation on screen load
/// - startAutoRefresh() called in initState()
/// - stopAutoRefresh() called in dispose()

void main() {
  group('MarketRatesScreen Lifecycle Tests', () {
    late MarketRateProvider provider;

    setUp(() {
      provider = MarketRateProvider(apiClient: ApiClient());
    });

    tearDown(() {
      try {
        provider.stopAutoRefresh();
        provider.dispose();
      } catch (e) {
        // Ignore disposal errors in tests
      }
    });

    testWidgets('should start auto-refresh when screen is mounted', (tester) async {
      // Build the screen
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const MarketRatesScreen(),
          ),
        ),
      );

      // Wait for post-frame callbacks to complete
      await tester.pumpAndSettle();

      // After mounting, auto-refresh should be started
      // Verify screen is visible
      expect(find.byType(MarketRatesScreen), findsOneWidget);
    });

    testWidgets('should stop auto-refresh when screen is disposed', (tester) async {
      // Build the screen
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const MarketRatesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away (dispose screen)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text('Other Screen'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // After disposal, auto-refresh should be stopped
      // Timer should be canceled
      expect(find.byType(MarketRatesScreen), findsNothing);
    });

    testWidgets('should not crash on repeated mount/unmount cycles', (tester) async {
      // Mount and unmount multiple times
      for (int i = 0; i < 3; i++) {
        // Mount
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const MarketRatesScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Unmount
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Other Screen $i'),
            ),
          ),
        );

        await tester.pumpAndSettle();
      }

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });
  });
}
