// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String tokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String mobileNumberKey = 'mobile_number';
  static const String userIdKey = 'user_id';

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      resetOnError: true,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Token management
  static Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Refresh token management
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: refreshTokenKey);
  }

  // Mobile number storage
  static Future<void> saveMobileNumber(String mobileNumber) async {
    await _storage.write(key: mobileNumberKey, value: mobileNumber);
  }

  static Future<String?> getMobileNumber() async {
    return await _storage.read(key: mobileNumberKey);
  }

  static Future<void> deleteMobileNumber() async {
    await _storage.delete(key: mobileNumberKey);
  }

  // User ID storage
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  static Future<void> deleteUserId() async {
    await _storage.delete(key: userIdKey);
  }

  // Generic key-value storage for sensitive data
  static Future<void> saveSecureValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getSecureValue(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteSecureValue(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all secure storage
  static Future<void> clearAll() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
      deleteMobileNumber(),
      deleteUserId(),
    ]);
  }
}
