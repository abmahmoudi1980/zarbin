# Tasks: MVP Foundation - Manual Tracking & Live Rates Dashboard

**Input**: Design documents from `/specs/001-mvp-foundation/`  
**Prerequisites**: ✅ plan.md, ✅ spec.md, ✅ research.md, ✅ data-model.md, ✅ contracts/  
**Organization**: Tasks grouped by user story (US1-US5) for independent implementation  
**Path Convention**: Monorepo with `backend/` (Rails) and `frontend/` (Flutter) subdirectories  

---

## Format: `[ID] [P?] [Story] Description with file path`

- **[ID]**: Task sequential number (T001, T002, etc.)
- **[P]**: Parallelizable - can run independently (different files, no dependencies)
- **[Story]**: User story label (US1, US2, etc.) for story-phase tasks only
- **File Paths**: Exact locations for implementation

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure across both Rails and Flutter

✅ **PHASE 1 COMPLETE** - All tasks finished

- [x] T001 Create Rails 8 project structure with Gemfile and main config files in `backend/`
- [x] T002 [P] Create Flutter project structure with pubspec.yaml and main app in `frontend/`
- [x] T003 [P] Configure PostgreSQL database connection in `backend/config/database.yml`
- [x] T004 [P] Configure environment variables and secrets management in `backend/config/credentials.yml.enc` and `backend/.env.example`
- [x] T005 [P] Configure Flutter API client configuration in `frontend/lib/config/api_config.dart`
- [x] T006 [P] Set up RuboCop linting for Rails in `backend/.rubocop.yml`
- [x] T007 [P] Set up Flutter analysis and formatting in `frontend/analysis_options.yaml`
- [x] T008 Create initial migration system and db:setup tasks in `backend/db/migrate/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until Phase 2 is complete

### Backend Foundation

- [x] T009 [P] Create User model with mobile_number, password_hash, account_status attributes in `backend/app/models/user.rb`
- [x] T010 [P] Create MarketRate model with rate_type, value_in_toman, timestamp in `backend/app/models/market_rate.rb`
- [x] T011 [P] Create Transaction model with amount_toman, type, category_id, user_id, date in `backend/app/models/transaction.rb`
- [x] T012 [P] Create Category model with persian_name, icon_code, display_order in `backend/app/models/category.rb`
- [x] T013 [P] Create OtpVerification model with mobile_number, otp_code, expires_at in `backend/app/models/otp_verification.rb`
- [x] T014 [P] Create UserBalance model with total_toman, total_usd_equivalent in `backend/app/models/user_balance.rb`
- [x] T015 [P] Create database migrations for all models in `backend/db/migrate/`
- [x] T016 [P] Implement base ApplicationController with error handling in `backend/app/controllers/application_controller.rb`
- [x] T017 [P] Set up JWT authentication middleware in `backend/app/middleware/jwt_auth.rb`
- [x] T018 [P] Configure CORS for Flutter app in `backend/config/initializers/cors.rb`
- [x] T019 [P] Implement MarketDataService to fetch rates from TGJU API in `backend/app/services/market_data_service.rb`
- [x] T020 [P] Implement SmsOtpService for Kavenegar SMS integration in `backend/app/services/sms_otp_service.rb`
- [x] T021 [P] Create FetchMarketRatesJob using Solid Queue in `backend/app/jobs/fetch_market_rates_job.rb`
- [x] T022 Configure Solid Queue for background job execution in `backend/config/solid_queue.yml`
- [x] T023 Seed predefined categories (Food, Transport, Bills, Shopping, Health, Entertainment, Other) in `backend/db/seeds.rb`

### Frontend Foundation

- [x] T024 [P] Create User model for local storage in `frontend/lib/models/user.dart`
- [x] T025 [P] Create Transaction model for local storage in `frontend/lib/models/transaction.dart`
- [x] T026 [P] Create MarketRate model for caching in `frontend/lib/models/market_rate.dart`
- [x] T027 [P] Create Hive storage adapters for caching in `frontend/lib/services/hive_service.dart`
- [x] T028 [P] Create SQLite database initialization in `frontend/lib/services/database_service.dart`
- [x] T029 [P] Create HTTP API client with error handling in `frontend/lib/services/api_client.dart`
- [x] T030 [P] Set up Provider for state management in `frontend/lib/providers/`
- [x] T031 [P] Create secure storage for JWT tokens in `frontend/lib/services/secure_storage.dart`
- [x] T032 [P] Configure Jalali calendar using shamsi_date in `frontend/lib/utils/jalali_helper.dart`
- [x] T033 [P] Create Persian numeral converter in `frontend/lib/utils/persian_formatter.dart`
- [x] T034 [P] Create Persian numeral and validation utilities in `frontend/lib/utils/validators.dart`
- [x] T035 [P] Add Persian font loading utilities in `frontend/lib/utils/font_loader.dart`

**Checkpoint**: Foundation complete - user story implementation can now begin in parallel (all following tasks can run independently)

---

## Phase 3: User Story 1 - View Real-Time Market Rates (Priority: P1) 🎯 MVP

**Goal**: Users can open the app and see live Gold, Bahar Azadi Coin, and USD/Toman rates with Jalali timestamps

**Independent Test**: Open app → home screen displays 3 current rates → pull-to-refresh updates rates → rates show stale indicator after 5 minutes

### Tests for User Story 1 (TDD: Write tests FIRST, ensure they FAIL)

- [x] T036 [P] [US1] Contract test for GET `/api/v1/rates` in `backend/spec/requests/api/v1/rates_spec.rb`
- [x] T037 [P] [US1] Unit test for MarketDataService.fetch_rates in `backend/spec/services/market_data_service_spec.rb`
- [x] T038 [P] [US1] Widget test for MarketRatesScreen display in `frontend/test/screens/market_rates_screen_test.dart`

### Implementation for User Story 1

- [x] T039 [P] [US1] Create RatesController with GET endpoint in `backend/app/controllers/api/v1/rates_controller.rb`
- [x] T040 [US1] Implement rate caching with Solid Cache (5-minute expiry) in `backend/app/services/market_data_service.rb`
- [x] T041 [P] [US1] Create rate formatting service for Jalali dates and Persian numerals in `backend/app/services/rate_formatter.rb`
- [x] T042 [P] [US1] Create MarketRateProvider for state management in `frontend/lib/providers/market_rate_provider.dart`
- [x] T043 [P] [US1] Create MarketRatesScreen UI with rate display widgets in `frontend/lib/screens/market_rates_screen.dart`
- [x] T044 [P] [US1] Implement pull-to-refresh functionality in `frontend/lib/screens/market_rates_screen.dart`
- [x] T045 [US1] Implement stale indicator (>5 minutes) in `frontend/lib/widgets/rate_card.dart` (depends on T040)
- [x] T046 [US1] Add rate update indicators (up/down arrows with percentage) in `frontend/lib/widgets/rate_change_indicator.dart`
- [x] T047 [P] [US1] Create background job to fetch rates every 5 minutes in `backend/app/jobs/fetch_market_rates_job.rb`
- [x] T048 [US1] Schedule FetchMarketRatesJob in Solid Queue during market hours in `backend/config/solid_queue.yml`
- [x] T049 [P] [US1] Add Persian fonts to Flutter for Jalali date display in `frontend/pubspec.yaml`
- [ ] T050 [US1] Verify rates load within 3 seconds performance target

**Checkpoint**: User Story 1 complete - rates display and refresh working. Can be tested independently.

---

## Phase 4: User Story 2 - Register and Authenticate (Priority: P2)

**Goal**: New users can register with mobile number + password, verify OTP, and existing users can securely log in

**Independent Test**: Register with phone → receive OTP → verify OTP → logged in → close app → reopen → still authenticated after 7 days

### Tests for User Story 2 (TDD)

- [x] T051 [P] [US2] Contract test for POST `/api/v1/auth/register` in `backend/spec/requests/api/v1/auth_spec.rb`
- [x] T052 [P] [US2] Contract test for POST `/api/v1/auth/verify-otp` in `backend/spec/requests/api/v1/auth_spec.rb`
- [x] T053 [P] [US2] Contract test for POST `/api/v1/auth/login` in `backend/spec/requests/api/v1/auth_spec.rb`
- [x] T054 [P] [US2] Unit test for User.authenticate method in `backend/spec/models/user_spec.rb`
- [x] T055 [P] [US2] Unit test for SmsOtpService.send_otp in `backend/spec/services/sms_otp_service_spec.rb`
- [x] T056 [P] [US2] Unit test for JWT token generation in `backend/spec/services/auth_service_spec.rb`
- [x] T057 [P] [US2] Widget test for RegisterScreen in `frontend/test/screens/register_screen_test.dart`
- [x] T058 [P] [US2] Widget test for LoginScreen in `frontend/test/screens/login_screen_test.dart`

### Implementation for User Story 2

- [x] T059 [P] [US2] Create AuthController with register, verify-otp, login endpoints in `backend/app/controllers/api/v1/auth_controller.rb`
- [x] T060 [P] [US2] Implement User password hashing with bcrypt in `backend/app/models/user.rb`
- [x] T061 [P] [US2] Create AuthService for JWT token generation in `backend/app/services/auth_service.rb`
- [x] T062 [P] [US2] Implement OTP generation and verification logic in `backend/app/services/otp_service.rb`
- [x] T063 [P] [US2] Create JwtAuthMiddleware for token validation in `backend/app/controllers/application_controller.rb`
- [ ] T064 [US2] Implement account lockout after 5 failed login attempts in `backend/app/models/user.rb` (depends on T059)
- [x] T065 [P] [US2] Create RegisterScreen with phone/password input in `frontend/lib/screens/register_screen.dart`
- [x] T066 [P] [US2] Create OtpVerificationScreen with code entry in `frontend/lib/screens/otp_verification_screen.dart`
- [x] T067 [P] [US2] Create LoginScreen with phone/password input in `frontend/lib/screens/login_screen.dart`
- [x] T068 [P] [US2] Create AuthProvider for session management in `frontend/lib/providers/auth_provider.dart`
- [x] T069 [P] [US2] Implement secure token storage in Flutter using flutter_secure_storage in `frontend/lib/services/secure_storage.dart`
- [ ] T070 [US2] Implement 7-day token expiry refresh logic in `frontend/lib/services/api_client.dart` (depends on T068)
- [x] T071 [P] [US2] Add form validation for Iranian mobile numbers in `frontend/lib/utils/validators.dart`
- [x] T072 [P] [US2] Add form validation for password strength (min 8 chars, 1 number) in `frontend/lib/utils/validators.dart`
- [ ] T073 [US2] Test account lockout triggers correctly after 5 failures and resets after 15 min
- [ ] T074 [US2] Verify registration completes in <2 minutes per SC-001

**Checkpoint**: User Story 2 core implementation complete ✅
- Register/Login screens, AuthProvider, secure storage ✅
- AuthController, AuthService, OtpService ✅  
- All tests written (TDD complete) ✅
- Remaining: Token refresh (T070), integration tests (T073-T074)

---

## Phase 5: User Story 3 - Add Manual Transaction (Priority: P3) ✅ COMPLETE

**Goal**: Authenticated users can create income/expense transactions with categories, dates, and notes

**Independent Test**: Logged-in user → tap Add Transaction → enter amount (5M Toman) → select Food category → pick Jalali date → add note → save → appears in list with dual-currency amounts

### Tests for User Story 3 (TDD)

- [x] T075 [P] [US3] Contract test for POST `/api/v1/transactions` in `backend/spec/requests/api/v1/transactions_spec.rb`
- [x] T076 [P] [US3] Contract test for GET `/api/v1/transactions` in `backend/spec/requests/api/v1/transactions_spec.rb`
- [x] T077 [P] [US3] Unit test for Transaction.validate_amount in `backend/spec/models/transaction_spec.rb`
- [x] T078 [P] [US3] Unit test for currency conversion in `backend/spec/services/currency_service_spec.rb`
- [x] T079 [P] [US3] Widget test for AddTransactionScreen in `frontend/test/screens/add_transaction_screen_test.dart`
- [x] T080 [P] [US3] Widget test for TransactionListScreen in `frontend/test/screens/transaction_list_screen_test.dart`

### Implementation for User Story 3

- [x] T081 [P] [US3] Create TransactionsController with POST/GET endpoints in `backend/app/controllers/api/v1/transactions_controller.rb`
- [x] T082 [P] [US3] Implement transaction amount validation (>0, <=99,999,999,999 Toman) in `backend/app/models/transaction.rb`
- [x] T083 [P] [US3] Create CurrencyService for Toman→USD conversion at creation time in `backend/app/services/currency_service.rb`
- [x] T084 [P] [US3] Implement transaction sorting by date (newest first) in `backend/app/models/transaction.rb`
- [x] T085 [US3] Ensure current exchange rate is stored with each transaction for historical accuracy in `backend/app/controllers/api/v1/transactions_controller.rb` (depends on T083)
- [x] T086 [P] [US3] Create AddTransactionScreen with form inputs in `frontend/lib/screens/add_transaction_screen.dart`
- [x] T087 [P] [US3] Integrate Jalali date picker into transaction form in `frontend/lib/screens/add_transaction_screen.dart`
- [x] T088 [P] [US3] Create category selector dropdown with all 7 categories in `frontend/lib/widgets/category_selector.dart`
- [x] T089 [P] [US3] Create TransactionListScreen showing all user transactions in `frontend/lib/screens/transaction_list_screen.dart`
- [x] T090 [P] [US3] Create transaction list item widget with amount, category icon, note preview in `frontend/lib/widgets/transaction_list_item.dart`
- [x] T091 [P] [US3] Create TransactionProvider for managing transaction state in `frontend/lib/providers/transaction_provider.dart`
- [x] T092 [P] [US3] Implement dual-currency display (Toman + USD equivalent) in `frontend/lib/widgets/dual_currency_display.dart`
- [x] T093 [P] [US3] Create Persian numeral formatter for transaction amounts in `frontend/lib/utils/persian_formatter.dart`
- [x] T094 [US3] Implement amount input validation with Persian numeral support in `frontend/lib/widgets/amount_input_field.dart`
- [x] T095 [P] [US3] Add income/expense type toggle in `frontend/lib/widgets/transaction_type_toggle.dart`
- [x] T096 [P] [US3] Implement local transaction caching to SQLite in `frontend/lib/services/database_service.dart`
- [x] T097 [US3] Test transaction creation completes in <30 seconds per SC-003

**Checkpoint**: User Story 3 complete - users can record income and expenses with full details.

---

## Phase 6: User Story 4 - View Net Worth Dashboard (Priority: P4)

**Goal**: Users see total balance in Toman with USD and Gold gram equivalents, updating automatically when rates change

**Independent Test**: User with transactions → view dashboard → see Toman total + USD equivalent + Gold equivalent → rates update → equivalents recalculate automatically

### Tests for User Story 4 (TDD)

- [x] T098 [P] [US4] Contract test for GET `/api/v1/dashboard` in `backend/spec/requests/api/v1/dashboard_spec.rb`
- [x] T099 [P] [US4] Unit test for UserBalance.calculate_equivalents in `backend/spec/models/user_balance_spec.rb`
- [x] T100 [P] [US4] Widget test for DashboardScreen in `frontend/test/screens/dashboard_screen_test.dart`

### Implementation for User Story 4

- [x] T101 [P] [US4] Create DashboardController with GET endpoint in `backend/app/controllers/api/v1/dashboard_controller.rb`
- [x] T102 [P] [US4] Implement UserBalance.calculate for total Toman from transactions in `backend/app/models/user_balance.rb`
- [x] T103 [P] [US4] Implement USD/Gold equivalent calculations in `backend/app/services/currency_service.rb`
- [x] T104 [P] [US4] Create DashboardScreen with balance cards in `frontend/lib/screens/dashboard_screen.dart`
- [x] T105 [P] [US4] Create balance display widgets (Toman card, USD card, Gold card) in `frontend/lib/widgets/balance_card.dart`
- [x] T106 [US4] Implement auto-refresh of dashboard when rates update (FetchMarketRatesJob completes) in `frontend/lib/providers/dashboard_provider.dart` (depends on T040)
- [x] T107 [P] [US4] Display helpful prompt when balance is zero in `frontend/lib/screens/dashboard_screen.dart`
- [ ] T108 [US4] Verify dashboard loads within 2 seconds per SC-004

**Checkpoint**: User Story 4 complete - users see dual-currency balance with real-time rate updates. ✅ PHASE 6 CORE IMPLEMENTATION COMPLETE

---

## Phase 7: User Story 5 - Categorize Transactions (Priority: P5)

**Goal**: User transactions are categorized; dashboard shows spending breakdown by category for current Jalali month

**Independent Test**: Create transactions in different categories → view dashboard → see pie chart or list showing category breakdown → defaults to "Other" if not selected

### Tests for User Story 5 (TDD)

- [ ] T109 [P] [US5] Contract test for GET `/api/v1/categories` in `backend/spec/requests/api/v1/categories_spec.rb`
- [ ] T110 [P] [US5] Contract test for spending breakdown endpoint in `backend/spec/requests/api/v1/dashboard_spec.rb`
- [ ] T111 [P] [US5] Unit test for category spending calculation in `backend/spec/services/spending_service_spec.rb`
- [ ] T112 [P] [US5] Widget test for category breakdown chart in `frontend/test/widgets/category_chart_test.dart`

### Implementation for User Story 5

- [ ] T113 [P] [US5] Create CategoriesController with GET endpoint in `backend/app/controllers/api/v1/categories_controller.rb`
- [ ] T114 [P] [US5] Create SpendingService to calculate spending by category for current Jalali month in `backend/app/services/spending_service.rb`
- [ ] T115 [P] [US5] Implement transaction default to "Other" category if not selected in `backend/app/models/transaction.rb`
- [ ] T116 [P] [US5] Create CategoryBreakdownScreen showing pie chart or list in `frontend/lib/screens/category_breakdown_screen.dart`
- [ ] T117 [P] [US5] Create PieChart widget for category spending visualization in `frontend/lib/widgets/category_pie_chart.dart`
- [ ] T118 [P] [US5] Create CategoryListItem widget showing category name, amount, percentage in `frontend/lib/widgets/category_list_item.dart`
- [ ] T119 [US5] Integrate category breakdown into main dashboard in `frontend/lib/screens/dashboard_screen.dart` (depends on T104)
- [ ] T120 [P] [US5] Add category icons to breakd own display in `frontend/lib/utils/category_icons.dart`

**Checkpoint**: User Story 5 complete - all user stories implemented and independently testable.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Testing, security, performance optimization, and deployment readiness

### Backend Polish

- [ ] T121 [P] Add error handling for TGJU API failures with fallback to cached rates in `backend/app/services/market_data_service.rb`
- [ ] T122 [P] Add logging for authentication events in `backend/app/middleware/jwt_auth.rb`
- [ ] T123 [P] Add logging for transaction operations in `backend/app/controllers/api/v1/transactions_controller.rb`
- [ ] T124 [P] Configure Active Record Encryption for sensitive User data in `backend/app/models/user.rb`
- [ ] T125 [P] Implement request rate limiting to prevent abuse in `backend/config/initializers/rate_limiter.rb`
- [ ] T126 [P] Add input sanitization for transaction notes in `backend/app/controllers/api/v1/transactions_controller.rb`
- [ ] T127 Run full test suite with RSpec: `bundle exec rspec` targeting 80% coverage in `backend/`
- [ ] T128 Run RuboCop linting: `bundle exec rubocop` and fix violations in `backend/`
- [ ] T129 Performance test: Market rates endpoint returns within 3 seconds
- [ ] T130 Performance test: Dashboard endpoint returns within 2 seconds
- [ ] T131 Test account lockout actually locks after 5 failures and unlocks after 15 min
- [ ] T132 Test transaction amounts handle edge cases (0, negatives, >99B Toman)
- [ ] T133 Test Jalali date picker validation (no future dates, valid ranges)

### Frontend Polish

- [ ] T134 [P] Add error dialogs for API failures in `frontend/lib/widgets/error_dialog.dart`
- [ ] T135 [P] Add offline indicators when rates are stale in `frontend/lib/widgets/offline_indicator.dart`
- [ ] T136 [P] Implement app-wide error handling in `frontend/lib/main.dart`
- [ ] T137 [P] Add input sanitization for transaction notes in `frontend/lib/screens/add_transaction_screen.dart`
- [ ] T138 [P] Configure Flutter analytics/crash reporting (optional for MVP)
- [ ] T139 Run Flutter analyzer: `flutter analyze` and fix issues in `frontend/`
- [ ] T140 Format Flutter code: `dart format --set-exit-if-changed lib/` in `frontend/`
- [ ] T141 Run full widget test suite: `flutter test` targeting 80% coverage in `frontend/`
- [ ] T142 Performance test: App launches and displays rates within 3 seconds
- [ ] T143 Performance test: Dashboard loads and displays within 2 seconds
- [ ] T144 Verify Persian numerals display correctly in all screens
- [ ] T145 Verify RTL layout works on both iOS and Android
- [ ] T146 Verify Jalali date picker displays correct Persian dates
- [ ] T147 Test offline functionality: Create transaction without network, sync when reconnected
- [ ] T148 Test token refresh: Verify 7-day session persistence works correctly

### Integration & Security

- [ ] T149 End-to-end test: Complete user journey (register → view rates → add transaction → view dashboard)
- [ ] T150 Security test: Verify JWT tokens are not exposed in logs or error messages
- [ ] T151 Security test: Verify passwords are never logged or displayed
- [ ] T152 Security test: Verify API requires valid JWT for protected endpoints
- [ ] T153 CORS test: Verify Flutter app can communicate with Rails API
- [ ] T154 Database test: Verify data encryption for User.password_hash column
- [ ] T155 Test API rate limiting prevents abuse (e.g., >100 requests/min from single IP)

### Documentation & Deployment

- [ ] T156 Generate API documentation from contracts/ OpenAPI specs
- [ ] T157 Create deployment checklist in `docs/DEPLOYMENT.md`
- [ ] T158 Create troubleshooting guide in `docs/TROUBLESHOOTING.md`
- [ ] T159 Set up GitHub Actions CI/CD pipeline for automated testing in `.github/workflows/`
- [ ] T160 Prepare Kamal deployment configuration in `backend/config/deploy.yml`

**Checkpoint**: All user stories complete, tested, polished, and ready for deployment.

---

## Dependencies Graph

```
Phase 1 (Setup) 
  ↓
