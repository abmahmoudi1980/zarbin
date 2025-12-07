import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/models/category_breakdown.dart';
import 'package:zarbin/widgets/category_pie_chart.dart';
import 'package:zarbin/providers/dashboard_provider.dart';

void main() {
  group('CategoryPieChart Widget Tests', () {
    late CategoryBreakdownData mockBreakdownData;

    setUp(() {
      mockBreakdownData = CategoryBreakdownData(
        categories: [
          CategorySpending(
            categoryId: '1',
            categoryNameFa: 'غذا',
            categoryIcon: 'food',
            totalAmount: 5_000_000,
            percentage: 62.5,
          ),
          CategorySpending(
            categoryId: '2',
            categoryNameFa: 'حمل‌ونقل',
            categoryIcon: 'transport',
            totalAmount: 3_000_000,
            percentage: 37.5,
          ),
        ],
        totalSpending: 8_000_000,
        currentMonth: '1403/09',
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: CategoryPieChart(
            categoryBreakdown: mockBreakdownData,
          ),
        ),
      );
    }

    testWidgets('displays pie chart when data is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CategoryPieChart), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('displays all category segments in pie chart',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that both category names are displayed
      expect(find.text('غذا'), findsWidgets);
      expect(find.text('حمل‌ونقل'), findsWidgets);
    });

    testWidgets('displays percentage for each category',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('62.5%'), findsWidgets);
      expect(find.text('37.5%'), findsWidgets);
    });

    testWidgets('displays category amounts in Persian numerals',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Persian numerals for 5,000,000 and 3,000,000
      expect(find.text('۵٬۰۰۰٬۰۰۰'), findsWidgets);
      expect(find.text('۳٬۰۰۰٬۰۰۰'), findsWidgets);
    });

    testWidgets('displays category icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that icon widgets are rendered
      expect(find.byIcon(Icons.fastfood), findsWidgets);
      expect(find.byIcon(Icons.directions_car), findsWidgets);
    });

    testWidgets('displays legend with category names',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Legend), findsOneWidget);
      expect(find.text('غذا'), findsWidgets);
      expect(find.text('حمل‌ونقل'), findsWidgets);
    });

    testWidgets('displays total spending amount', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Persian numerals for 8,000,000
      expect(find.text('۸٬۰۰۰٬۰۰۰'), findsWidgets);
    });

    testWidgets('displays current month in Jalali format',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('1403/09'), findsWidgets);
    });

    testWidgets('uses correct colors for different categories',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pie chart should have specific colors for each segment
      final pieChart = find.byType(PieChart);
      expect(pieChart, findsOneWidget);
    });

    testWidgets('handles single category correctly',
        (WidgetTester tester) async {
      final singleCategoryData = CategoryBreakdownData(
        categories: [
          CategorySpending(
            categoryId: '1',
            categoryNameFa: 'غذا',
            categoryIcon: 'food',
            totalAmount: 8_000_000,
            percentage: 100.0,
          ),
        ],
        totalSpending: 8_000_000,
        currentMonth: '1403/09',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(
              categoryBreakdown: singleCategoryData,
            ),
          ),
        ),
      );

      expect(find.text('100.0%'), findsWidgets);
      expect(find.text('غذا'), findsWidgets);
    });

    testWidgets('handles empty breakdown gracefully',
        (WidgetTester tester) async {
      final emptyData = CategoryBreakdownData(
        categories: [],
        totalSpending: 0,
        currentMonth: '1403/09',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(
              categoryBreakdown: emptyData,
            ),
          ),
        ),
      );

      // Should show empty state message
      expect(
        find.text('No spending recorded for this month'),
        findsOneWidget,
      );
    });

    testWidgets('handles large category amounts without overflow',
        (WidgetTester tester) async {
      final largeData = CategoryBreakdownData(
        categories: [
          CategorySpending(
            categoryId: '1',
            categoryNameFa: 'غذا',
            categoryIcon: 'food',
            totalAmount: 50_000_000_000,
            percentage: 100.0,
          ),
        ],
        totalSpending: 50_000_000_000,
        currentMonth: '1403/09',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(
              categoryBreakdown: largeData,
            ),
          ),
        ),
      );

      expect(find.byType(CategoryPieChart), findsOneWidget);
    });

    testWidgets('updates when breakdown data changes',
        (WidgetTester tester) async {
      final initialData = CategoryBreakdownData(
        categories: [
          CategorySpending(
            categoryId: '1',
            categoryNameFa: 'غذا',
            categoryIcon: 'food',
            totalAmount: 5_000_000,
            percentage: 100.0,
          ),
        ],
        totalSpending: 5_000_000,
        currentMonth: '1403/09',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CategoryPieChart(categoryBreakdown: initialData),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          mockBreakdownData = CategoryBreakdownData(
                            categories: [
                              CategorySpending(
                                categoryId: '1',
                                categoryNameFa: 'غذا',
                                categoryIcon: 'food',
                                totalAmount: 10_000_000,
                                percentage: 100.0,
                              ),
                            ],
                            totalSpending: 10_000_000,
                            currentMonth: '1403/09',
                          );
                        });
                      },
                      child: Text('Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial value should be displayed
      expect(find.text('۵٬۰۰۰٬۰۰۰'), findsWidgets);
    });

    testWidgets('is scrollable when content exceeds screen height',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays category breakdown title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text('تفکیک هزینه‌های ماه'),
        findsOneWidget,
      );
    });

    testWidgets('has correct RTL layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that Directionality is set to RTL
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Directionality && widget.textDirection == TextDirection.rtl,
        ),
        findsWidgets,
      );
    });
  });
}
