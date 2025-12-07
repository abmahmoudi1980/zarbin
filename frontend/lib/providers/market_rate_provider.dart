import 'package:flutter/foundation.dart';
import '../models/market_rate.dart';
import '../services/api_client.dart';

/// MarketRateProvider - State management for market rates
/// 
/// Responsibilities:
/// - Fetch rates from API
/// - Cache rates locally
/// - Manage loading/error states
/// - Notify listeners when rates update
/// - Track staleness of rate data

class MarketRateProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  List<MarketRate> _rates = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  
  // Cache duration - rates auto-expire after 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  MarketRateProvider({required ApiClient apiClient}) : _apiClient = apiClient;
  
  // Getters
  List<MarketRate> get rates => _rates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;
  
  bool get isStale {
    if (_lastFetchTime == null) return true;
    final age = DateTime.now().difference(_lastFetchTime!);
    return age.inMinutes >= 5;
  }
  
  int get staleMinutes {
    if (_lastFetchTime == null) return 0;
    return DateTime.now().difference(_lastFetchTime!).inMinutes;
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
      _rates = (ratesData['rates'] as List)
          .map((r) => MarketRate.fromJson(r))
          .toList();
      
      _lastFetchTime = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch rates: $e';
      // Keep existing rates even if fetch fails
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Refresh rates from API (pull-to-refresh)
  Future<void> refreshRates() async {
    // Force refresh regardless of cache
    _lastFetchTime = null;
    await fetchRates();
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
  
  // Initialize and auto-fetch on first load
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    // Fetch rates when first listener is added
    if (_rates.isEmpty && !_isLoading) {
      fetchRates();
    }
  }
}
