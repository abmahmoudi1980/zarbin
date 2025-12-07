import 'package:flutter/material.dart';
import '../models/market_rate.dart';
import '../utils/persian_formatter.dart';
import 'rate_change_indicator.dart';

/// RateCard - Displays a single market rate with all details
/// 
/// Features:
/// - Rate type label (USD, Gold, Bahar Azadi)
/// - Current rate value in Persian numerals
/// - Jalali timestamp
/// - Stale indicator (if >5 minutes old)
/// - Rate change indicator (up/down arrows with %)

class RateCard extends StatelessWidget {
  final MarketRate rate;

  const RateCard({
    Key? key,
    required this.rate,
  }) : super(key: key);

  bool get isStale => rate.isStale;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isStale ? 1 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isStale
              ? Border.all(color: Colors.orange.shade200)
              : Border.all(color: Colors.transparent),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with label and stale indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isStale)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'نرخ قدیمی است',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  RateChangeIndicator(rate: rate),
                ],
              ),

              const SizedBox(height: 12),

              // Main rate value
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'نرخ کنونی',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PersianFormatter.formatNumber(rate.valueInToman),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تومان',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Footer with timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'زمان: ${_formatTimestamp()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (isStale)
                    Text(
                      '${_getStaleMinutes()} دقیقه قدیمی',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLabel() {
    switch (rate.rateType) {
      case 'usd':
        return 'دلار آمریکا';
      case 'gold_gram':
        return 'طلا (گرم)';
      case 'bahar_coin':
        return 'سکه بهار آزادی';
      default:
        return rate.rateType;
    }
  }

  String _formatTimestamp() {
    final time = rate.timestamp;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  int _getStaleMinutes() {
    final now = DateTime.now();
    return now.difference(rate.timestamp).inMinutes;
  }
}
