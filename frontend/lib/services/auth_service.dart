// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'hive_service.dart';
import 'secure_storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final ApiClient _apiClient = ApiClient();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Generate OTP
  Future<Map<String, dynamic>> generateOtp(String mobileNumber) async {
    try {
      final response = await _apiClient.generateOtp(mobileNumber);
      if (response.statusCode == 200) {
        await SecureStorageService.saveMobileNumber(mobileNumber);
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'expires_in_minutes': response.data['expires_in_minutes'] ?? 10,
        };
      }
      return {'success': false, 'error': 'Failed to generate OTP'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error',
      };
    }
  }

  // Verify OTP and login
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String code) async {
    try {
      final response = await _apiClient.verifyOtp(mobileNumber, code);
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userData = response.data['user'];

        // Save credentials
        await SecureStorageService.saveToken(token);
        await SecureStorageService.saveMobileNumber(mobileNumber);
        if (userData?['id'] != null) {
          await SecureStorageService.saveUserId(userData['id']);
        }

        // Save user to Hive
        final user = User.fromJson(userData);
        await HiveService.saveUser(user);

        return {
          'success': true,
          'message': 'Login successful',
          'user': user,
        };
      }
      return {'success': false, 'error': 'Failed to verify OTP'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error',
      };
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String mobileNumber) async {
    try {
      final response = await _apiClient.resendOtp(mobileNumber);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP resent successfully',
          'expires_in_minutes': response.data['expires_in_minutes'] ?? 10,
        };
      }
      return {'success': false, 'error': 'Failed to resend OTP'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (e) {
      // Continue logout even if API fails
    } finally {
      await SecureStorageService.clearAll();
      await HiveService.deleteUser();
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return HiveService.getUser();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return SecureStorageService.hasToken();
  }

  // Get JWT token
  Future<String?> getToken() async {
    return SecureStorageService.getToken();
  }
}
