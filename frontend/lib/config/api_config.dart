// Flutter API Client Configuration
// Located at: frontend/lib/config/api_config.dart

class ApiConfig {
  // API Base URLs based on environment
  static const String _devBaseUrl = 'http://localhost:3000/api/v1';
  static const String _prodBaseUrl = 'https://api.zarbin.app/api/v1';

  // Environment
  static const bool isProduction = bool.fromEnvironment('kReleaseMode', defaultValue: false);

  // Base URL
  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;

  // Timeouts (in seconds)
  static const int connectTimeout = 10;
  static const int receiveTimeout = 15;
  static const int sendTimeout = 10;

  // API Endpoints
  static const String authRegister = '/auth/register';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authLogin = '/auth/login';

  static const String marketRates = '/rates';
  static const String marketRatesHistory = '/rates/history';

  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String balance = '/balance';
  static const String categories = '/categories';
  static const String dashboard = '/dashboard';

  // Market Data Cache Duration (minutes)
  static const int cacheMarketRatesDuration = 5;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // JWT Token Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableTransactionSync = true;
  static const bool enableAnalytics = true;

  // Localization
  static const String defaultLocale = 'fa'; // Persian/Farsi
  static const List<String> supportedLocales = ['fa', 'en'];

  // Dates (Jalali Calendar)
  static const bool useJalaliDatesOnly = true; // v1.0 requirement

  // Logging
  static const bool enableApiLogging = true;
  static const bool enableErrorLogging = true;

  // SMS Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int maxOtpAttempts = 3;

  // Account Security
  static const int maxLoginAttempts = 5;
  static const int accountLockoutMinutes = 15;
  static const int sessionDurationDays = 7;
}
