import 'package:flutter/material.dart';
import 'package:zarbin/models/transaction.dart';
import 'package:zarbin/utils/persian_formatter.dart';

/// TransactionListItem - Widget displaying a single transaction in a list
/// Features:
/// - Category icon
/// - Amount in Toman (Persian numerals) with +/- indicator
/// - USD equivalent
/// - Transaction date
/// - Category name
/// - Notes preview
/// - Income (green) vs Expense (red) color coding
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  /// Gets category icon based on category name
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'خوراک':
        return Icons.restaurant;
      case 'حمل و نقل':
        return Icons.directions_car;
      case 'صورت حساب':
        return Icons.lightbulb;
      case 'خرید و فروش':
        return Icons.shopping_bag;
      case 'سلامت':
        return Icons.health_and_safety;
      case 'سرگرمی':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  /// Gets color based on transaction type
  Color _getTypeColor() {
    return transaction.transactionType == 'income' ? Colors.green : Colors.red;
  }

  /// Gets amount display with +/- prefix and Persian numerals
  String _getFormattedAmount() {
    final prefix = transaction.transactionType == 'income' ? '+' : '-';
    final formatted = PersianFormatter.formatNumber(transaction.amountToman);
    return '$prefix$formatted';
  }

  /// Truncates notes to preview length
  String _getTruncatedNotes(String notes) {
    const maxLength = 50;
    if (notes.length > maxLength) {
      return '${notes.substring(0, maxLength)}...';
    }
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        // Category icon
        leading: CircleAvatar(
          backgroundColor: _getTypeColor().withOpacity(0.1),
          child: Icon(
            _getCategoryIcon(transaction.categoryName ?? ''),
            color: _getTypeColor(),
          ),
        ),

        // Transaction details
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.categoryName ?? 'Other',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  transaction.transactionDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Notes preview
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(
                _getTruncatedNotes(transaction.notes!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),

        // Amount display
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Toman amount
            Text(
              _getFormattedAmount(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _getTypeColor(),
              ),
            ),
            const SizedBox(height: 4),
            // USD equivalent
            Text(
              '${transaction.amountUsdEquivalent.toStringAsFixed(2)} USD',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        // Tap action
        onTap: onTap,

        // Long press for more options
        onLongPress: () {
          _showOptions(context);
        },
      ),
    );
  }

  /// Shows options menu on long press
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
