import 'package:flutter/foundation.dart';
import '../models/market_rate.dart';
import '../models/category_breakdown.dart';
import '../services/api_client.dart';
import '../services/analytics_service.dart';

/// Dashboard data model
class DashboardData {
  final int totalToman;
  final double totalUsdEquivalent;
  final double totalGoldGramsEquivalent;
  final String lastUpdated;

  DashboardData({
    required this.totalToman,
    required this.totalUsdEquivalent,
    required this.totalGoldGramsEquivalent,
    required this.lastUpdated,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalToman: json['total_toman'] as int? ?? 0,
      totalUsdEquivalent:
          (json['total_usd_equivalent'] as num?)?.toDouble() ?? 0.0,
      totalGoldGramsEquivalent:
          (json['total_gold_grams_equivalent'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated'] as String? ?? '',
    );
  }
}

/// DashboardProvider - State management for user's dashboard
///
/// Responsibilities:
/// - Fetch dashboard data from API
/// - Calculate equivalents based on current rates
/// - Manage loading/error states
/// - Notify listeners when dashboard updates
/// - Auto-refresh when market rates change

class DashboardProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AnalyticsService _analytics = AnalyticsService();

  DashboardData? _dashboard;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  DashboardProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  // Getters
  DashboardData? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  bool get hasBalance => _dashboard != null && _dashboard!.totalToman > 0;

  // Fetch dashboard data from API
  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dashboardJson = await _apiClient.getDashboard();
      _dashboard = DashboardData.fromJson(dashboardJson);
      _lastFetchTime = DateTime.now();
      _error = null;

      await _analytics.logEvent(name: 'dashboard_fetched');
    } catch (e, stack) {
      _error = 'Failed to fetch dashboard: $e';
      await _analytics.logError(e, stack, reason: 'fetch_dashboard_failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Recalculate equivalents based on new rates
  void updateWithNewRates(MarketRate? usdRate, MarketRate? goldRate) {
    if (_dashboard == null) return;

    final usdRateValue = usdRate?.valueInToman ?? 42500;
    final goldRateValue = goldRate?.valueInToman ?? 2150000;

    final newUsdEquivalent =
        (_dashboard!.totalToman.toDouble() / usdRateValue).round();
    final newGoldEquivalent =
        (_dashboard!.totalToman.toDouble() / goldRateValue);

    _dashboard = DashboardData(
      totalToman: _dashboard!.totalToman,
      totalUsdEquivalent: double.parse(newUsdEquivalent.toStringAsFixed(2)),
      totalGoldGramsEquivalent:
          double.parse(newGoldEquivalent.toStringAsFixed(3)),
      lastUpdated: _dashboard!.lastUpdated,
    );

    notifyListeners();
  }

  // Clear dashboard data
  void clear() {
    _dashboard = null;
    _error = null;
    notifyListeners();
  }

  // Load spending breakdown by category
  Future<CategoryBreakdownData> loadSpendingBreakdown() async {
    try {
      final response = await _apiClient.get('/transactions/summary/categories');
      return CategoryBreakdownData.fromJson(response);
    } catch (e, stack) {
      await _analytics.logError(e, stack,
          reason: 'load_spending_breakdown_failed');
      rethrow;
    }
  }
}
