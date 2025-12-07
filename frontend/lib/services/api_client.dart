// lib/services/api_client.dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'secure_storage_service.dart';

class ApiClient {
  late Dio _dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
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
    _dio.interceptors.add(ApiInterceptor());
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

class ApiInterceptor extends QueuedInterceptorsManager {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageService.getToken();
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
      // Token expired, clear it and redirect to login
      SecureStorageService.clearAll();
      // This should trigger a redirect to login screen in the app
    }
    super.onError(err, handler);
  }
}
