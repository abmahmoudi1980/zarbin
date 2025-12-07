// lib/services/hive_service.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/market_rate.dart';

class HiveService {
  static const String userBoxName = 'users';
  static const String marketRateBoxName = 'market_rates';
  static const String appCacheBoxName = 'app_cache';

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(MarketRateAdapter().typeId)) {
      Hive.registerAdapter(MarketRateAdapter());
    }

    // Open boxes
    await Hive.openBox<User>(userBoxName);
    await Hive.openBox<MarketRate>(marketRateBoxName);
    await Hive.openBox(appCacheBoxName);
  }

  static Future<void> close() async {
    await Hive.close();
  }

  // User management
  static Future<void> saveUser(User user) async {
    final box = Hive.box<User>(userBoxName);
    await box.put('current_user', user);
  }

  static User? getUser() {
    final box = Hive.box<User>(userBoxName);
    return box.get('current_user');
  }

  static Future<void> deleteUser() async {
    final box = Hive.box<User>(userBoxName);
    await box.delete('current_user');
  }

  static bool hasUser() {
    final box = Hive.box<User>(userBoxName);
    return box.containsKey('current_user');
  }

  // Market rates caching (5-minute validity)
  static Future<void> saveMarketRates(List<MarketRate> rates) async {
    final box = Hive.box<MarketRate>(marketRateBoxName);
    await box.clear();
    for (int i = 0; i < rates.length; i++) {
      await box.put('rate_$i', rates[i]);
    }
    final cacheBox = Hive.box(appCacheBoxName);
    await cacheBox.put('rates_cached_at', DateTime.now().toIso8601String());
  }

  static List<MarketRate> getMarketRates() {
    final box = Hive.box<MarketRate>(marketRateBoxName);
    return box.values.toList();
  }

  static MarketRate? getMarketRateByType(String rateType) {
    final box = Hive.box<MarketRate>(marketRateBoxName);
    return box.values.firstWhere(
      (rate) => rate.rateType == rateType,
      orElse: () => null as dynamic,
    );
  }

  static bool isMarketRatesCached() {
    final cacheBox = Hive.box(appCacheBoxName);
    final cachedAt = cacheBox.get('rates_cached_at');
    if (cachedAt == null) return false;

    final lastCacheTime = DateTime.parse(cachedAt as String);
    final now = DateTime.now();
    return now.difference(lastCacheTime).inMinutes < 5;
  }

  static Future<void> clearMarketRates() async {
    final box = Hive.box<MarketRate>(marketRateBoxName);
    await box.clear();
    final cacheBox = Hive.box(appCacheBoxName);
    await cacheBox.delete('rates_cached_at');
  }

  // App cache (generic key-value storage)
  static Future<void> setCacheValue(String key, dynamic value) async {
    final box = Hive.box(appCacheBoxName);
    await box.put(key, value);
  }

  static dynamic getCacheValue(String key) {
    final box = Hive.box(appCacheBoxName);
    return box.get(key);
  }

  static Future<void> deleteCacheValue(String key) async {
    final box = Hive.box(appCacheBoxName);
    await box.delete(key);
  }

  static Future<void> clearAllCache() async {
    final box = Hive.box(appCacheBoxName);
    await box.clear();
  }
}