Phase 2 (Foundation) ← All T001-T035
  ↓
  ├─→ Phase 3 (US1: Rates) ← Depends on T009-T035
  │    └─→ Phase 4 (US2: Auth) ← Depends on T009, T013, T014, T035
  │         └─→ Phase 5 (US3: Transactions) ← Depends on T009-T035, Auth complete
  │              └─→ Phase 6 (US4: Dashboard) ← Depends on T009-T035, Transactions complete
  │                   └─→ Phase 7 (US5: Categories) ← Depends on all previous
  │
  └─→ Phase 8 (Polish) ← Depends on all phases complete
```

---

## Parallelization Opportunities

### Can run in parallel from start (after Phase 2):

**Backend tasks** (can all run in parallel):
- T036-T050 (US1 backend + tests)
- T051-T074 (US2 backend + tests)
- T075-T097 (US3 backend + tests)
- T098-T108 (US4 backend + tests)
- T109-T120 (US5 backend + tests)

**Frontend tasks** (can all run in parallel):
- T043-T050 (US1 frontend)
- T065-T074 (US2 frontend)
- T086-T097 (US3 frontend)
- T104-T108 (US4 frontend)
- T116-T120 (US5 frontend)

**Polish tasks** (can run in parallel after individual story completion):
- T121-T148 (Backend and frontend polish independently)
- T149-T155 (Integration tests)
- T156-T160 (Documentation and deployment)

---

## Success Criteria Verification

Each task above directly supports measurable outcomes from spec.md:

- **SC-001** (Register & login within 2min): Tasks T051-T074 ✅
- **SC-002** (Rates display within 3s): Tasks T036-T050 ✅
- **SC-003** (Add transaction within 30s): Tasks T075-T097 ✅
- **SC-004** (Dashboard load within 2s): Tasks T098-T108 ✅
- **SC-005** (95% first-attempt success): Tasks T051-T074, T075-T097 ✅
- **SC-006** (5-minute rate updates): Tasks T021-T023, T047-T050 ✅
- **SC-007** (24h offline capability): Tasks T024-T035, T096 ✅

---

## Implementation Notes

1. **TDD First**: Write all Phase 3-7 tests BEFORE implementation (T036-T038, T051-T058, etc.)
2. **Database Migrations**: Each entity needs a migration file in Phase 2 (T015)
3. **API Documentation**: Contract tests in `/contracts/` serve as living API documentation
4. **Constitution Compliance**: All tasks maintain Zarbin Constitution v1.0.2:
   - Inflation-centric: Dual-currency display throughout (T041, T092, T105)
   - Privacy-first: JWT auth (T059-T063), no PII in logs (T122-T123)
   - Responsive UX: Rate caching (T040), local storage (T024-T035)
   - TDD: Test tasks (T036-T120) required before implementation
   - Simplicity: No Redis, Solid Queue/Cache only (Phase 2)
5. **Phase 3 is MVP**: Completing through Phase 7 enables all user stories; Phase 8 is polish

---

## Next Steps

1. **Week 1**: Complete Phase 1 + Phase 2 (Setup & Foundation)
2. **Weeks 2-3**: Parallel implementation of Phase 3 (US1), Phase 4 (US2)
3. **Weeks 4-5**: Parallel implementation of Phase 5 (US3), Phase 6 (US4), Phase 7 (US5)
4. **Week 6**: Phase 8 (Polish, testing, security)
5. **Week 7**: Deployment and production validation

Each phase is a checkpoint where the system is functional and independently testable.
