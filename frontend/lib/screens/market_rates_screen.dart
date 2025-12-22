import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/market_rate_provider.dart';
import '../utils/jalali_helper.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rate cards
          ..._buildRateCards(provider),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildRateCards(MarketRateProvider provider) {
    return provider.rates.map((rate) {
      return RateCard(rate: rate);
    }).toList();
  }
}
