class CategoryBreakdownData {
  final List<CategorySpending> categories;
  final int totalSpending;
  final String currentMonth;

  CategoryBreakdownData({
    required this.categories,
    required this.totalSpending,
    required this.currentMonth,
  });

  factory CategoryBreakdownData.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownData(
      categories: (json['breakdown'] as List)
          .map(
              (item) => CategorySpending.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalSpending: json['total_spending'] as int,
      currentMonth: json['current_month'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'breakdown': categories.map((c) => c.toJson()).toList(),
        'total_spending': totalSpending,
        'current_month': currentMonth,
      };
}

class CategorySpending {
  final String categoryId;
  final String categoryNameFa;
  final String categoryIcon;
  final int totalAmount;
  final double percentage;

  CategorySpending({
    required this.categoryId,
    required this.categoryNameFa,
    required this.categoryIcon,
    required this.totalAmount,
    required this.percentage,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      categoryId: json['category_id'] as String,
      categoryNameFa: json['category_name_fa'] as String,
      categoryIcon: json['category_icon'] as String,
      totalAmount: json['total_amount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name_fa': categoryNameFa,
        'category_icon': categoryIcon,
        'total_amount': totalAmount,
        'percentage': percentage,
      };
}
