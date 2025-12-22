import 'package:flutter/material.dart';

/// BalanceCard widget - Displays a single balance in a specific currency
///
/// Shows:
/// - Currency label (e.g., "تومان", "دلار آمریکا", "طلا")
/// - Amount value in Persian numerals
/// - Currency symbol
/// - Visual styling with color differentiation

class BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;

  const BalanceCard({
    Key? key,
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    _getCurrencyIcon(),
                    size: 18,
                    color: color.withOpacity(0.7),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      amount,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
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

  IconData _getCurrencyIcon() {
    if (label.contains('تومان')) return Icons.account_balance_wallet_rounded;
    if (label.contains('دلار')) return Icons.attach_money_rounded;
    if (label.contains('طلا')) return Icons.workspace_premium_rounded;
    return Icons.payments_rounded;
  }
}
