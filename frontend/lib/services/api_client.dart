// lib/services/api_client.dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'secure_storage.dart';
import 'analytics_service.dart';

class ApiClient {
  late Dio _dio;
  String? _token;
  final AnalyticsService _analytics = AnalyticsService();

  ApiClient() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Zarbin/1.0',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(this));
    _dio.interceptors.add(_AnalyticsInterceptor(_analytics));
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }

  Dio get dio => _dio;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // POST request helper
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('POST $path failed: ${e.message}');
    }
  }

  // GET request helper
  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('GET $path failed: ${e.message}');
    }
  }

  // PUT request helper
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('PUT $path failed: ${e.message}');
    }
  }

  // DELETE request helper
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('DELETE $path failed: ${e.message}');
    }
  }

  // Authentication Endpoints
  Future<Response<dynamic>> generateOtp(String mobileNumber) async {
    return _dio.post(
      '${ApiConfig.authEndpoint}/generate-otp',
      data: {'mobile_number': mobileNumber},
    );
  }

  Future<Response<dynamic>> verifyOtp(String mobileNumber, String code) async {
    return _dio.post(
      '${ApiConfig.authEndpoint}/verify-otp',
      data: {
        'mobile_number': mobileNumber,
        'otp_code': code,
      },
    );
  }

  Future<Response<dynamic>> resendOtp(String mobileNumber) async {
    return _dio.post(
      '${ApiConfig.authEndpoint}/resend-otp',
      data: {'mobile_number': mobileNumber},
    );
  }

  Future<Response<dynamic>> logout() async {
    return _dio.post('${ApiConfig.authEndpoint}/logout');
  }

  // Rates Endpoints
  Future<Response<dynamic>> getLatestRates() async {
    return _dio.get('${ApiConfig.ratesEndpoint}/latest');
  }

  // Get all current market rates (main endpoint for MarketRatesScreen)
  Future<Map<String, dynamic>> getMarketRates() async {
    try {
      final response = await _dio.get(ApiConfig.ratesEndpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to fetch market rates: ${e.message}');
    }
  }

  Future<Response<dynamic>> getRate(String rateType) async {
    return _dio.get('${ApiConfig.ratesEndpoint}/current/$rateType');
  }

  // Categories Endpoints
  Future<Response<dynamic>> getCategories() async {
    return _dio.get(ApiConfig.categoriesEndpoint);
  }

  Future<Response<dynamic>> seedCategories() async {
    return _dio.post('${ApiConfig.categoriesEndpoint}/seed');
  }

  // Transactions Endpoints
  Future<Response<dynamic>> getTransactions() async {
    return _dio.get(ApiConfig.transactionsEndpoint);
  }

  Future<Response<dynamic>> createTransaction(Map<String, dynamic> data) async {
    return _dio.post(ApiConfig.transactionsEndpoint, data: data);
  }

  Future<Response<dynamic>> updateTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _dio.patch('${ApiConfig.transactionsEndpoint}/$id', data: data);
  }

  Future<Response<dynamic>> deleteTransaction(String id) async {
    return _dio.delete('${ApiConfig.transactionsEndpoint}/$id');
  }

  Future<Response<dynamic>> getTransactionsMonthlySummary(
    int year,
    int month,
  ) async {
    return _dio.get(
      '${ApiConfig.transactionsEndpoint}/summary/monthly',
      queryParameters: {'year': year, 'month': month},
    );
  }

  // User Balance Endpoints
  Future<Response<dynamic>> getUserBalance() async {
    return _dio.get('${ApiConfig.baseUrl}/api/v1/user-balance');
  }

  // Dashboard Endpoints
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/api/v1/dashboard');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to fetch dashboard: ${e.message}');
    }
  }
}

class _AuthInterceptor extends QueuedInterceptorsManager {
  final ApiClient apiClient;
  bool _isRefreshing = false;
  final List<DioException> _failedQueue = [];

  _AuthInterceptor(this.apiClient);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = apiClient._token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      
      try {
        // Try to refresh the token
        final token = apiClient._token;
        if (token != null) {
          final response = await apiClient._dio.post(
            '${ApiConfig.authEndpoint}/refresh',
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
          
          if (response.statusCode == 200) {
            final data = response.data as Map<String, dynamic>;
            final newToken = data['data']['token'] as String;
            
            // Save new token
            await SecureStorage().saveToken(newToken);
            apiClient.setToken(newToken);
            
            // Retry the failed request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            
            _isRefreshing = false;
            
            // Retry the original request
            final retryResponse = await apiClient._dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Token refresh failed, clear storage and redirect to login
        await SecureStorage().clearAll();
        apiClient.clearToken();
      }
      
      _isRefreshing = false;
    }
    
    super.onError(err, handler);
  }
}

class _AnalyticsInterceptor extends Interceptor {
  final AnalyticsService _analytics;

  _AnalyticsInterceptor(this._analytics);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _analytics.logError(
      err,
      err.stackTrace,
      reason: 'api_error: ${err.requestOptions.path}',
    );
    
    _analytics.setCustomKey('api_path', err.requestOptions.path);
    _analytics.setCustomKey('api_method', err.requestOptions.method);
    if (err.response != null) {
      _analytics.setCustomKey('api_status_code', err.response!.statusCode ?? 0);
    }

    super.onError(err, handler);
  }
}
