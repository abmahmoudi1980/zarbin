# Data Model: Automatic Market Rates Refresh

**Feature**: 002-auto-refresh-rates  
**Date**: December 25, 2025  
**Purpose**: Define state management and data flow for auto-refresh functionality

## Overview

This feature adds auto-refresh timing state to the existing `MarketRateProvider`. No new entities are introduced; existing `MarketRate` model remains unchanged. Backend API contract remains unchanged.

## State Management Extensions

### MarketRateProvider (Modified)

**Location**: `frontend/lib/providers/market_rate_provider.dart`

**Existing State** (no changes):
- `List<MarketRate> rates` - Current rate data
- `bool isLoading` - Loading state for UI
- `String? error` - Error message if fetch fails
- `DateTime? lastUpdated` - Timestamp of last successful fetch

**New State** (additions for auto-refresh):
- `Timer? _autoRefreshTimer` - Periodic timer for 5-minute intervals (private)
- `bool isAutoRefreshing` - Flag indicating background refresh in progress (public, for UI indicator)
- `bool _isManualRefreshing` - Flag to prevent concurrent manual/auto refreshes (private)

**New Methods**:

```dart
/// Start periodic auto-refresh with 5-minute interval
void startAutoRefresh() {
  stopAutoRefresh(); // Cancel existing timer if any
  _autoRefreshTimer = Timer.periodic(
    Duration(minutes: 5),
    (timer) => _performAutoRefresh(),
  );
}

/// Stop periodic auto-refresh and clean up timer
void stopAutoRefresh() {
  _autoRefreshTimer?.cancel();
  _autoRefreshTimer = null;
}

/// Internal: Execute auto-refresh if not already refreshing
Future<void> _performAutoRefresh() async {
  if (_isManualRefreshing || isAutoRefreshing) {
    return; // Skip if already refreshing
  }
  
  isAutoRefreshing = true;
  notifyListeners();
  
  try {
    await fetchRates(); // Existing method
  } finally {
    isAutoRefreshing = false;
    notifyListeners();
  }
}

/// Modified: Coordinate manual refresh with auto-refresh
Future<void> refreshRates() async {
  _isManualRefreshing = true;
  stopAutoRefresh(); // Pause auto-refresh during manual
  
  try {
    await fetchRates(); // Existing method
  } finally {
    _isManualRefreshing = false;
    startAutoRefresh(); // Resume auto-refresh (resets timer)
  }
}
```

**Lifecycle**:
- Timer created: When `startAutoRefresh()` called (in screen's `initState()`)
- Timer destroyed: When `stopAutoRefresh()` called (in screen's `dispose()` or app backgrounded)
- Timer reset: After manual refresh completes

**State Transitions**:

```
[Screen Loaded] 
    → startAutoRefresh() 
    → Timer active, waiting 5 minutes
    
[Timer Fires] 
    → Check if already refreshing (skip if yes)
    → Set isAutoRefreshing = true
    → Fetch data
    → Set isAutoRefreshing = false
    → Wait 5 minutes, repeat
    
[Manual Refresh]
    → Set _isManualRefreshing = true
    → stopAutoRefresh()
    → Fetch data
    → Set _isManualRefreshing = false
    → startAutoRefresh() (resets to 5 minutes)
    
[App Backgrounded]
    → stopAutoRefresh()
    → Timer cancelled
    
[App Resumed]
    → Fetch data immediately
    → startAutoRefresh()
    
[Screen Disposed]
    → stopAutoRefresh()
    → Timer cancelled permanently
```

---

## Existing Entity (No Changes)

### MarketRate

**Location**: `frontend/lib/models/market_rate.dart`

**Attributes** (unchanged):
- `String rateType` - Type identifier (e.g., "usd", "gold_gram", "bahar_azadi")
- `int valueInToman` - Current rate value in Iranian Toman
- `String label` - Display label (e.g., "دلار آمریکا")
- `DateTime timestamp` - When rate was last updated
- `bool stale` - Whether rate is older than 5 minutes
- `double? changePercent` - Percentage change from previous
- `String? changeDirection` - "up", "down", or "stable"

**Relationships**: None (value object)

**Validation**: No changes

---

## Screen Lifecycle State

### MarketRatesScreen Lifecycle

**Location**: `frontend/lib/screens/market_rates_screen.dart`

**Lifecycle Hooks**:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this); // Register lifecycle observer
  
  // Initial fetch and start auto-refresh
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      final provider = context.read<MarketRateProvider>();
      provider.refreshRates(); // Immediate fetch
      provider.startAutoRefresh(); // Start timer
    }
  });
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this); // Unregister observer
  context.read<MarketRateProvider>().stopAutoRefresh(); // Stop timer
  super.dispose();
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  final provider = context.read<MarketRateProvider>();
  
  switch (state) {
    case AppLifecycleState.resumed:
      provider.refreshRates(); // Immediate refresh
      provider.startAutoRefresh(); // Resume timer
      break;
    case AppLifecycleState.paused:
      provider.stopAutoRefresh(); // Pause timer
      break;
    default:
      break;
  }
}
```

**State Flow**:
1. Screen created → Register as lifecycle observer
2. After first frame → Fetch data immediately, start 5-minute timer
3. App backgrounded → Cancel timer (save battery)
4. App resumed → Fetch immediately, restart timer
5. Screen destroyed → Cancel timer, unregister observer

---

## Data Flow Diagram

```
[MarketRatesScreen]
       ↓ (initState)
    startAutoRefresh()
       ↓
