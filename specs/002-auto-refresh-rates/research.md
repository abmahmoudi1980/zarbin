# Research: Automatic Market Rates Refresh

**Feature**: 002-auto-refresh-rates  
**Date**: December 25, 2025  
**Purpose**: Resolve technical unknowns and establish implementation patterns

## Research Questions

Based on Technical Context analysis, the following areas require research:

1. How to implement periodic timers in Flutter with proper lifecycle management?
2. How to detect app foreground/background state changes in Flutter?
3. How to prevent memory leaks when disposing widgets with active timers?
4. How to coordinate manual refresh with automatic refresh to avoid race conditions?
5. What are best practices for showing non-blocking loading indicators during background refresh?

## Research Findings

### 1. Flutter Periodic Timer Management

**Decision**: Use `Timer.periodic` from `dart:async` with cleanup in widget disposal

**Pattern**:
```dart
import 'dart:async';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }
  
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      // Refresh logic here
      _fetchData();
    });
  }
  
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}
```

**Rationale**: 
- `Timer.periodic` is built-in Dart, no dependencies needed
- Calling `cancel()` in `dispose()` prevents memory leaks
- Nullable `Timer?` allows checking if timer is active before cancellation

**Alternatives considered**:
- Stream-based approach with `Stream.periodic`: More complex, unnecessary for simple timing
- Third-party packages (like `periodic_task`): Adds dependency for solved problem

**References**: Flutter Timer API documentation, Dart async library patterns

---

### 2. App Lifecycle State Detection

**Decision**: Use `WidgetsBindingObserver` mixin with `AppLifecycleState` enum

**Pattern**:
```dart
class _MyWidgetState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App returned to foreground
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        // App went to background
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (transition state)
        break;
      case AppLifecycleState.detached:
        // App is detached from engine
        break;
    }
  }
  
  void _onAppResumed() {
    _fetchData(); // Immediate refresh
    _startAutoRefresh(); // Resume timer
  }
  
  void _onAppPaused() {
    _stopAutoRefresh(); // Pause timer to save battery
  }
}
```

**Rationale**:
- Built-in Flutter mechanism, no dependencies
- Reliable detection of foreground/background transitions
- `resumed` state = app visible, `paused` state = app backgrounded
- Mixin pattern keeps code organized

**Alternatives considered**:
- Manual visibility tracking: Error-prone, misses system-level events
- Third-party packages: Unnecessary for core Flutter functionality

**References**: Flutter WidgetsBindingObserver API, app lifecycle documentation

---

### 3. Memory Leak Prevention for Timers

**Decision**: Always cancel timers in `dispose()`, use nullable timer references

**Best Practices**:

1. **Null-safe cancellation**:
   ```dart
   Timer? _timer;
   
   void _stopTimer() {
     _timer?.cancel();
     _timer = null;
   }
   
   @override
   void dispose() {
     _stopTimer();
     super.dispose();
   }
   ```

2. **Check before starting**:
   ```dart
   void _startTimer() {
     _stopTimer(); // Cancel existing timer if any
     _timer = Timer.periodic(Duration(minutes: 5), _callback);
   }
   ```

3. **Widget tree changes**:
   - Timer cancellation must happen in `dispose()`, not `deactivate()`
   - For StatefulWidgets that rebuild frequently, keep timer at state level
   - Don't recreate timers on every build - use `initState()` once

**Rationale**:
- Dart's garbage collector can't collect timer callbacks if they're still scheduled
- Uncancelled timers continue firing even after widget is removed from tree
- Nullable pattern makes it safe to call cancel multiple times

**Common mistakes to avoid**:
- Forgetting to cancel timer in dispose
- Creating new timer on every build
- Not nulling out timer reference after cancellation

**References**: Flutter performance best practices, Dart Timer memory management

---

### 4. Coordinating Manual and Automatic Refresh

**Decision**: Reset auto-refresh timer after manual refresh, skip auto-refresh if manual is in progress

**Pattern**:
```dart
bool _isManualRefreshing = false;

Future<void> _onManualRefresh() async {
  _isManualRefreshing = true;
  _stopAutoRefresh(); // Stop timer during manual refresh
  
  try {
    await _fetchData();
  } finally {
    _isManualRefreshing = false;
    _startAutoRefresh(); // Restart timer (resets to full 5 minutes)
  }
}

void _onAutoRefresh() {
  if (_isManualRefreshing) {
    return; // Skip if manual refresh in progress
  }
  _fetchData();
}
```

