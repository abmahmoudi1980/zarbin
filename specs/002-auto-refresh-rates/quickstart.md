# Quickstart: Automatic Market Rates Refresh

**Feature**: 002-auto-refresh-rates  
**Estimated Time**: 2-3 hours  
**Difficulty**: Intermediate

## Overview

Implement automatic polling of market rates every 5 minutes in the Flutter app. The rates screen will refresh data without user intervention, with proper lifecycle management to pause when backgrounded.

## Prerequisites

- Flutter development environment set up
- Existing Zarbin project cloned and running
- Familiarity with Flutter StatefulWidget lifecycle
- Understanding of Provider state management
- Backend Rails server running on localhost:3000 (or configured URL)

## Quick Reference

**Files to Modify**:
- `frontend/lib/providers/market_rate_provider.dart` (~50 lines added)
- `frontend/lib/screens/market_rates_screen.dart` (~40 lines added)

**Files to Create**:
- `frontend/test/widgets/market_rates_screen_test.dart` (new)
- `frontend/test/integration/auto_refresh_timing_test.dart` (new)

**No backend changes required** ✅

---

## Step-by-Step Implementation

### Step 1: Understand Current Implementation (5 minutes)

**Read these files first**:
1. `frontend/lib/providers/market_rate_provider.dart` - Current state management
2. `frontend/lib/screens/market_rates_screen.dart` - Current UI and pull-to-refresh

**Key existing patterns**:
- `MarketRateProvider` uses `ChangeNotifier` from provider package
- Screen uses `SmartRefresher` for pull-to-refresh gesture
- `refreshRates()` method fetches data and updates state
- `isLoading` flag controls loading UI

---

### Step 2: Add Timer State to Provider (30 minutes)

**File**: `frontend/lib/providers/market_rate_provider.dart`

**TDD Approach** - Write test first:

```dart
// Test file: test/providers/market_rate_provider_test.dart
test('should start and stop auto-refresh timer', () {
  final provider = MarketRateProvider(mockApiService);
  
  // Timer should not exist initially
  expect(provider.isAutoRefreshing, false);
  
  // Start timer
  provider.startAutoRefresh();
  // Timer is now active (verified by cancellation not throwing)
  
  // Stop timer
  provider.stopAutoRefresh();
  expect(provider.isAutoRefreshing, false);
});
```

**Implementation** - Add to `MarketRateProvider` class:

```dart
import 'dart:async';

class MarketRateProvider extends ChangeNotifier {
  // Existing fields...
  List<MarketRate> _rates = [];
  bool _isLoading = false;
  String? _error;
  
  // New fields for auto-refresh
  Timer? _autoRefreshTimer;
  bool _isAutoRefreshing = false;
  bool _isManualRefreshing = false;
  
  static const Duration _autoRefreshInterval = Duration(minutes: 5);
  
  // Existing getters...
  bool get isLoading => _isLoading;
  List<MarketRate> get rates => _rates;
  
  // New getter
  bool get isAutoRefreshing => _isAutoRefreshing;
  
  // New methods
  void startAutoRefresh() {
    stopAutoRefresh(); // Cancel existing timer if any
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (timer) {
      _performAutoRefresh();
    });
  }
  
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
  
  Future<void> _performAutoRefresh() async {
    if (_isManualRefreshing || _isAutoRefreshing) {
      return; // Skip if already refreshing
    }
    
    _isAutoRefreshing = true;
    notifyListeners();
    
    try {
      await fetchRates(); // Existing method
    } catch (e) {
      // Log error but don't throw - maintain existing rates
      debugPrint('Auto-refresh failed: $e');
    } finally {
      _isAutoRefreshing = false;
      notifyListeners();
    }
  }
  
  // Modified existing method
  Future<void> refreshRates() async {
    _isManualRefreshing = true;
    stopAutoRefresh(); // Pause during manual refresh
    
    try {
      await fetchRates(); // Existing implementation
    } finally {
      _isManualRefreshing = false;
      startAutoRefresh(); // Resume (resets timer)
    }
  }
  
  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
```

**Run test**: `flutter test test/providers/market_rate_provider_test.dart`

---

### Step 3: Add Lifecycle Management to Screen (45 minutes)

**File**: `frontend/lib/screens/market_rates_screen.dart`

**TDD Approach** - Write widget test first:

