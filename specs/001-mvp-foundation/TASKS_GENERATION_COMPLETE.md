# Tasks Generation Complete - Zarbin MVP Foundation

**Generated**: `tasks.md` (160 actionable tasks) + `contracts/transactions.yaml` (complete API spec)  
**Date**: Phase 1 → Phase 2 transition  
**Status**: ✅ Ready for Phase 2 implementation  

---

## Summary

### Tasks Generated: 160 Total Items

**Distribution by Phase**:

| Phase | Name | Task Count | Purpose |
|-------|------|-----------|---------|
| Phase 1 | Setup | 8 | Project initialization (Rails 8 + Flutter) |
| Phase 2 | Foundation | 27 | Blocking prerequisites (models, services, auth) |
| Phase 3 | US1: Market Rates | 15 | P1 - Core MVP feature (rates display + refresh) |
| Phase 4 | US2: Authentication | 24 | P2 - Register, OTP, login, session management |
| Phase 5 | US3: Transactions | 23 | P3 - Add income/expense with categories |
| Phase 6 | US4: Dashboard | 10 | P4 - Net worth in Toman + USD + Gold |
| Phase 7 | US5: Categories | 8 | P5 - Spending breakdown by category |
| Phase 8 | Polish | 45 | Testing, security, performance, deployment |
| **TOTAL** | | **160** | **Complete feature implementation** |

---

## Task Format Validation

✅ **ALL 160 tasks follow strict checklist format**:
```
- [ ] [TaskID] [P?] [Story] Description with file path
```

**Format Components**:
- ✅ Checkbox: `- [ ]` on every task
- ✅ Task ID: T001 → T160 (sequential, execution order)
- ✅ [P] marker: Applied to parallelizable tasks
- ✅ [Story] label: Applied to US1-US5 phase tasks only
- ✅ File paths: Exact locations for every implementation task

**Example valid tasks**:
- `- [ ] T001 Create Rails 8 project structure with Gemfile and main config files in backend/`
- `- [ ] T009 [P] Create User model with mobile_number, password_hash, account_status attributes in backend/app/models/user.rb`
- `- [ ] T036 [P] [US1] Contract test for GET /api/v1/rates in backend/spec/requests/api/v1/rates_spec.rb`

---

## User Story Breakdown

**Each user story is independently testable and deployable**:

| Story | Priority | Goal | Completion Tests | Task Count |
|-------|----------|------|---------------------|-----------|
| US1 | P1 🎯 MVP | View live rates (Gold, Coin, USD) with 5min refresh | Rates display → pull-refresh → stale indicator | 15 |
| US2 | P2 | Register with OTP + login with 7-day session | Register → OTP → login → persists 7 days | 24 |
| US3 | P3 | Add income/expense with category + Jalali date | Create transaction → dual-currency display → local cache | 23 |
| US4 | P4 | View net worth in Toman + USD + Gold equivalents | Dashboard loads → shows 3 balances → auto-updates | 10 |
| US5 | P5 | Category breakdown pie chart for current month | Transactions grouped → percentages calculated → chart displays | 8 |

---

## Parallelization Opportunities

**Can execute simultaneously after Phase 2 completion**:

### Backend Tracks (Independent implementation):
- US1 backend (T039-T050): Market rates API + caching + scheduling
- US2 backend (T059-T074): Auth controller + JWT + OTP service
- US3 backend (T081-T097): Transactions CRUD + currency conversion
- US4 backend (T101-T108): Dashboard aggregation + balance calculations
- US5 backend (T113-T120): Category breakdown + spending analytics

### Frontend Tracks (Independent implementation):
- US1 frontend (T043-T050): Rates screen + refresh + Jalali dates
- US2 frontend (T065-T074): Auth screens + token storage + form validation
- US3 frontend (T086-T097): Add transaction + categories + dual-currency display
- US4 frontend (T104-T108): Dashboard cards + rate subscriptions
- US5 frontend (T116-T120): Breakdown chart + category filtering

### Estimated Parallelization Benefit:
- **Sequential (Phases 1→2→3→4→5→6→7→8)**: ~8 weeks
- **Optimal (1→2→{3,4,5,6,7}||→8)**: ~4-5 weeks
- **With 2 teams (Backend + Frontend parallel)**: ~3 weeks

---

## API Contracts

**All 3 endpoints now specified**:

| Contract | Endpoints | Status | File |
|----------|-----------|--------|------|
| auth.yaml | Register, Verify OTP, Login | ✅ Complete (Phase 1) | `contracts/auth.yaml` |
| market-rates.yaml | Current rates, Historical rates | ✅ Complete (Phase 1) | `contracts/market-rates.yaml` |
| transactions.yaml | CRUD, Balance, Categories, Dashboard | ✅ NEW (Phase 2 prep) | `contracts/transactions.yaml` |

**transactions.yaml NEW endpoints**:
- `POST /transactions` - Create transaction (T081)
- `GET /transactions` - List with filtering (T089)
- `GET /transactions/{id}` - Get single (T089)
- `PATCH /transactions/{id}` - Update (T089)
- `DELETE /transactions/{id}` - Delete (T089)
- `GET /balance` - User's current balance (T102-T103)
- `GET /categories` - List all 7 categories (T113)
- `GET /dashboard` - Full dashboard summary (T119)

