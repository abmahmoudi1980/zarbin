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
    // The API returns {"success": true, "data": [...]}
    // We need to handle the "data" array
    final data = json['data'] as List<dynamic>? ?? [];
    final categories = data
        .map((item) => CategorySpending.fromJson(item as Map<String, dynamic>))
        .toList();

    // Calculate total spending from all categories' expenses
    final totalSpending = categories.fold<int>(
      0,
      (sum, category) => sum + category.totalExpense,
    );

    // Calculate percentages for each category
    for (final category in categories) {
      if (totalSpending > 0) {
        category.percentage = (category.totalExpense / totalSpending) * 100;
      } else {
        category.percentage = 0.0;
      }
    }

    // Get current month in Persian format
    final now = DateTime.now();
    final persianMonths = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    // Note: This is a simple conversion. For accurate Persian calendar,
    // you might want to use a proper Jalali calendar library
    final monthIndex = (now.month - 1) % 12;
    final currentMonth = persianMonths[monthIndex];

    return CategoryBreakdownData(
      categories: categories,
      totalSpending: totalSpending,
      currentMonth: currentMonth,
    );
  }

  Map<String, dynamic> toJson() => {
        'categories': categories.map((c) => c.toJson()).toList(),
        'total_spending': totalSpending,
        'current_month': currentMonth,
      };
}

class CategorySpending {
  final String categoryId;
  final String categoryNameFa;
  final String categoryIcon;
  final int totalAmount;
  final int totalIncome;
  final int totalExpense;
  final int netBalance;
  final int transactionCount;
  double percentage;

  CategorySpending({
    required this.categoryId,
    required this.categoryNameFa,
    required this.categoryIcon,
    required this.totalAmount,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.transactionCount,
    required this.percentage,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      categoryId: json['category_id'].toString(),
      categoryNameFa: json['category_name'] as String,
      categoryIcon: json['icon_code'] as String,
      totalAmount: json['total_expense'] as int, // Using expense as the main amount for breakdown
      totalIncome: json['total_income'] as int,
      totalExpense: json['total_expense'] as int,
      netBalance: json['net_balance'] as int,
      transactionCount: json['transaction_count'] as int,
      percentage: 0.0, // Will be calculated later
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name_fa': categoryNameFa,
        'category_icon': categoryIcon,
        'total_amount': totalAmount,
        'total_income': totalIncome,
        'total_expense': totalExpense,
        'net_balance': netBalance,
        'transaction_count': transactionCount,
        'percentage': percentage,
      };
}
