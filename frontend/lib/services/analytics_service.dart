import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> init() async {
    if (!ApiConfig.enableAnalytics) return;

    // Enable/disable collection based on config
    await _analytics.setAnalyticsCollectionEnabled(ApiConfig.enableAnalytics);
    await _crashlytics
        .setCrashlyticsCollectionEnabled(ApiConfig.enableAnalytics);

    if (kDebugMode) {
      // Force disable in debug mode if needed, or keep enabled for testing
      // await _crashlytics.setCrashlyticsCollectionEnabled(false);
    }
  }

  // Log custom events
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!ApiConfig.enableAnalytics) return;
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  // Log screen views
  Future<void> logScreenView({required String screenName}) async {
    if (!ApiConfig.enableAnalytics) return;
    await _analytics.logScreenView(screenName: screenName);
  }

  // Log user login
  Future<void> logLogin({String? method}) async {
    if (!ApiConfig.enableAnalytics) return;
    await _analytics.logLogin(loginMethod: method);
  }

  // Log user sign up
  Future<void> logSignUp({required String method}) async {
    if (!ApiConfig.enableAnalytics) return;
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Set user ID
  Future<void> setUserId(String userId) async {
    if (!ApiConfig.enableAnalytics) return;
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }

  // Log non-fatal errors
  Future<void> logError(dynamic error, StackTrace stack,
      {String? reason}) async {
    if (!ApiConfig.enableAnalytics) return;
    await _crashlytics.recordError(error, stack, reason: reason);
  }

  // Log custom keys for crash reports
  Future<void> setCustomKey(String key, Object value) async {
    if (!ApiConfig.enableAnalytics) return;
    await _crashlytics.setCustomKey(key, value);
  }
}
