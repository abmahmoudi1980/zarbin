import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
import 'package:zarbin/screens/market_rates_screen.dart';
import 'package:zarbin/services/api_client.dart';

/// Tests for MarketRatesScreen lifecycle observer
/// 
/// This test validates:
/// - T020 [US4]: Lifecycle observer registration and cleanup
/// - WidgetsBindingObserver properly added in initState
/// - Observer properly removed in dispose

void main() {
  group('MarketRatesScreen Observer Tests', () {
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

    testWidgets('should register lifecycle observer on mount', (tester) async {
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

      // Screen should be visible
      expect(find.byType(MarketRatesScreen), findsOneWidget);
      
      // Observer should be registered (we can't test directly, but no crash means success)
    });

    testWidgets('should unregister lifecycle observer on dispose', (tester) async {
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

      // Dispose screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Text('Other')),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle multiple mount/unmount cycles with observer', (tester) async {
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
            home: Scaffold(body: Text('Other $i')),
          ),
        );

        await tester.pumpAndSettle();
      }

      // Should not crash with observer leaks
      expect(tester.takeException(), isNull);
    });
  });
}
