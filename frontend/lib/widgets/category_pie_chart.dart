import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:zarbin/models/category_breakdown.dart';
import 'package:zarbin/utils/persian_formatter.dart';

class CategoryPieChart extends StatelessWidget {
  final CategoryBreakdownData categoryBreakdown;

  const CategoryPieChart({
    Key? key,
    required this.categoryBreakdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryBreakdown.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No spending recorded for this month',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Pie chart
        PieChart(
          dataMap: _buildDataMap(),
          animationDuration: const Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 2.7,
          colorList: _getColorList(),
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          centerText: PersianFormatter.formatNumber(
            categoryBreakdown.totalSpending,
          ),
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            decimalPlaces: 1,
          ),
          ringStrokeWidth: 32,
        ),
        const SizedBox(height: 24),
        // Legend with details
        _buildDetailedLegend(),
      ],
    );
  }

  Map<String, double> _buildDataMap() {
    final dataMap = <String, double>{};
    for (final category in categoryBreakdown.categories) {
      dataMap[category.categoryNameFa] = category.totalAmount.toDouble();
    }
    return dataMap;
  }

  List<Color> _getColorList() {
    const colors = [
      Color(0xFF6366F1), // Indigo
      Color(0xFF8B5CF6), // Violet
      Color(0xFFEC4899), // Pink
      Color(0xFFF43F5E), // Rose
      Color(0xFFF97316), // Orange
      Color(0xFFEAB308), // Yellow
      Color(0xFF22C55E), // Green
    ];
    return colors;
  }

  Widget _buildDetailedLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: categoryBreakdown.categories
            .map((category) => _buildCategoryRow(category))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryRow(CategorySpending category) {
    final colorIndex =
        categoryBreakdown.categories.indexOf(category) % _getColorList().length;
    final color = _getColorList()[colorIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.categoryNameFa,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${category.percentage}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            PersianFormatter.formatNumber(category.totalAmount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
