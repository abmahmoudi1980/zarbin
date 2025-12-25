# Tasks: Automatic Market Rates Refresh

**Input**: Design documents from `/specs/002-auto-refresh-rates/`  
**Prerequisites**: ✅ plan.md, ✅ spec.md, ✅ research.md, ✅ data-model.md, ✅ contracts/  
**Organization**: Tasks grouped by user story (US1-US4) for independent implementation  
**Path Convention**: Monorepo with `backend/` (Rails) and `frontend/` (Flutter) subdirectories

---

## Format: `[ID] [P?] [Story] Description with file path`

- **[ID]**: Task sequential number (T001, T002, etc.)
- **[P]**: Parallelizable - can run independently (different files, no dependencies)
- **[Story]**: User story label (US1, US2, US3, US4) for story-phase tasks only
- **File Paths**: Exact locations for implementation

---

## Phase 1: Setup (No Setup Required)

**Status**: ✅ **SKIP - Not applicable**

This feature builds on existing infrastructure from 001-mvp-foundation. No new setup required.

---

## Phase 2: Foundational (No Foundation Required)

**Status**: ✅ **SKIP - Not applicable**

All required foundation (MarketRateProvider, ApiService, MarketRatesScreen) already exists from 001-mvp-foundation Phase 2 (T024-T043). This feature extends existing components only.

**Checkpoint**: Foundation already complete - user story implementation can begin immediately

---

## Phase 3: User Story 1 - Automatic Rate Updates (Priority: P1) 🎯 MVP

**Goal**: Users viewing the market rates screen see rates automatically update every 5 minutes without manual intervention

**Independent Test**: Open rates screen → wait 5 minutes → verify rates update automatically → see subtle loading indicator → verify timestamp updates

### Tests for User Story 1 (TDD: Write tests FIRST, ensure they FAIL)

- [ ] T001 [P] [US1] Unit test for timer lifecycle in provider in `frontend/test/providers/market_rate_provider_auto_refresh_test.dart`
- [ ] T002 [P] [US1] Widget test for auto-refresh initiation on screen load in `frontend/test/widgets/market_rates_screen_lifecycle_test.dart`
- [ ] T003 [P] [US1] Integration test for 5-minute periodic refresh timing in `frontend/test/integration/auto_refresh_timing_test.dart`

### Implementation for User Story 1

- [ ] T004 [US1] Add timer state fields to MarketRateProvider (_autoRefreshTimer, isAutoRefreshing) in `frontend/lib/providers/market_rate_provider.dart`
- [ ] T005 [US1] Implement startAutoRefresh() method with Timer.periodic in `frontend/lib/providers/market_rate_provider.dart`
- [ ] T006 [US1] Implement stopAutoRefresh() method with timer cancellation in `frontend/lib/providers/market_rate_provider.dart`
- [ ] T007 [US1] Implement _performAutoRefresh() with skip logic in `frontend/lib/providers/market_rate_provider.dart`
- [ ] T008 [US1] Override dispose() to cancel timer in `frontend/lib/providers/market_rate_provider.dart`
- [ ] T009 [US1] Call startAutoRefresh() in initState() of MarketRatesScreen in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T010 [US1] Call stopAutoRefresh() in dispose() of MarketRatesScreen in `frontend/lib/screens/market_rates_screen.dart`

**Checkpoint**: At this point, rates should auto-refresh every 5 minutes when screen is visible. This is the core MVP functionality.

---

## Phase 4: User Story 2 - Background Refresh with User Awareness (Priority: P2)

**Goal**: Users see subtle loading indicator during auto-refresh to know data is updating, without blocking interaction

**Independent Test**: Wait for auto-refresh trigger → observe subtle LinearProgressIndicator at top of screen → verify rates update → indicator disappears → UI remains interactive throughout

### Tests for User Story 2 (TDD: Write tests FIRST, ensure they FAIL)

- [ ] T011 [P] [US2] Widget test for loading indicator visibility during auto-refresh in `frontend/test/widgets/market_rates_screen_loading_test.dart`

### Implementation for User Story 2

- [ ] T012 [US2] Add LinearProgressIndicator widget to MarketRatesScreen build method in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T013 [US2] Bind indicator visibility to provider.isAutoRefreshing state in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T014 [US2] Style indicator with subtle colors (2px height, semi-transparent) in `frontend/lib/screens/market_rates_screen.dart`

**Checkpoint**: At this point, users have visual feedback during auto-refresh. Both US1 and US2 work independently.

---

## Phase 5: User Story 3 - Manual Refresh Coexistence (Priority: P2)

**Goal**: Pull-to-refresh gesture still works, resets auto-refresh timer to prevent duplicate requests, provides immediate user feedback

