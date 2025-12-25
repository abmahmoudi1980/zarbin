import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/market_rate.dart';
import '../services/api_client.dart';
import '../services/analytics_service.dart';

/// MarketRateProvider - State management for market rates
///
/// Responsibilities:
/// - Fetch rates from API
/// - Cache rates locally
/// - Manage loading/error states
/// - Notify listeners when rates update
/// - Track staleness of rate data
/// - Auto-refresh rates periodically (every 5 minutes)

class MarketRateProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AnalyticsService _analytics = AnalyticsService();

  List<MarketRate> _rates = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  
  // Auto-refresh state (T004)
  Timer? _autoRefreshTimer;
  bool _isAutoRefreshing = false;
  bool _isManualRefreshing = false;
  static const Duration _autoRefreshInterval = Duration(minutes: 5);

  MarketRateProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _loadCachedRates();
  }

  // Getters
  List<MarketRate> get rates => _rates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;
  bool get isAutoRefreshing => _isAutoRefreshing; // T004

  bool get isStale {
    if (_lastFetchTime == null) return true;
    final age = DateTime.now().difference(_lastFetchTime!);
    return age.inMinutes >= 5;
  }

  int get staleMinutes {
    if (_lastFetchTime == null) return 0;
    return DateTime.now().difference(_lastFetchTime!).inMinutes;
  }

  // Load cached rates from local storage
  Future<void> _loadCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getString('cached_rates');
      final timestampStr = prefs.getString('rates_timestamp');

      if (ratesJson != null && timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        final ratesList = (jsonDecode(ratesJson) as List)
            .map((r) => MarketRate.fromJson(r))
            .toList();

        _rates = ratesList;
        _lastFetchTime = timestamp;
        notifyListeners();
      }
    } catch (e) {
      // Ignore cache loading errors
      debugPrint('Failed to load cached rates: $e');
    }
  }

  // Save rates to local storage
  Future<void> _saveCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = jsonEncode(_rates.map((r) => r.toJson()).toList());
      final timestampStr = _lastFetchTime?.toIso8601String();

      await prefs.setString('cached_rates', ratesJson);
      if (timestampStr != null) {
        await prefs.setString('rates_timestamp', timestampStr);
      }
    } catch (e) {
      debugPrint('Failed to save cached rates: $e');
    }
  }

  // Clear cached rates from local storage
  Future<void> _clearCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_rates');
      await prefs.remove('rates_timestamp');
    } catch (e) {
      debugPrint('Failed to clear cached rates: $e');
    }
  }

  // Fetch rates from API
  Future<void> fetchRates() async {
    // Don't fetch if we're already loading
    if (_isLoading) return;

    // Check if we have cached data that's still fresh
    if (_rates.isNotEmpty && !isStale) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ratesData = await _apiClient.getMarketRates();

      // Convert API response to MarketRate objects
      final ratesList = (ratesData['rates'] as List)
          .map((r) => MarketRate.fromJson(r))
          .toList();
      
      _rates = ratesList;
      _lastFetchTime = DateTime.now();
      _error = null;

      // Save to cache (or clear cache if empty)
      if (ratesList.isEmpty) {
        await _clearCachedRates();
      } else {
        await _saveCachedRates();
      }

      await _analytics.logEvent(name: 'rates_fetched');
    } catch (e, stack) {
      _error = 'Failed to fetch rates: $e';
      await _analytics.logError(e, stack, reason: 'fetch_rates_failed');
      // Keep existing rates even if fetch fails
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh rates from API (pull-to-refresh)
  // T017-T019: Coordinate with auto-refresh timer
  Future<void> refreshRates() async {
    // T017: Set manual refresh flag
    _isManualRefreshing = true;
    
    // T018: Stop auto-refresh timer during manual refresh
    stopAutoRefresh();
    
    try {
      // Force refresh regardless of cache
      _lastFetchTime = null;
      await fetchRates();
    } finally {
      // T018: Restart auto-refresh timer after manual refresh completes
      _isManualRefreshing = false;
      startAutoRefresh();
    }
  }

  // Get specific rate by type
  MarketRate? getRateByType(String rateType) {
    try {
      return _rates.firstWhere((r) => r.rateType == rateType);
    } catch (e) {
      return null;
    }
  }

  // Get USD rate
  MarketRate? get usdRate => getRateByType('usd');

  // Convenience getter for tests and simple UI
  double get currentUsdRate => usdRate?.valueInToman.toDouble() ?? 0.0;

  // Get Gold rate
  MarketRate? get goldRate => getRateByType('gold_gram');

  // Get Bahar Azadi Coin rate
  MarketRate? get baharCoinRate => getRateByType('bahar_coin');

  // Clear all data
  void clearRates() {
    _rates = [];
    _lastFetchTime = null;
    _error = null;
    notifyListeners();
  }

  // Auto-refresh methods (T005-T008)
  
  /// Start periodic auto-refresh with 5-minute interval (T005)
  void startAutoRefresh() {
    stopAutoRefresh(); // Cancel existing timer if any
    _autoRefreshTimer = Timer.periodic(
      _autoRefreshInterval,
      (timer) => _performAutoRefresh(),
    );
  }

  /// Stop periodic auto-refresh and clean up timer (T006)
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Internal: Execute auto-refresh if not already refreshing (T007)
  Future<void> _performAutoRefresh() async {
    // Skip if manual or auto refresh already in progress
    if (_isManualRefreshing || _isAutoRefreshing) {
      return;
    }

    _isAutoRefreshing = true;
    notifyListeners();

    try {
      await fetchRates();
    } catch (e) {
      // Errors are already handled in fetchRates()
      // Just ensure we reset the flag
      debugPrint('Auto-refresh error (will retry next cycle): $e');
    } finally {
      _isAutoRefreshing = false;
      notifyListeners();
    }
  }

  /// Override dispose to cancel timer (T008)
  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  // Initialize and auto-fetch on first load
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    // Fetch rates when listener is added if we don't have data or it's stale
    if (!_isLoading && (_rates.isEmpty || isStale)) {
      fetchRates();
    }
  }
}
