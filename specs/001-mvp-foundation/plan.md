# Implementation Plan: MVP Foundation - Manual Tracking & Live Rates Dashboard

**Branch**: `001-mvp-foundation` | **Date**: 2025-12-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-mvp-foundation/spec.md`

## Summary

Build the foundation for Zarbin, an AI-powered personal financial advisor for high-inflation economies. This MVP delivers:
1. **Real-time market rates dashboard** - Live Gold, Coin, and USD prices with Jalali timestamps
2. **User authentication** - Iranian mobile number registration with SMS OTP verification
3. **Manual transaction tracking** - Income/expense entry with categories and dual-currency display
4. **Net worth dashboard** - Total balance in Toman with USD/Gold equivalents

Technical approach: Ruby on Rails 8 API backend with Flutter mobile app, using PostgreSQL for storage, Solid Queue/Cache for background jobs, and in-house authentication for data sovereignty.

## Technical Context

**Language/Version**: Ruby 3.4+ (backend), Dart/Flutter latest stable (mobile)  
**Primary Dependencies**: Rails 8.x, Flutter, PostgreSQL 15+, Solid Queue, Solid Cache  
**Storage**: PostgreSQL with Active Record Encryption for sensitive data  
**Testing**: RSpec (Rails), flutter_test (mobile), 80% coverage target for models/services  
**Target Platform**: Android 6.0+, iOS 12+, Linux server for API  
**Project Type**: Mobile + API (Flutter app + Rails backend)  
**Performance Goals**: Market rates display within 3 seconds, dashboard load within 2 seconds  
**Constraints**: TLS 1.3 minimum, no Redis in MVP, Persian/RTL default, Jalali-only dates  
**Scale/Scope**: MVP targeting initial user base, 5 main screens, ~15 API endpoints

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| **I. Inflation-Centric Design** | ✅ PASS | Dual-currency display (Toman + USD/Gold) in all monetary contexts; FR-017, FR-018 |
| **II. Privacy-First Data Handling** | ✅ PASS | Active Record Encryption for user data; in-house auth (no 3rd party); token-based sessions |
| **III. Responsive & Resilient UX** | ✅ PASS | Local caching for rates (FR-010); non-blocking sync; optimistic UI updates |
| **IV. Test-Driven Development** | ✅ PASS | 80% coverage target; RSpec for backend; flutter_test for mobile |
| **V. Simplicity & YAGNI** | ✅ PASS | MVP-only features; Solid Queue/Cache (no Redis); 5 screens with ≤3 primary actions each |
| **Localization (v1.0)** | ✅ PASS | Persian default; Jalali-only dates; RTL layout; Persian numerals |

**Gate Result**: ✅ PASSED - No violations. Proceed to Phase 0 research.

## Project Structure

### Documentation (this feature)

```text
specs/001-mvp-foundation/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (OpenAPI specs)
│   ├── auth.yaml
│   ├── market-rates.yaml
│   ├── transactions.yaml
│   └── dashboard.yaml
├── checklists/
│   └── requirements.md  # Already created
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
# Mobile + API structure (Flutter + Rails)

api/
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── auth_controller.rb
│   │   │       ├── market_rates_controller.rb
│   │   │       ├── transactions_controller.rb
│   │   │       └── dashboard_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── transaction.rb
│   │   ├── category.rb
│   │   └── market_rate.rb
│   ├── services/
│   │   ├── market_data_fetcher.rb
│   │   ├── sms_otp_service.rb
│   │   └── currency_converter.rb
│   └── jobs/
│       └── market_rate_refresh_job.rb
├── config/
├── db/
│   └── migrate/
├── spec/
│   ├── models/
│   ├── services/
│   ├── requests/
│   └── factories/
├── Gemfile
└── Dockerfile

mobile/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   │   ├── jalali_date.dart
│   │   │   └── persian_numbers.dart
│   │   └── l10n/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── datasources/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   └── presentation/
│       ├── screens/
│       │   ├── splash/
│       │   ├── auth/
│       │   ├── home/
│       │   ├── transactions/
│       │   └── dashboard/
│       ├── widgets/
│       └── providers/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── pubspec.yaml
└── analysis_options.yaml
```

**Structure Decision**: Mobile + API architecture selected based on Flutter mobile app + Rails 8 backend requirement from constitution. Clean architecture pattern for Flutter to support testability and separation of concerns.

## Complexity Tracking

> No violations identified. Table left empty per instructions.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | - | - |
