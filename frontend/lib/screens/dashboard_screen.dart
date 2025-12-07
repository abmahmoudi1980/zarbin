import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/market_rate_provider.dart';
import '../services/api_client.dart';
import '../utils/persian_formatter.dart';
import '../widgets/balance_card.dart';

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

  void _loadDashboard() async {
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
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCards(DashboardData dashboard) {
    return Column(
      children: [
        BalanceCard(
          label: 'تومان',
          amount: PersianFormatter.formatNumber(dashboard.totalToman),
          currency: '﷼',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        BalanceCard(
          label: 'دلار آمریکا',
          amount: dashboard.totalUsdEquivalent.toStringAsFixed(2),
          currency: '\$',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        BalanceCard(
          label: 'طلا (گرم)',
          amount: dashboard.totalGoldGramsEquivalent.toStringAsFixed(3),
          currency: 'g',
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildZeroBalancePrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
          const SizedBox(height: 12),
          Text(
            'شروع به ثبت تراکنش‌ها کنید',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای دیدن داشبورد خود، ابتدا یک تراکنش اضافه کنید.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(DashboardData dashboard) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'آخرین بروزرسانی: ${PersianFormatter.convertToPersianNumerals(dashboard.lastUpdated)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
