import 'package:flutter/material.dart';

/// CategorySelector - Dropdown widget for selecting transaction category
/// Displays all 7 predefined categories:
/// - Food, Transport, Bills, Shopping, Health, Entertainment, Other
class CategorySelector extends StatefulWidget {
  final int? selectedCategoryId;
  final Function(int) onCategorySelected;

  const CategorySelector({
    Key? key,
    this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  // Hardcoded categories (would be fetched from API in production)
  static const List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'خوراک', 'icon': '🍔'}, // Food
    {'id': 2, 'name': 'حمل و نقل', 'icon': '🚗'}, // Transport
    {'id': 3, 'name': 'صورت حساب', 'icon': '💡'}, // Bills
    {'id': 4, 'name': 'خرید و فروش', 'icon': '🛍️'}, // Shopping
    {'id': 5, 'name': 'سلامت', 'icon': '⚕️'}, // Health
    {'id': 6, 'name': 'سرگرمی', 'icon': '🎬'}, // Entertainment
    {'id': 7, 'name': 'سایر', 'icon': '📌'}, // Other
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        DropdownButtonFormField<int>(
          value: widget.selectedCategoryId,
          hint: const Text('Select a category'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<int>(
              value: category['id'] as int,
              child: Row(
                children: [
                  Text(category['icon'] as String,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(category['name'] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (categoryId) {
            if (categoryId != null) {
              widget.onCategorySelected(categoryId);
            }
          },
          isExpanded: true,
        ),
      ],
    );
  }
}
