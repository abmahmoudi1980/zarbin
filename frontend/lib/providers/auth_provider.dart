import 'package:flutter/foundation.dart';
import 'package:zarbin/services/api_client.dart';
import 'package:zarbin/services/secure_storage.dart';
import 'package:zarbin/models/user.dart';
import 'package:zarbin/services/analytics_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final AnalyticsService _analytics = AnalyticsService();

  User? _currentUser;
  String? _token;
  String? _error;
  bool _isLoading = false;

  AuthProvider({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _currentUser != null;

  // Register user
  Future<bool> registerUser({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'auth': {
            'mobile_number': mobileNumber,
            'password': password,
          },
        },
      );

      if (response['success'] == true) {
        // Save mobile number for OTP verification
        await _secureStorage.savePendingMobileNumber(mobileNumber);
        await _analytics.logSignUp(method: 'mobile_number');
        notifyListeners();
        return true;
      } else {
        _setError(response['error'] ?? 'Registration failed');
        return false;
      }
    } catch (e, stack) {
      _setError('Registration error: $e');
      await _analytics.logError(e, stack, reason: 'registration_failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({
    required String mobileNumber,
    required String otpCode,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiClient.post(
        '/auth/verify-otp',
        data: {
          'otp': {
            'mobile_number': mobileNumber,
            'otp_code': otpCode,
          },
        },
      );

      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];
        _currentUser = User.fromJson(data);

        // Save token
        await _secureStorage.saveToken(_token!);
        await _secureStorage.savePendingMobileNumber(''); // Clear pending
        
        await _analytics.setUserId(_currentUser!.id.toString());
        await _analytics.logEvent(name: 'otp_verified');

        notifyListeners();
        return true;
      } else {
        _setError(response['error'] ?? 'OTP verification failed');
        return false;
      }
    } catch (e, stack) {
      _setError('OTP verification error: $e');
      await _analytics.logError(e, stack, reason: 'otp_verification_failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<bool> resendOtp(String mobileNumber) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'auth': {
            'mobile_number': mobileNumber,
          },
        },
      );

      if (response['success'] == true) {
        await _analytics.logEvent(name: 'otp_resent');
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to resend OTP');
        return false;
      }
    } catch (e, stack) {
      _setError('Resend OTP error: $e');
      await _analytics.logError(e, stack, reason: 'resend_otp_failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> loginUser({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'auth': {
            'mobile_number': mobileNumber,
            'password': password,
          },
        },
      );

      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];
        _currentUser = User.fromJson(data);

        // Save token
        await _secureStorage.saveToken(_token!);

        // Set API client token
        _apiClient.setToken(_token!);

        await _analytics.setUserId(_currentUser!.id.toString());
        await _analytics.logLogin(method: 'mobile_number');

        notifyListeners();
        return true;
      } else {
        _setError(response['error'] ?? 'Login failed');
        return false;
      }
    } catch (e, stack) {
      _setError('Login error: $e');
      await _analytics.logError(e, stack, reason: 'login_failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      if (_token == null) {
        return false;
      }

      final response = await _apiClient.post('/auth/refresh');

      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];

        // Save new token
        await _secureStorage.saveToken(_token!);
        _apiClient.setToken(_token!);

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      _setLoading(true);

      // Clear local data
      _currentUser = null;
      _token = null;
      _clearError();

      // Clear secure storage
      await _secureStorage.deleteToken();

      // Reset API client
      _apiClient.clearToken();

      notifyListeners();
    } catch (e) {
      _setError('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load stored token and restore session
  Future<bool> restoreSession() async {
    try {
      _setLoading(true);

      final token = await _secureStorage.getToken();
      if (token == null) {
        return false;
      }

      _token = token;
      _apiClient.setToken(token);

      // Optionally verify token is still valid by making a request
      // For now, we just restore it

      notifyListeners();
      return true;
    } catch (e) {
      await _secureStorage.deleteToken();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