**Independent Test**: Perform pull-to-refresh → rates update immediately → verify next auto-refresh occurs 5 minutes later (not sooner) → perform another manual refresh at 3 minutes → verify timer resets again

### Tests for User Story 3 (TDD: Write tests FIRST, ensure they FAIL)

- [ ] T015 [P] [US3] Integration test for timer reset after manual refresh in `frontend/test/integration/manual_refresh_coordination_test.dart`
- [ ] T016 [P] [US3] Unit test for concurrent request prevention in `frontend/test/providers/market_rate_provider_coordination_test.dart`

### Implementation for User Story 3

- [ ] T017 [US3] Add _isManualRefreshing flag to MarketRateProvider in `frontend/lib/providers/market_rate_provider.dart`
- [ ] T018 [US3] Modify refreshRates() to set flag, stop timer, restart after completion in `frontend/lib/providers/market_rate_provider.dart`
- [ ] T019 [US3] Add skip logic in _performAutoRefresh() to check _isManualRefreshing in `frontend/lib/providers/market_rate_provider.dart`

**Checkpoint**: At this point, manual and automatic refresh work together without conflicts. US1, US2, and US3 all work independently.

---

## Phase 6: User Story 4 - Battery and Data Optimization (Priority: P3)

**Goal**: Auto-refresh pauses when app is backgrounded or screen is not visible, resumes immediately when user returns, conserving battery and data

**Independent Test**: Background app (press home) → wait 10 minutes → no network requests logged → return to app → immediate refresh occurs → auto-refresh resumes every 5 minutes

### Tests for User Story 4 (TDD: Write tests FIRST, ensure they FAIL)

- [ ] T020 [P] [US4] Widget test for lifecycle observer registration/cleanup in `frontend/test/widgets/market_rates_screen_observer_test.dart`
- [ ] T021 [P] [US4] Integration test for pause on AppLifecycleState.paused in `frontend/test/integration/lifecycle_state_test.dart`
- [ ] T022 [P] [US4] Integration test for resume on AppLifecycleState.resumed in `frontend/test/integration/lifecycle_state_test.dart`

### Implementation for User Story 4

- [ ] T023 [US4] Add WidgetsBindingObserver mixin to _MarketRatesScreenState in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T024 [US4] Register observer in initState() with WidgetsBinding.instance.addObserver(this) in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T025 [US4] Unregister observer in dispose() with removeObserver(this) in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T026 [US4] Implement didChangeAppLifecycleState() method in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T027 [US4] Handle AppLifecycleState.resumed (fetch + start timer) in didChangeAppLifecycleState() in `frontend/lib/screens/market_rates_screen.dart`
- [ ] T028 [US4] Handle AppLifecycleState.paused (stop timer) in didChangeAppLifecycleState() in `frontend/lib/screens/market_rates_screen.dart`

**Checkpoint**: All user stories complete and independently functional. Auto-refresh is battery-efficient and lifecycle-aware.

---

## Phase 7: Polish & Validation

**Purpose**: Final testing, documentation, and validation of complete feature

- [ ] T029 [P] Run all unit tests and ensure 100% pass in `frontend/test/`
- [ ] T030 [P] Run all widget tests and ensure 100% pass in `frontend/test/widgets/`
- [ ] T031 [P] Run all integration tests and ensure 100% pass in `frontend/test/integration/`
- [ ] T032 Perform manual testing checklist from quickstart.md
- [ ] T033 Memory leak test: navigate away/back 10 times, verify stable memory
- [ ] T034 [P] Code review: verify timer cleanup, lifecycle management, error handling
- [ ] T035 [P] Performance test with Flutter DevTools: verify 60fps during auto-refresh
- [ ] T036 Update app README.md with auto-refresh behavior documentation in `README.md`
- [ ] T037 Add release notes entry for auto-refresh feature

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: ✅ SKIP - No setup needed
- **Foundational (Phase 2)**: ✅ SKIP - Foundation exists from 001-mvp-foundation
- **User Stories (Phase 3-6)**: Can proceed immediately in priority order or in parallel
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies - can start immediately (core auto-refresh)
- **User Story 2 (P2)**: Depends on US1 T004-T010 (needs isAutoRefreshing state) - adds visual feedback
- **User Story 3 (P2)**: Depends on US1 T004-T010 (needs timer management) - adds manual coordination
- **User Story 4 (P3)**: Depends on US1 T009-T010 (needs screen lifecycle) - adds background pause

### Within Each User Story

**Standard TDD Flow**:
1. Write tests FIRST (marked [P] can run in parallel)
2. Run tests, verify they FAIL
3. Implement tasks in order (dependencies noted)
4. Run tests, verify they PASS
5. Verify story works independently
6. Move to next priority

