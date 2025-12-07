import 'package:flutter/material.dart';
import 'package:zarbin/models/category_breakdown.dart';
import 'package:zarbin/utils/persian_formatter.dart';
import 'package:zarbin/utils/category_icons.dart';

class CategoryListItem extends StatelessWidget {
  final CategorySpending categorySpending;
  final VoidCallback? onTap;

  const CategoryListItem({
    Key? key,
    required this.categorySpending,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIcons.getIcon(categorySpending.categoryIcon);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: Row(
          children: [
            // Category icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 16),

            // Category name and percentage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categorySpending.categoryNameFa,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${categorySpending.percentage.toStringAsFixed(1)}% of total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PersianFormatter.formatNumber(
                    categorySpending.totalAmount,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تومان',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
