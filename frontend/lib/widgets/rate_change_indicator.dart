import 'package:flutter/material.dart';
import '../models/market_rate.dart';
import '../utils/persian_formatter.dart';

/// RateChangeIndicator - Shows rate change with up/down arrows and percentage
///
/// Features:
/// - Up arrow (green) for rate increases
/// - Down arrow (red) for rate decreases
/// - Neutral indicator for no change
/// - Percentage change display
/// - Compares with previous rate from 1 hour ago

class RateChangeIndicator extends StatefulWidget {
  final MarketRate rate;

  const RateChangeIndicator({
    Key? key,
    required this.rate,
  }) : super(key: key);

  @override
  State<RateChangeIndicator> createState() => _RateChangeIndicatorState();
}

class _RateChangeIndicatorState extends State<RateChangeIndicator> {
  double _changePercent = 0;
  String _changeDirection = 'stable';

  @override
  void initState() {
    super.initState();
    _calculateChange();
  }

  void _calculateChange() {
    // In a real app, this would compare with historical data
    // For now, we'll show a placeholder
    // TODO: Implement actual change calculation from historical rates
    _changePercent = 0;
    _changeDirection = 'stable';
  }

  Color _getChangeColor() {
    switch (_changeDirection) {
      case 'up':
        return Colors.green;
      case 'down':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getChangeIcon() {
    switch (_changeDirection) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getChangeColor();
    final percentStr = _changePercent > 0
        ? '+${_changePercent.toStringAsFixed(2)}'
        : _changePercent.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getChangeIcon(),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${PersianFormatter.toPersianDigits(percentStr)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
