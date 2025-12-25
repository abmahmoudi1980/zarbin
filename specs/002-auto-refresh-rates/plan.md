# Implementation Plan: Automatic Market Rates Refresh

**Branch**: `002-auto-refresh-rates` | **Date**: December 25, 2025 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-auto-refresh-rates/spec.md`

## Summary

Implement automatic periodic refresh of market rates data in the Flutter mobile app. The rates screen will automatically fetch updated exchange rates every 5 minutes when visible, with proper lifecycle management to pause during backgrounding and resume on return. This eliminates the need for manual pull-to-refresh while preserving that gesture for user-initiated updates.

## Technical Context

**Language/Version**: Dart 3.2+ (Flutter 3.16+), Ruby 3.4.1 (Rails 8.0)  
**Primary Dependencies**: Flutter (provider/riverpod for state, dio for HTTP), Rails backend already serving rates API  
**Storage**: Local provider state (in-memory), no persistence needed for auto-refresh timers  
**Testing**: Flutter widget tests for lifecycle, integration tests for network timing  
**Target Platform**: Flutter mobile (Android/iOS), interfacing with existing Rails backend
**Project Type**: Mobile + API (Flutter frontend, Rails backend)  
**Performance Goals**: Rates update within 10 seconds of scheduled refresh, UI remains at 60 fps during updates  
**Constraints**: No background network when app backgrounded, timer cleanup on screen disposal to prevent memory leaks  
**Scale/Scope**: Single screen modification (MarketRatesScreen), affects ~200 lines in frontend

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Core Principles Evaluation

✅ **I. Inflation-Centric Design**: Not applicable - feature is infrastructure for data freshness, doesn't change how rates are displayed or calculated

✅ **II. Privacy-First Data Handling**: Compliant - auto-refresh only calls existing public rates API (already skips authentication), no new data collection

✅ **III. Responsive & Resilient UX**: **DIRECTLY ALIGNED** - Auto-refresh ensures users see current data without manual interaction, loading indicators prevent UI blocking, graceful error handling maintains existing data on failures

✅ **IV. Test-Driven Development**: Compliant - requires widget tests for timer lifecycle, integration tests for refresh timing, TDD approach will be followed

✅ **V. Simplicity & YAGNI**: Compliant - minimal addition to existing screen, uses built-in Dart Timer class (no new dependencies), leverages existing MarketRateProvider infrastructure

### Technology Stack Compliance

✅ **Mobile Framework**: Flutter (latest stable) - already in use  
✅ **Mobile Storage**: Not applicable - timers are in-memory only  
✅ **Localization**: Not applicable - feature is behind-the-scenes, no new UI text

### Quality Gates

✅ **Pre-Commit**: Flutter analyze will catch any lint issues  
✅ **Testing**: Widget tests for lifecycle, integration tests for timing behavior  
✅ **Constitution Alignment**: Feature enhances UX responsiveness (Principle III)

**GATE STATUS**: ✅ PASSED - No violations, directly supports constitution principles

### Post-Phase 1 Re-Evaluation

*After completing research and design, re-checking constitution compliance:*

✅ **I. Inflation-Centric Design**: Still not applicable - design confirms no changes to rate display or calculations

✅ **II. Privacy-First Data Handling**: Confirmed compliant - polling contract shows public API only, no authentication, no new data storage

✅ **III. Responsive & Resilient UX**: **STRENGTHENED** - Design includes:
  - Non-blocking LinearProgressIndicator (60fps maintained)
  - Graceful error handling (existing data preserved)
  - Background pause (battery optimization)
  - Immediate refresh on resume (responsive feel)

✅ **IV. Test-Driven Development**: Confirmed compliant - Comprehensive test strategy:
  - Unit tests for provider timer lifecycle
  - Widget tests for screen lifecycle hooks
  - Integration tests for timing behavior
  - Memory leak tests for timer cleanup

✅ **V. Simplicity & YAGNI**: **EXEMPLARY** - Design confirms:
  - Zero new dependencies (dart:async Timer is built-in)
  - ~90 lines of code added total
  - Leverages existing infrastructure (Provider, ApiService)
  - No over-engineering (rejected stream-based alternatives)

**Final Constitution Status**: ✅✅ PASSED WITH EXCELLENCE

Design phase confirms feature is minimal, well-tested, and directly enhances user experience without compromising privacy or adding complexity. Exemplifies constitution principles II, III, IV, V.

## Project Structure

### Documentation (this feature)

```text
specs/002-auto-refresh-rates/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Mobile + API structure (Flutter frontend, Rails backend)
backend/
├── app/
│   ├── controllers/
│   │   └── api/v1/rates_controller.rb  # Existing - no changes needed
│   ├── models/
│   │   └── market_rate.rb              # Existing - no changes needed
│   └── services/
│       └── tgju_scraper_service.rb     # Existing - no changes needed
└── spec/
    └── requests/
        └── api/v1/rates_spec.rb        # Existing tests still apply

frontend/
├── lib/
│   ├── providers/
│   │   └── market_rate_provider.dart   # MODIFY: Add auto-refresh timer logic
│   ├── screens/
│   │   └── market_rates_screen.dart    # MODIFY: Integrate lifecycle hooks for timer
│   └── services/
│       └── api_service.dart            # Existing - no changes needed
└── test/
    ├── widgets/
    │   └── market_rates_screen_test.dart  # NEW: Widget tests for lifecycle
    └── integration/
        └── auto_refresh_timing_test.dart  # NEW: Integration tests for timing
```

**Structure Decision**: Using existing Mobile + API structure. Flutter frontend handles all auto-refresh logic (timer management, lifecycle hooks). Backend requires no changes - existing `/api/v1/rates` endpoint already supports repeated polling. All modifications confined to frontend presentation and state management layers.

## Complexity Tracking

> No violations - Constitution check passed cleanly. Feature aligns with existing architecture and principles.
