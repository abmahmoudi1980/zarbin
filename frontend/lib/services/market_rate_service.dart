// lib/services/market_rate_service.dart
import 'package:dio/dio.dart';
import '../models/market_rate.dart';
import 'api_client.dart';
import 'hive_service.dart';

class MarketRateService {
  static final MarketRateService _instance = MarketRateService._internal();
  final ApiClient _apiClient = ApiClient();

  factory MarketRateService() {
    return _instance;
  }

  MarketRateService._internal();

  // Get latest rates from API or cache
  Future<List<MarketRate>> getLatestRates({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh && HiveService.isMarketRatesCached()) {
      final cached = HiveService.getMarketRates();
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    try {
      final response = await _apiClient.getLatestRates();
      if (response.statusCode == 200) {
        final ratesData = response.data['rates'] as List;
        final rates = ratesData
            .map((r) => MarketRate.fromJson(r as Map<String, dynamic>))
            .toList();
        
        // Cache the rates
        await HiveService.saveMarketRates(rates);
        return rates;
      }
      return [];
    } on DioException catch (_) {
      // Return cached rates if API fails
      return HiveService.getMarketRates();
    }
  }

  // Get specific rate type
  Future<MarketRate?> getRate(String rateType) async {
    try {
      // Check cache first
      var cached = HiveService.getMarketRateByType(rateType);
      if (cached != null && !cached.isStale) {
        return cached;
      }

      final response = await _apiClient.getRate(rateType);
      if (response.statusCode == 200) {
        return MarketRate.fromJson(response.data as Map<String, dynamic>);
      }
      return cached;
    } on DioException catch (_) {
      // Return cached rate if API fails
      return HiveService.getMarketRateByType(rateType);
    }
  }

  // Convert amount from Toman to target currency
  Future<Map<String, dynamic>> convertFromToman(
    int amountToman,
    String targetCurrency,
  ) async {
    try {
      final rate = await getRate(targetCurrency);
      if (rate != null) {
        return {
          'success': true,
          'amount_toman': amountToman,
          'amount_in_currency': rate.convertFromToman(amountToman),
          'currency': targetCurrency,
          'rate': rate.valueInToman,
          'rate_label': rate.rateLabel,
        };
      }
      return {
        'success': false,
        'error': 'Rate not found',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Conversion failed',
      };
    }
  }

  // Convert amount from currency to Toman
  Future<Map<String, dynamic>> convertToToman(
    double amount,
    String sourceCurrency,
  ) async {
    try {
      final rate = await getRate(sourceCurrency);
      if (rate != null) {
        return {
          'success': true,
          'amount_in_currency': amount,
          'amount_toman': rate.convertToToman(amount),
          'currency': sourceCurrency,
          'rate': rate.valueInToman,
          'rate_label': rate.rateLabel,
        };
      }
      return {
        'success': false,
        'error': 'Rate not found',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Conversion failed',
      };
    }
  }

  // Refresh rates (force API call)
  Future<List<MarketRate>> refreshRates() async {
    return getLatestRates(forceRefresh: true);
  }

  // Check if rates are stale
  bool areRatesCached() {
    return HiveService.isMarketRatesCached();
  }
}