```dart
// Test file: test/widgets/market_rates_screen_test.dart
testWidgets('should start auto-refresh on init and stop on dispose', (tester) async {
  final mockProvider = MockMarketRateProvider();
  
  await tester.pumpWidget(
    ChangeNotifierProvider<MarketRateProvider>.value(
      value: mockProvider,
      child: MaterialApp(home: MarketRatesScreen()),
    ),
  );
  
  // Verify startAutoRefresh was called
  verify(() => mockProvider.startAutoRefresh()).called(1);
  
  // Dispose screen
  await tester.pumpWidget(Container());
  
  // Verify stopAutoRefresh was called
  verify(() => mockProvider.stopAutoRefresh()).called(1);
});
```

**Implementation** - Modify `_MarketRatesScreenState`:

```dart
import 'package:flutter/material.dart';

class _MarketRatesScreenState extends State<MarketRatesScreen> 
    with WidgetsBindingObserver {
  
  late RefreshController _refreshController;
  
  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    
    // Register as lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Start auto-refresh after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<MarketRateProvider>();
        provider.refreshRates(); // Initial fetch
        provider.startAutoRefresh(); // Start timer
      }
    });
  }
  
  @override
  void dispose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Stop auto-refresh
    context.read<MarketRateProvider>().stopAutoRefresh();
    
    _refreshController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final provider = context.read<MarketRateProvider>();
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - refresh immediately and restart timer
        provider.refreshRates();
        provider.startAutoRefresh();
        break;
        
      case AppLifecycleState.paused:
        // App went to background - stop timer to save battery
        provider.stopAutoRefresh();
        break;
        
      default:
        break;
    }
  }
  
  // Rest of existing implementation...
}
```

**Run test**: `flutter test test/widgets/market_rates_screen_test.dart`

---

### Step 4: Add Loading Indicator (15 minutes)

**File**: `frontend/lib/screens/market_rates_screen.dart`

**Modify `_buildContent` method** to show subtle indicator:

```dart
Widget _buildContent(MarketRateProvider provider) {
  return Column(
    children: [
      // Subtle loading indicator for background refresh
      if (provider.isAutoRefreshing)
        LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor.withOpacity(0.6),
          ),
        ),
      
      // Existing content (rates list, error states, etc.)
      Expanded(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          header: const WaterDropMaterialHeader(),
          child: _buildRatesList(provider),
        ),
      ),
    ],
  );
}
```

**Test manually**:
1. Run app: `flutter run`
2. Navigate to rates screen
3. Wait and observe subtle indicator at top every 5 minutes

---

### Step 5: Write Integration Tests (30 minutes)

**File**: `frontend/test/integration/auto_refresh_timing_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  testWidgets('should auto-refresh after 5 minutes', (tester) async {
    fakeAsync((async) {
      // Setup
      final mockProvider = MockMarketRateProvider();
      
      // Pump widget
      await tester.pumpWidget(/* screen with provider */);
      
      // Verify initial fetch
      verify(() => mockProvider.refreshRates()).called(1);
      verify(() => mockProvider.startAutoRefresh()).called(1);
      
      // Advance time by 5 minutes
      async.elapse(Duration(minutes: 5));
      await tester.pump();
      
      // Verify auto-refresh was triggered
      verify(() => mockProvider.fetchRates()).called(1);
      
      // Advance another 5 minutes
      async.elapse(Duration(minutes: 5));
      await tester.pump();
      
      // Verify second auto-refresh
      verify(() => mockProvider.fetchRates()).called(2);
    });
  });
  
  testWidgets('should not auto-refresh when backgrounded', (tester) async {
    // Test that stopAutoRefresh is called on AppLifecycleState.paused
    // and startAutoRefresh on AppLifecycleState.resumed
  });
}
```

**Run tests**: `flutter test test/integration/`

---

### Step 6: Manual Testing Checklist (20 minutes)

**Test Scenarios**:

1. **Initial Load**:
   - [ ] Open rates screen
   - [ ] Rates appear immediately
   - [ ] No errors in console

2. **Auto-Refresh**:
   - [ ] Wait 5 minutes (or reduce timer for testing)
   - [ ] Subtle loading indicator appears
   - [ ] Rates update automatically
   - [ ] Console shows successful fetch

3. **Manual Refresh During Auto**:
   - [ ] Perform pull-to-refresh
   - [ ] Rates update immediately
   - [ ] Next auto-refresh happens 5 min after manual

4. **Background/Foreground**:
   - [ ] Navigate away from rates screen
   - [ ] Return after 2 minutes
   - [ ] Rates refresh immediately on return
   - [ ] Auto-refresh resumes

