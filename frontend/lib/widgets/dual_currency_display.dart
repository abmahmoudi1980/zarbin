import 'package:flutter/material.dart';
import 'package:zarbin/utils/persian_formatter.dart';

/// DualCurrencyDisplay - Widget showing both Toman and USD equivalent amounts
/// Features:
/// - Displays amount in Toman with Persian numerals
/// - Shows USD equivalent
/// - Real-time updates as amount changes
class DualCurrencyDisplay extends StatefulWidget {
  final int amountToman;
  final String usdEquivalent;
  final bool showGold;
  final String? goldEquivalent;

  const DualCurrencyDisplay({
    Key? key,
    required this.amountToman,
    required this.usdEquivalent,
    this.showGold = false,
    this.goldEquivalent,
  }) : super(key: key);

  @override
  State<DualCurrencyDisplay> createState() => _DualCurrencyDisplayState();
}

class _DualCurrencyDisplayState extends State<DualCurrencyDisplay> {
  /// Formats amount to Persian numerals with thousands separator
  String _formatTomanAmount(int amount) {
    if (amount == 0) return '۰';

    final formatted = amount.toString();
    final reversed = formatted.split('').reversed.toList();

    final withSeparators = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withSeparators.add('،');
      }
      withSeparators.add(reversed[i]);
    }

    final result = withSeparators.reversed.join('');
    return PersianFormatter.toPersian(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toman amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              Text(
                _formatTomanAmount(widget.amountToman),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // USD equivalent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'USD Equivalent',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              Text(
                widget.usdEquivalent,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Gold equivalent (if enabled)
          if (widget.showGold && widget.goldEquivalent != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gold Equivalent',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                Text(
                  widget.goldEquivalent!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