---

## Constitution Compliance

✅ **All 160 tasks maintain Zarbin Constitution v1.0.2**:

| Principle | Implementation in Tasks |
|-----------|------------------------|
| **Inflation-Centric** | T092: Dual-currency display (Toman + USD/Gold) in all screens |
| **Privacy-First** | T122-T123: Logging excludes PII; T154: Data encryption for passwords |
| **Responsive UX** | T040: 5-min rate caching; T024-T035: Local SQLite storage; T097: Offline sync |
| **TDD** | T036-T120: Tests first (marked [P] for parallel); Implementation after |
| **Simplicity** | T022: Solid Queue only (no Redis); T031-T035: No complex third-party auth |
| **Open-Source Ready** | T156: Generate API docs; T157-T160: CI/CD + deployment docs |

---

## Testing Strategy

**80% coverage target across both codebases**:

### Backend Tests (T127-T133, T149-T155):
- Unit tests for models (User auth, Transaction validation, Balance calculations)
- Service tests (MarketDataService, OtpService, CurrencyService, SpendingService)
- Controller tests (API contract tests for all 8 endpoints)
- Integration tests (Full user journeys from register → add transaction → view dashboard)
- Security tests (JWT validation, rate limiting, password hashing, OTP lockout)
- Performance tests (Rates <3s, Dashboard <2s, Auth <2min)

### Frontend Tests (T139-T148):
- Widget tests for all screens (MarketRatesScreen, RegisterScreen, LoginScreen, etc.)
- Unit tests for utilities (Persian formatting, Jalali date conversion, validators)
- Integration tests (Login flow, transaction creation, dashboard loading)
- Offline tests (Create transaction offline → sync when connected)
- Performance tests (App launch <3s, Dashboard load <2s, Transaction save <30s)
- UI tests (Persian numerals display, RTL layout on iOS/Android, Jalali calendar)

---

## Success Criteria Verification

**All 7 SC from spec.md covered by corresponding tasks**:

| SC | Requirement | Supporting Tasks | Validation |
|----|-------------|------------------|-----------|
| SC-001 | Register & login complete within 2 min | T051-T074 | Measure actual auth flow time |
| SC-002 | Market rates display within 3 sec | T036-T050 | Performance test rates endpoint |
| SC-003 | Add transaction complete within 30 sec | T075-T097 | Performance test transaction creation |
| SC-004 | Dashboard load within 2 sec | T098-T108 | Performance test dashboard endpoint |
| SC-005 | 95% first-attempt success (auth/transaction) | T051-T074, T075-T097 | Form validation + error handling |
| SC-006 | Market rates update every 5 min | T021-T023, T047-T050 | Verify FetchMarketRatesJob scheduling |
| SC-007 | 24h offline capability | T024-T035, T096 | Create transaction offline, verify sync |

---

## Implementation Strategy

**MVP Scope (Phases 1-7, ~4-5 weeks)**:
- Week 1: Phase 1 + Phase 2 setup (T001-T035)
- Weeks 2-3: Phase 3-4 parallel (US1 + US2, T036-T074)
- Week 4: Phase 5-6 parallel (US3 + US4, T075-T108)
- Week 5: Phase 7 (US5, T109-T120)

**Polish & Deployment (Phase 8, ~1 week)**:
- Testing: Run full test suites (T127-T148)
- Security: Hardening and audit (T149-T155)
- Deployment: Kamal + App Stores (T156-T160)

---

## How to Use tasks.md

1. **Track Progress**: Use checklist format to mark tasks complete as implementation proceeds
2. **Parallelization**: After Phase 2, assign US1-5 tasks to different team members/sprints
3. **Independent Testing**: Each user story can be tested in isolation (see Independent Test criteria)
4. **Dependency Management**: Follow dependencies graph to prevent blocked tasks
5. **Performance Validation**: Run performance tests (T050, T097, T108, etc.) as completion criteria

---

## Next Steps

1. ✅ **COMPLETED**: Phase 1 design artifacts (constitution, spec, research, plan, data-model, quickstart, contracts)
2. ✅ **COMPLETED**: Phase 2 task list (160 actionable items organized by story)
3. ✅ **COMPLETED**: Complete API specification (transactions.yaml added)
4. 📋 **NEXT**: Begin Phase 1 setup tasks (T001-T008) - Rails 8 + Flutter project initialization
5. 📋 **THEN**: Complete Phase 2 foundation (T009-T035) - Models, migrations, services
6. 🚀 **READY**: Execute Phase 3-7 tasks in parallel for rapid MVP delivery

---

## Files Generated

| File | Lines | Purpose |
|------|-------|---------|
| `tasks.md` | 680+ | Complete task list with 160 items, dependencies, parallelization |
| `contracts/transactions.yaml` | 550+ | OpenAPI spec for transactions, balance, categories, dashboard |
| `TASKS_GENERATION_COMPLETE.md` | This file | Summary of task generation results |

**All files in**: `/workspaces/zarbin/specs/001-mvp-foundation/`

---

**Status**: 🎯 **Phase 1 design complete. Phase 2 implementation ready to begin.**
