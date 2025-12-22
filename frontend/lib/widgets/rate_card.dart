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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with label and change indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _getIcon(colorScheme),
                      const SizedBox(width: 12),
                      Text(
                        _getLabel(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RateChangeIndicator(rate: rate),
                ],
              ),

              const SizedBox(height: 20),

              // Main rate value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'نرخ کنونی',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        PersianFormatter.formatNumber(rate.valueInToman),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'تومان',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer with timestamp and stale indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'به‌روزرسانی: ${PersianFormatter.formatDateTime(rate.timestamp)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (isStale)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'نرخ قدیمی',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _getIcon(ColorScheme colorScheme) {
    IconData iconData;
    Color iconColor;

    switch (rate.rateType) {
      case 'usd':
        iconData = Icons.attach_money_rounded;
        iconColor = Colors.green;
        break;
      case 'gold_gram':
        iconData = Icons.workspace_premium_rounded;
        iconColor = Colors.amber.shade700;
        break;
      case 'bahar_coin':
        iconData = Icons.toll_rounded;
        iconColor = Colors.orange.shade800;
        break;
      default:
        iconData = Icons.trending_up_rounded;
        iconColor = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
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
}