5. **App Background**:
   - [ ] Press home button (app to background)
   - [ ] Wait 10 minutes
   - [ ] Return to app
   - [ ] Rates refresh immediately
   - [ ] No network requests during background (check logs)

6. **Memory Leak Test**:
   - [ ] Open rates screen
   - [ ] Navigate away
   - [ ] Return to rates screen
   - [ ] Repeat 10 times
   - [ ] Check memory usage (should be stable)

---

## Testing Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/providers/market_rate_provider_test.dart

# Run with coverage
flutter test --coverage

# Run widget tests only
flutter test test/widgets/

# Run integration tests only
flutter test test/integration/

# Run in verbose mode
flutter test --verbose
```

---

## Troubleshooting

### Issue: Timer not stopping, memory leak

**Solution**: Verify `dispose()` calls `stopAutoRefresh()` before `super.dispose()`

```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  context.read<MarketRateProvider>().stopAutoRefresh(); // Must be before super
  _refreshController.dispose();
  super.dispose();
}
```

---

### Issue: Auto-refresh continues when backgrounded

**Solution**: Check `didChangeAppLifecycleState` is implemented and observer is registered

```dart
// Must add mixin
class _MarketRatesScreenState extends State<MarketRatesScreen> 
    with WidgetsBindingObserver { // Don't forget this!
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Register observer
  }
}
```

---

### Issue: Concurrent requests (manual + auto)

**Solution**: Check `_isManualRefreshing` flag is set correctly

```dart
Future<void> refreshRates() async {
  _isManualRefreshing = true; // Set before async work
  stopAutoRefresh();
  
  try {
    await fetchRates();
  } finally {
    _isManualRefreshing = false; // Reset in finally
    startAutoRefresh();
  }
}
```

---

### Issue: setState called after dispose error

**Solution**: Check `mounted` before `setState` in async callbacks

```dart
try {
  await fetchRates();
} finally {
  if (mounted) { // Add this check
    _isAutoRefreshing = false;
    notifyListeners();
  }
}
```

---

## Performance Checklist

- [ ] No frame drops during auto-refresh (use Flutter DevTools)
- [ ] Loading indicator smooth at 60fps
- [ ] Memory stable after multiple screen navigations
- [ ] No network requests when backgrounded (use network inspector)
- [ ] Timer cleanup verified (no console warnings)

---

## Configuration Options

To change the auto-refresh interval (for testing or tuning):

```dart
// In MarketRateProvider
static const Duration _autoRefreshInterval = Duration(minutes: 5); // Change this

// For testing, temporarily use:
static const Duration _autoRefreshInterval = Duration(seconds: 30); // 30 seconds
```

**Remember to change back to 5 minutes before commit!**

---

## Next Steps

After implementation is complete:

1. **Code Review**: Submit PR with changes
2. **QA Testing**: Test on physical devices (Android/iOS)
3. **Performance Profiling**: Use Flutter DevTools to verify no memory leaks
4. **Documentation**: Update app README with auto-refresh behavior
5. **User Communication**: Add note in release notes about auto-refresh feature

---

## Estimated Timeline

| Task | Time | Cumulative |
|------|------|------------|
| Step 1: Understanding | 5 min | 0:05 |
| Step 2: Provider changes | 30 min | 0:35 |
| Step 3: Screen lifecycle | 45 min | 1:20 |
| Step 4: Loading indicator | 15 min | 1:35 |
| Step 5: Integration tests | 30 min | 2:05 |
| Step 6: Manual testing | 20 min | 2:25 |
| Buffer for debugging | 35 min | 3:00 |

**Total: 3 hours**

---

## Resources

- [Flutter Timer API](https://api.flutter.dev/flutter/dart-async/Timer-class.html)
- [WidgetsBindingObserver](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Widget Lifecycle](https://flutter.dev/docs/development/ui/widgets-intro#stateful-widgets)

---

## Success Criteria

You'll know the feature is working when:

✅ Rates update automatically every 5 minutes without user action  
✅ Subtle loading indicator appears during background refresh  
✅ Manual pull-to-refresh still works and resets the timer  
✅ Auto-refresh pauses when app is backgrounded  
✅ Immediate refresh occurs when returning to screen  
✅ No memory leaks after repeated screen navigation  
✅ All tests pass  
✅ 60fps maintained during auto-refresh

Happy coding! 🚀
