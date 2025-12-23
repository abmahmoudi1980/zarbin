import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SecureStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _mobileNumberKey = 'mobile_number';
  static const String _pendingMobileNumberKey = 'pending_mobile_number';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _storage;
  SharedPreferences? _prefs;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> _initPrefs() async {
    if (kIsWeb && _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // Token management
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.setString(_tokenKey, token);
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      await _initPrefs();
      return _prefs?.getString(_tokenKey);
    } else {
      return await _storage.read(key: _tokenKey);
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.remove(_tokenKey);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  // User ID management
  Future<void> saveUserId(String userId) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.setString(_userIdKey, userId);
    } else {
      await _storage.write(key: _userIdKey, value: userId);
    }
  }

  Future<String?> getUserId() async {
    if (kIsWeb) {
      await _initPrefs();
      return _prefs?.getString(_userIdKey);
    } else {
      return await _storage.read(key: _userIdKey);
    }
  }

  Future<void> deleteUserId() async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.remove(_userIdKey);
    } else {
      await _storage.delete(key: _userIdKey);
    }
  }

  // Mobile number management
  Future<void> saveMobileNumber(String mobileNumber) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.setString(_mobileNumberKey, mobileNumber);
    } else {
      await _storage.write(key: _mobileNumberKey, value: mobileNumber);
    }
  }

  Future<String?> getMobileNumber() async {
    if (kIsWeb) {
      await _initPrefs();
      return _prefs?.getString(_mobileNumberKey);
    } else {
      return await _storage.read(key: _mobileNumberKey);
    }
  }

  Future<void> deleteMobileNumber() async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.remove(_mobileNumberKey);
    } else {
      await _storage.delete(key: _mobileNumberKey);
    }
  }

  // Pending mobile number (during OTP verification)
  Future<void> savePendingMobileNumber(String mobileNumber) async {
    if (kIsWeb) {
      await _initPrefs();
      if (mobileNumber.isEmpty) {
        await _prefs?.remove(_pendingMobileNumberKey);
      } else {
        await _prefs?.setString(_pendingMobileNumberKey, mobileNumber);
      }
    } else {
      if (mobileNumber.isEmpty) {
        await _storage.delete(key: _pendingMobileNumberKey);
      } else {
        await _storage.write(key: _pendingMobileNumberKey, value: mobileNumber);
      }
    }
  }

  Future<String?> getPendingMobileNumber() async {
    if (kIsWeb) {
      await _initPrefs();
      return _prefs?.getString(_pendingMobileNumberKey);
    } else {
      return await _storage.read(key: _pendingMobileNumberKey);
    }
  }

  // Token expiry management
  Future<void> saveTokenExpiry(DateTime expiry) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.setString(_tokenExpiryKey, expiry.toIso8601String());
    } else {
      await _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
    }
  }

  Future<DateTime?> getTokenExpiry() async {
    String? value;
    if (kIsWeb) {
      await _initPrefs();
      value = _prefs?.getString(_tokenExpiryKey);
    } else {
      value = await _storage.read(key: _tokenExpiryKey);
    }
    
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
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.remove(_pendingMobileNumberKey);
      await _prefs?.remove(_tokenExpiryKey);
    } else {
      await _storage.delete(key: _pendingMobileNumberKey);
      await _storage.delete(key: _tokenExpiryKey);
    }
  }
}
