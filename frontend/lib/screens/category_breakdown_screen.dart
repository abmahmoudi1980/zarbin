import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/models/category_breakdown.dart';
import 'package:zarbin/providers/dashboard_provider.dart';
import 'package:zarbin/utils/persian_formatter.dart';
import 'package:zarbin/widgets/category_pie_chart.dart';
import 'package:zarbin/widgets/category_list_item.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  const CategoryBreakdownScreen({Key? key}) : super(key: key);

  @override
  State<CategoryBreakdownScreen> createState() =>
      _CategoryBreakdownScreenState();
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
  late DashboardProvider _dashboardProvider;
  bool _isLoading = false;
  String? _errorMessage;
  CategoryBreakdownData? _breakdownData;

  @override
  void initState() {
    super.initState();
    _dashboardProvider = context.read<DashboardProvider>();
    _loadCategoryBreakdown();
  }

  Future<void> _loadCategoryBreakdown() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dashboardProvider.loadSpendingBreakdown();
      setState(() {
        _breakdownData = data;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'خطا در بارگذاری داده‌ها: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفکیک هزینه‌های ماه'),
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCategoryBreakdown,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategoryBreakdown,
              child: const Text('تلاش دوباره'),
            ),
          ],
        ),
      );
    }

    if (_breakdownData == null || _breakdownData!.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_down, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('هیچ هزینه‌ای در این ماه ثبت نشده است'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Current month header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'ماه ${_breakdownData!.currentMonth}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Pie chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CategoryPieChart(categoryBreakdown: _breakdownData!),
          ),

          const SizedBox(height: 24),

          // Total spending card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'کل هزینه‌ها',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      PersianFormatter.formatNumber(
                        _breakdownData!.totalSpending,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category breakdown list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفصیل دسته‌بندی',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _breakdownData!.categories.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final category = _breakdownData!.categories[index];
                    return CategoryListItem(
                      categorySpending: category,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
