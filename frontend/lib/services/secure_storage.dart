import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _mobileNumberKey = 'mobile_number';
  static const String _pendingMobileNumberKey = 'pending_mobile_number';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // User ID management
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  // Mobile number management
  Future<void> saveMobileNumber(String mobileNumber) async {
    await _storage.write(key: _mobileNumberKey, value: mobileNumber);
  }

  Future<String?> getMobileNumber() async {
    return await _storage.read(key: _mobileNumberKey);
  }

  Future<void> deleteMobileNumber() async {
    await _storage.delete(key: _mobileNumberKey);
  }

  // Pending mobile number (during OTP verification)
  Future<void> savePendingMobileNumber(String mobileNumber) async {
    if (mobileNumber.isEmpty) {
      await _storage.delete(key: _pendingMobileNumberKey);
    } else {
      await _storage.write(key: _pendingMobileNumberKey, value: mobileNumber);
    }
  }

  Future<String?> getPendingMobileNumber() async {
    return await _storage.read(key: _pendingMobileNumberKey);
  }

  // Token expiry management
  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
  }

  Future<DateTime?> getTokenExpiry() async {
    final value = await _storage.read(key: _tokenExpiryKey);
    if (value == null) return null;
    return DateTime.parse(value);
  }

  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return expiry.isBefore(DateTime.now());
  }

  // Clear all
  Future<void> clearAll() async {
    await deleteToken();
    await deleteUserId();
    await deleteMobileNumber();
    await _storage.delete(key: _pendingMobileNumberKey);
    await _storage.delete(key: _tokenExpiryKey);
  }
}
