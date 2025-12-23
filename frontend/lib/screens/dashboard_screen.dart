import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/market_rate_provider.dart';
import '../utils/persian_formatter.dart';
import '../widgets/balance_card.dart';
import 'category_breakdown_screen.dart';

/// DashboardScreen - Displays user's net worth dashboard
///
/// Features:
/// - Show total balance in Toman
/// - Display USD equivalent
/// - Display Gold gram equivalent
/// - Show last updated timestamp in Jalali format
/// - Display helpful prompt when balance is zero
/// - Auto-refresh when market rates update
/// - Handle loading and error states

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardProvider _dashboardProvider;
  late MarketRateProvider _marketRateProvider;

  @override
  void initState() {
    super.initState();
    _dashboardProvider = context.read<DashboardProvider>();
    _marketRateProvider = context.read<MarketRateProvider>();

    _loadDashboard();

    // Listen for rate updates to refresh equivalents
    _marketRateProvider.addListener(_onRatesUpdated);
  }

  @override
  void dispose() {
    _marketRateProvider.removeListener(_onRatesUpdated);
    super.dispose();
  }

  void _onRatesUpdated() {
    // When rates update, recalculate equivalents in dashboard
    _dashboardProvider.updateWithNewRates(
      _marketRateProvider.usdRate,
      _marketRateProvider.goldRate,
    );
  }

  Future<void> _loadDashboard() async {
    try {
      await _dashboardProvider.fetchDashboard();
      // Also update with current rates
      _dashboardProvider.updateWithNewRates(
        _marketRateProvider.usdRate,
        _marketRateProvider.goldRate,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری داشبورد: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return _buildContent(provider);
        },
      ),
    );
  }

  Widget _buildContent(DashboardProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'خطایی رخ داد',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text('تلاش دوباره'),
            ),
          ],
        ),
      );
    }

    final dashboard = provider.dashboard;
    if (dashboard == null) {
      return const Center(
        child: Text('خطایی رخ داد'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadDashboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance cards section
            _buildBalanceCards(dashboard),

            const SizedBox(height: 24),

            // Zero balance prompt
            if (dashboard.totalToman == 0)
              _buildZeroBalancePrompt()
            else
              _buildLastUpdated(dashboard),

            const SizedBox(height: 24),

            // Category breakdown section (only show if balance > 0)
            if (dashboard.totalToman > 0) _buildCategoryBreakdownSection(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCards(DashboardData dashboard) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        BalanceCard(
          label: 'موجودی کل (تومان)',
          amount: PersianFormatter.formatNumber(dashboard.totalToman),
          currency: 'تومان',
          color: colorScheme.primary,
        ),
        const SizedBox(height: 4),
        BalanceCard(
          label: 'معادل دلار آمریکا',
          amount: PersianFormatter.toPersianDigits(dashboard.totalUsdEquivalent.toStringAsFixed(2)),
          currency: 'دلار',
          color: Colors.green.shade700,
        ),
        const SizedBox(height: 4),
        BalanceCard(
          label: 'معادل طلا (گرم)',
          amount: PersianFormatter.toPersianDigits(dashboard.totalGoldGramsEquivalent.toStringAsFixed(3)),
          currency: 'گرم',
          color: Colors.amber.shade800,
        ),
      ],
    );
  }

  Widget _buildZeroBalancePrompt() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.secondaryContainer),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: colorScheme.secondary, size: 48),
          const SizedBox(height: 16),
          Text(
            'شروع به ثبت تراکنش‌ها کنید',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای دیدن داشبورد خود، ابتدا یک تراکنش اضافه کنید.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-transaction');
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('افزودن تراکنش'),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(DashboardData dashboard) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'آخرین بروزرسانی: ${PersianFormatter.toPersianDigits(dashboard.lastUpdated)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CategoryBreakdownScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.pie_chart_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'تفکیک هزینه‌های ماه',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'برای مشاهده تحلیل دقیق هزینه‌ها بر اساس دسته‌بندی، ضربه بزنید.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