**Rationale**:
- Prevents duplicate simultaneous network requests
- Manual refresh takes priority (immediate user feedback)
- Timer reset after manual refresh avoids refresh within 2 minutes (user expectation)
- Flag pattern is simpler than async coordination

**Alternatives considered**:
- Debouncing: Too complex, doesn't handle priority correctly
- Request cancellation: Requires more complex HTTP client management
- Ignoring the problem: Wastes bandwidth, confuses backend analytics

**References**: Flutter async patterns, state management best practices

---

### 5. Non-Blocking Loading Indicators

**Decision**: Show subtle indicator in existing UI without blocking interaction

**Pattern**:
```dart
class _MyWidgetState extends State<MyWidget> {
  bool _isAutoRefreshing = false;
  
  Future<void> _autoRefresh() async {
    setState(() => _isAutoRefreshing = true);
    
    try {
      await _fetchData();
    } finally {
      if (mounted) {
        setState(() => _isAutoRefreshing = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isAutoRefreshing)
          LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
          ),
        // Rest of content
        Expanded(child: _buildRatesList()),
      ],
    );
  }
}
```

**UI Guidelines**:
- Use `LinearProgressIndicator` at top of screen (2-3px height)
- Keep content fully scrollable and interactive during refresh
- Don't use modal loading (CircularProgressIndicator in center)
- Distinguish from pull-to-refresh indicator (different position/color)

**Rationale**:
- Users can continue viewing/scrolling during background refresh
- Subtle indicator provides feedback without being intrusive
- Maintains app responsiveness (Constitution Principle III)
- `mounted` check prevents setState after disposal

**Alternatives considered**:
- No indicator: Users unsure if data is updating
- Modal loading: Blocks interaction, poor UX for background operation
- Snackbar notification: Too intrusive for frequent operation

**References**: Material Design loading patterns, Flutter progress indicators

---

## Implementation Recommendations

### Recommended Approach

1. **Modify `MarketRateProvider`**:
   - Add `startAutoRefresh()` and `stopAutoRefresh()` methods
   - Manage `Timer.periodic` instance
   - Add `isAutoRefreshing` boolean state for UI indicator

2. **Modify `MarketRatesScreen`**:
   - Add `WidgetsBindingObserver` mixin to state class
   - Call `provider.startAutoRefresh()` in `initState()`
   - Implement `didChangeAppLifecycleState()` for pause/resume
   - Call `provider.stopAutoRefresh()` in `dispose()`
   - Add subtle `LinearProgressIndicator` when `isAutoRefreshing == true`

3. **Coordinate with Pull-to-Refresh**:
   - In `_onRefresh()` handler: stop auto-refresh, fetch, restart timer
   - Prevents concurrent requests

4. **Testing Strategy**:
   - Widget test: Verify timer starts in initState, stops in dispose
   - Widget test: Verify lifecycle observer registered/unregistered
   - Integration test: Mock time advance, verify refresh triggered
   - Integration test: Verify no refresh when app backgrounded

### Technology Stack Impact

**No new dependencies required**:
- `dart:async` Timer - built-in
- `WidgetsBindingObserver` - built-in Flutter
- Existing `provider` package for state management
- Existing `dio` for HTTP requests

**Aligns with Constitution**:
- ✅ Simplicity & YAGNI: Uses built-in Flutter APIs, no new packages
- ✅ Responsive UX: Non-blocking updates, maintains 60fps
- ✅ Test-Driven: Clear testing strategy for timer lifecycle

### Key Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Timer not cancelled, memory leak | High | Always cancel in dispose(), add tests verifying cancellation |
| Auto-refresh continues when backgrounded | Medium | Use WidgetsBindingObserver to pause/resume |
| Concurrent requests (manual + auto) | Medium | Use flag to skip auto-refresh during manual refresh |
| Timer fires after widget disposed | Low | Check `mounted` before setState in callback |
| 5-minute interval too slow/fast | Low | Make interval configurable constant for easy adjustment |

---

## Conclusion

All technical unknowns have been resolved using built-in Flutter APIs. No new dependencies required. Implementation is straightforward with clear patterns for timer management, lifecycle integration, and coordination with existing pull-to-refresh functionality.

**Ready to proceed to Phase 1: Design & Contracts**
