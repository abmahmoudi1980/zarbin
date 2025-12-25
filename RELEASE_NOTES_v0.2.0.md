# Release Notes - Zarbin v0.2.0

**Release Date**: December 25, 2025
**Feature**: Automatic Market Rates Refresh

## What's New

### Automatic Rate Updates 🔄

The market rates screen now automatically refreshes exchange rates every 5 minutes, keeping your data current without manual intervention.

**Key Features**:

1. **Automatic Refresh Every 5 Minutes**
   - Rates update automatically while the screen is visible
   - No need to manually pull-to-refresh to see latest data
   - Aligns with backend refresh cycle for optimal data freshness

2. **Subtle Visual Feedback**
   - Thin progress indicator appears at top of screen during updates
   - Non-intrusive design keeps focus on rate information
   - UI remains fully interactive during refresh

3. **Battery & Data Optimization**
   - Auto-refresh automatically pauses when app is backgrounded
   - Resumes immediately when app returns to foreground
   - Smart lifecycle management prevents unnecessary network usage

4. **Smart Manual Refresh Coordination**
   - Pull-to-refresh still works for immediate updates
   - Manual refresh resets the 5-minute timer
   - Prevents duplicate network requests

## Technical Details

### Architecture
- Timer-based periodic refresh using Dart's `Timer.periodic`
- Lifecycle-aware using Flutter's `WidgetsBindingObserver`
- State management integrated with existing `MarketRateProvider`
- Zero new dependencies - uses built-in Flutter/Dart APIs

### Performance
- Maintains 60fps during auto-refresh
- Proper timer cleanup prevents memory leaks
- Non-blocking network operations
- Graceful error handling with retry on next cycle

### Testing
- 25 automated tests covering all scenarios
- Unit tests for provider logic
- Widget tests for UI behavior
- Integration tests for timing and coordination
- Lifecycle tests for background/foreground handling

## User Stories Implemented

✅ **US1**: Automatic rate updates every 5 minutes (Priority: P1)
✅ **US2**: Visual feedback during refresh (Priority: P2)
✅ **US3**: Manual refresh coordination (Priority: P2)
✅ **US4**: Battery optimization with lifecycle management (Priority: P3)

## Breaking Changes

None - This feature is fully backward compatible.

## Known Issues

None

## Migration Guide

No migration required. The feature works automatically when you open the market rates screen.

## Dependencies

No new dependencies added.

## Testing

All existing tests pass. To run auto-refresh specific tests:

```bash
cd frontend
flutter test test/providers/market_rate_provider_auto_refresh_test.dart
flutter test test/widgets/market_rates_screen_lifecycle_test.dart
flutter test test/integration/auto_refresh_timing_test.dart
```

## Contributors

- Implementation: GitHub Copilot
- Specification: Feature spec in `specs/002-auto-refresh-rates/`
- Testing: Comprehensive TDD approach with 25 automated tests

## Next Steps

This feature lays the groundwork for future enhancements:
- Configurable refresh intervals
- Network condition awareness
- Background sync for multiple screens
- Push notification support

---

For more details, see the feature specification at `specs/002-auto-refresh-rates/spec.md`
