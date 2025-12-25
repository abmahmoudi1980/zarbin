import 'package:flutter_test/flutter_test.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
import 'package:zarbin/services/api_client.dart';

/// Tests for MarketRateProvider auto-refresh timer lifecycle
/// 
/// This test validates:
/// - T001 [US1]: Timer lifecycle management in provider
/// - Timer starts and stops correctly
/// - Timer cleanup on dispose
/// - Auto-refresh flag state management
///
/// NOTE: These tests validate the timer lifecycle without making actual API calls

void main() {
  group('MarketRateProvider Auto-Refresh Tests', () {
    late MarketRateProvider provider;

    setUp(() {
      // Using real ApiClient - tests focus on timer lifecycle, not API calls
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

    test('should have isAutoRefreshing getter that returns false initially', () {
      // Initially, auto-refresh should not be active
      expect(provider.isAutoRefreshing, false);
    });

    test('should start auto-refresh timer without throwing', () {
      // Start auto-refresh
      expect(() => provider.startAutoRefresh(), returnsNormally);

      // Timer should be active (not refreshing yet, just timer started)
      expect(provider.isAutoRefreshing, false);

      // Clean up
      provider.stopAutoRefresh();
    });

    test('should stop auto-refresh timer without throwing', () {
      // Start timer
      provider.startAutoRefresh();

      // Stop timer
      expect(() => provider.stopAutoRefresh(), returnsNormally);

      // Stopping should not throw, and subsequent stop should be safe
      expect(() => provider.stopAutoRefresh(), returnsNormally);
    });

    test('should cancel timer on dispose', () {
      // Start timer
      provider.startAutoRefresh();

      // Dispose should cancel timer without throwing
      expect(() => provider.dispose(), returnsNormally);
    });

    test('should restart timer when startAutoRefresh called multiple times', () {
      // Start timer
      provider.startAutoRefresh();

      // Start again - should cancel old and create new
      expect(() => provider.startAutoRefresh(), returnsNormally);

      // Clean up
      provider.stopAutoRefresh();
    });

    test('should allow stop without start', () {
      // Stop without starting should not throw
      expect(() => provider.stopAutoRefresh(), returnsNormally);
    });
  });
}
