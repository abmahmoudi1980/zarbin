import 'package:flutter/material.dart';

class CategoryIcons {
  static const Map<String, IconData> _iconMap = {
    'food': Icons.fastfood,
    'غذا': Icons.fastfood,
    'grocery': Icons.shopping_cart,
    'transport': Icons.directions_car,
    'حمل‌ونقل': Icons.directions_car,
    'bills': Icons.receipt,
    'قبض‌ها': Icons.receipt,
    'shopping': Icons.shopping_bag,
    'خریدن': Icons.shopping_bag,
    'health': Icons.local_hospital,
    'سلامت': Icons.local_hospital,
    'entertainment': Icons.movie,
    'سرگرمی': Icons.movie,
    'other': Icons.category,
    'سایر': Icons.category,
  };

  static IconData getIcon(String categoryCode) {
    return _iconMap[categoryCode] ?? Icons.category;
  }

  static Map<String, IconData> getAllIcons() {
    return Map.unmodifiable(_iconMap);
  }

  static IconData getIconByName(String categoryName) {
    final normalized = categoryName.toLowerCase();
    return _iconMap[normalized] ?? Icons.category;
  }
}
