// lib/services/api_client.dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'secure_storage.dart';

class ApiClient {
  late Dio _dio;
  String? _token;

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
}

class _AuthInterceptor extends QueuedInterceptorsManager {
  final ApiClient apiClient;

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Token expired, clear it
      SecureStorage().clearAll();
      apiClient.clearToken();
    }
    super.onError(err, handler);
  }
}
