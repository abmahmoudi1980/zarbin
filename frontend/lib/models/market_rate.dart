// lib/models/market_rate.dart
import 'package:hive/hive.dart';

part 'market_rate.g.dart';

@HiveType(typeId: 2)
class MarketRate extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String rateType; // usd, gold_gram, bahar_coin

  @HiveField(2)
  int valueInToman;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  DateTime cachedAt;

  MarketRate({
    this.id,
    required this.rateType,
    required this.valueInToman,
    DateTime? timestamp,
    DateTime? cachedAt,
  })  : timestamp = timestamp ?? DateTime.now(),
        cachedAt = cachedAt ?? DateTime.now();

  // Factory constructor from JSON (API response)
  factory MarketRate.fromJson(Map<String, dynamic> json) {
    return MarketRate(
      id: json['id']?.toString(),
      rateType: json['rate_type'] as String,
      valueInToman: json['value_in_toman'] as int,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      cachedAt: DateTime.now(),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rate_type': rateType,
      'value_in_toman': valueInToman,
      'timestamp': timestamp.toIso8601String(),
      'cached_at': cachedAt.toIso8601String(),
    };
  }

  // Get rate label in Persian
  String get rateLabel {
    switch (rateType) {
      case 'usd':
        return 'دلار آمریکا';
      case 'gold_gram':
        return 'طلا (گرم)';
      case 'bahar_coin':
        return 'سکه بهار آزادی';
      default:
        return rateType;
    }
  }

  // Get rate symbol
  String get rateSymbol {
    switch (rateType) {
      case 'usd':
        return '\$';
      case 'gold_gram':
        return 'g';
      case 'bahar_coin':
        return '🪙';
      default:
        return '';
    }
  }

  // Check if rate is stale (older than 5 minutes)
  bool get isStale {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff.inMinutes > 5;
  }

  // Get time ago description (in Persian)
  String get timeAgoDescription {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return 'لحظاتی پیش';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} دقیقه پیش';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ساعت پیش';
    } else {
      return '${diff.inDays} روز پیش';
    }
  }

  // Convert amount from Toman to this currency
  double convertFromToman(int amountToman) {
    return double.parse((amountToman / valueInToman).toStringAsFixed(2));
  }

  // Convert amount from this currency to Toman
  int convertToToman(double amount) {
    return (amount * valueInToman).toInt();
  }

  @override
  String toString() {
    return 'MarketRate($rateLabel: ${valueInToman.toString()} تومان)';
  }
}

extension DoubleRound on double {
  double roundToDouble(int decimals) {
    final factor = 10.0 * decimals;
    return (this * factor).round() / factor;
  }
}