**User Story 1 Flow**:
- T001-T003 (tests) → all can run in parallel, must fail before T004
- T004-T008 (provider changes) → must be sequential (modify same file)
- T009-T010 (screen changes) → must be sequential (modify same file)
- Run tests → should all pass

**User Story 2 Flow**:
- T011 (test) → must fail before T012
- T012-T014 (UI changes) → must be sequential (modify same file)
- Depends on US1 complete (needs T004 isAutoRefreshing state)

**User Story 3 Flow**:
- T015-T016 (tests) → can run in parallel, must fail before T017
- T017-T019 (coordination logic) → must be sequential (modify same file)
- Depends on US1 complete (needs T005-T006 timer methods)

**User Story 4 Flow**:
- T020-T022 (tests) → can run in parallel, must fail before T023
- T023-T028 (lifecycle management) → must be sequential (modify same file)
- Depends on US1 T009-T010 (needs screen structure)

### Parallel Opportunities

**If working solo**: Execute in priority order (US1 → US2 → US3 → US4)

**If working with team (2 developers)**:
- Dev 1: US1 (core) → US3 (manual coordination)
- Dev 2: Wait for US1 T004 → US2 (loading indicator) → US4 (lifecycle)

**Test Parallelization**:
- All tests within a user story marked [P] can run simultaneously
- All Polish phase tasks marked [P] can run simultaneously

---

## Implementation Strategy

### MVP-First Approach (Recommended)

1. **Implement User Story 1 only** (T001-T010)
   - Stop here and validate
   - Deploy if ready
   - This is the core value: automatic updates

2. **Add User Story 2** (T011-T014)
   - Adds user awareness
   - Still independently deployable

3. **Add User Story 3** (T015-T019)
   - Improves UX coordination
   - Prevents edge cases

4. **Add User Story 4** (T020-T028)
   - Battery optimization
   - Nice-to-have polish

### Full Feature Approach

1. Complete all User Stories (T001-T028)
2. Complete Polish phase (T029-T037)
3. Deploy complete feature

### Time Estimates

| Phase | Tasks | Estimated Time | Notes |
|-------|-------|----------------|-------|
| US1 Tests | T001-T003 | 30 min | Parallel possible |
| US1 Implementation | T004-T010 | 60 min | Sequential (same files) |
| US2 Tests | T011 | 10 min | Simple widget test |
| US2 Implementation | T012-T014 | 15 min | UI only |
| US3 Tests | T015-T016 | 20 min | Parallel possible |
| US3 Implementation | T017-T019 | 30 min | Sequential logic |
| US4 Tests | T020-T022 | 30 min | Parallel possible |
| US4 Implementation | T023-T028 | 45 min | Sequential lifecycle |
| Polish | T029-T037 | 60 min | Some parallel |
| **Total** | **37 tasks** | **~5 hours** | With testing |

**MVP (US1 only)**: ~1.5 hours  
**MVP + UX (US1-US2)**: ~2 hours  
**Full Feature**: ~5 hours

---

## Validation Checkpoints

### After User Story 1 (T010)
✅ Open rates screen  
✅ Wait 5 minutes (or change timer to 30 seconds for testing)  
✅ Verify rates update automatically  
✅ Navigate away and back  
✅ Verify no memory leaks (timer cleaned up)

### After User Story 2 (T014)
✅ All US1 tests still pass  
✅ Subtle loading indicator appears during auto-refresh  
✅ Indicator disappears after refresh completes  
✅ UI remains interactive during refresh

### After User Story 3 (T019)
✅ All US1-US2 tests still pass  
✅ Pull-to-refresh works immediately  
✅ Auto-refresh timer resets after manual refresh  
✅ No concurrent requests occur

### After User Story 4 (T028)
✅ All US1-US3 tests still pass  
✅ Background app → no network requests  
✅ Return to app → immediate refresh  
✅ Auto-refresh resumes after return

### After Polish (T037)
✅ All 31+ tests pass  
✅ No memory leaks detected  
✅ 60fps maintained during auto-refresh  
✅ Documentation updated  
✅ Ready for production

---

## Notes

- **Backend Changes**: None required - existing `/api/v1/rates` endpoint sufficient
- **Breaking Changes**: None - feature is additive only
- **Dependencies**: No new packages needed - uses dart:async Timer
- **Testing**: Comprehensive TDD approach with unit, widget, and integration tests
- **Performance**: Designed for 60fps, verified with Flutter DevTools
- **Memory**: Timer cleanup critical - multiple tests verify no leaks
- **Battery**: Lifecycle management prevents background polling

**Success Criteria Met**:
- ✅ Rates update every 5 minutes automatically
- ✅ Non-blocking UI during refresh
- ✅ Manual refresh coordination
- ✅ Battery-efficient background pause
- ✅ No memory leaks
- ✅ Independent user stories
- ✅ Comprehensive test coverage
