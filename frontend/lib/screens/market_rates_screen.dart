import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/market_rate_provider.dart';
import '../utils/jalali_helper.dart';
import '../utils/persian_formatter.dart';
import '../widgets/rate_card.dart';

/// MarketRatesScreen - Main screen displaying live market rates
/// 
/// Features:
/// - Display current rates for USD, Gold (gram), and Bahar Azadi Coin
/// - Show Jalali timestamp with Persian numerals
/// - Pull-to-refresh functionality
/// - Stale data indicator (>5 minutes)
/// - Rate change indicators (up/down arrows with %)
/// - Loading and error states

class MarketRatesScreen extends StatefulWidget {
  const MarketRatesScreen({Key? key}) : super(key: key);

  @override
  State<MarketRatesScreen> createState() => _MarketRatesScreenState();
}

class _MarketRatesScreenState extends State<MarketRatesScreen> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    try {
      await context.read<MarketRateProvider>().refreshRates();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نرخ‌های بازار'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MarketRateProvider>(
        builder: (context, provider, child) {
          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            header: const WaterDropMaterialHeader(),
            child: _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(MarketRateProvider provider) {
    if (provider.isLoading && provider.rates.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null && provider.rates.isEmpty) {
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
              onPressed: () => provider.refreshRates(),
              child: const Text('تلاش دوباره'),
            ),
          ],
        ),
      );
    }

    if (provider.rates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            const Text(
              'نرخی دردسترس نیست',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchRates(),
              child: const Text('بارگذاری'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timestamp header
          if (provider.lastFetchTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTimestampHeader(provider),
            ),

          // Stale indicator
          if (provider.isStale)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildStaleIndicator(provider),
            ),

          // Rate cards
          ..._buildRateCards(provider),

          // Last updated info
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              'آخرین بروزرسانی: ${_formatLastUpdate(provider)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampHeader(MarketRateProvider provider) {
    final jalaliDate = JalaliHelper.toJalaliString(provider.lastFetchTime!);
    final timeStr = '${provider.lastFetchTime!.hour.toString().padLeft(2, '0')}:${provider.lastFetchTime!.minute.toString().padLeft(2, '0')}';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '$jalaliDate ساعت $timeStr',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaleIndicator(MarketRateProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'این نرخ ها ${provider.staleMinutes} دقیقه قدیمی هستند',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRateCards(MarketRateProvider provider) {
    return provider.rates.map((rate) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: RateCard(rate: rate),
      );
    }).toList();
  }

  String _formatLastUpdate(MarketRateProvider provider) {
    final now = DateTime.now();
    final diff = now.difference(provider.lastFetchTime!);

    if (diff.inSeconds < 60) {
      return 'اکنون';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} دقیقه پیش';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ساعت پیش';
    } else {
      return '${diff.inDays} روز پیش';
    }
  }
}