[MarketRateProvider]
       ↓ (creates)
   [Timer - 5min]
       ↓ (fires periodically)
  _performAutoRefresh()
       ↓ (if not already refreshing)
    fetchRates()
       ↓ (HTTP GET)
[Backend API: /api/v1/rates]
       ↓ (JSON response)
   Parse MarketRate list
       ↓
   Update provider state
       ↓ (notifyListeners)
[MarketRatesScreen rebuilds]
       ↓
   Display updated rates


[User Pull-to-Refresh]
       ↓
   refreshRates()
       ↓
  stopAutoRefresh()
       ↓
   fetchRates()
       ↓
  startAutoRefresh() (timer reset)
```

---

## Memory Management

**Timer Cleanup Strategy**:
1. Always cancel timer in `dispose()` - prevents memory leaks
2. Use nullable `Timer?` - safe to cancel multiple times
3. Cancel before creating new timer - prevents multiple active timers
4. Check `mounted` before `setState` in async callbacks - prevents errors after disposal

**Observer Cleanup Strategy**:
1. Add observer in `initState()`
2. Remove observer in `dispose()` before timer cleanup
3. Prevents lifecycle callbacks after widget destroyed

---

## Testing Considerations

**State Transitions to Test**:
1. Timer starts when screen loads
2. Timer stops when screen disposed
3. Timer pauses when app backgrounded
4. Timer resumes when app foregrounded
5. Manual refresh resets timer
6. Auto-refresh skipped during manual refresh
7. No timer after disposal (memory leak test)

**Mock Points**:
- `Timer.periodic` - mock to test without waiting 5 minutes
- `WidgetsBinding.instance` - mock lifecycle state changes
- `ApiService.fetchRates()` - mock network responses

---

## Configuration

**Constants** (to be defined in provider or config):

```dart
// In MarketRateProvider or config file
static const Duration autoRefreshInterval = Duration(minutes: 5);
static const Duration staleThreshold = Duration(minutes: 5);
```

**Rationale for 5 minutes**:
- Aligns with backend rate update frequency (5 minutes)
- Balances data freshness with battery/bandwidth conservation
- Prevents stale indicator from appearing under normal conditions

---

## Backend Impact

**No changes required** to backend. Existing `/api/v1/rates` endpoint already supports repeated polling:
- Returns latest rates on each request
- Includes `timestamp` field for stale detection
- Includes `Cache-Control: max-age=300` (5 minutes)
- No rate limiting concerns for 5-minute intervals

---

## Summary

This data model extends existing state management with minimal additions:
- 3 new state fields in `MarketRateProvider`
- 4 new methods for timer lifecycle
- Lifecycle observer integration in `MarketRatesScreen`
- No new entities, no backend changes
- Clear state transitions with proper cleanup
