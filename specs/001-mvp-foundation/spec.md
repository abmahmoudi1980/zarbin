# Feature Specification: MVP Foundation - Manual Tracking & Live Rates Dashboard

**Feature Branch**: `001-mvp-foundation`  
**Created**: 2025-12-06  
**Status**: Draft  
**Input**: Phase 1 MVP from Zarbin Project Proposal - Rails 8 API setup, Flutter UI, Manual Transaction entry, Live Gold/USD rates dashboard

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Real-Time Market Rates (Priority: P1)

As a user concerned about inflation, I want to see live Gold and USD exchange rates on the home screen so I can quickly assess the current value of my money and make informed decisions about converting cash to assets.

**Why this priority**: This is the core value proposition of Zarbin. Users need to see real-time market data before they can make any financial decisions. Without live rates, the app provides no inflation-hedging value.

**Independent Test**: Can be fully tested by opening the app and verifying that Gold (per gram), Bahar Azadi Coin, and USD/IRR rates are displayed with timestamps. Delivers immediate value by replacing manual price-checking across multiple websites.

**Acceptance Scenarios**:

1. **Given** a user opens the app, **When** the home screen loads, **Then** they see current Gold price (per gram in Toman), Bahar Azadi Coin price, and USD free-market rate with last-updated timestamp in Jalali format
2. **Given** a user is viewing rates, **When** they pull-to-refresh, **Then** the rates update from the server and the timestamp refreshes
3. **Given** the user is viewing rates, **When** rates have not been updated for more than 5 minutes, **Then** a visual indicator (e.g., subtle warning color) shows that data may be stale

---

### User Story 2 - Register and Authenticate (Priority: P2)

As a new user, I want to create an account and log in securely so my financial data is protected and accessible only to me.

**Why this priority**: Authentication is foundational - no personal data (transactions, net worth) can be stored or synced without user identity. This gates all personalized features.

**Independent Test**: Can be fully tested by registering a new account with phone number/password, logging out, and logging back in. Delivers secure access foundation.

**Acceptance Scenarios**:

1. **Given** a new user, **When** they enter a valid Iranian mobile number and password (min 8 chars with at least one number), **Then** they receive an OTP via SMS and can verify their account
2. **Given** a registered user, **When** they enter correct credentials, **Then** they are authenticated and see their personalized dashboard
3. **Given** a user enters incorrect password 5 times, **When** they attempt a 6th login, **Then** the account is temporarily locked for 15 minutes
4. **Given** a logged-in user, **When** they close the app and reopen within 7 days, **Then** they remain authenticated (token-based session)

---

### User Story 3 - Add Manual Transaction (Priority: P3)

As a user, I want to manually record my income and expenses so I can track where my money goes, even without automatic bank integration.

**Why this priority**: Manual transaction entry is the core data-capture mechanism for MVP. While less convenient than SMS parsing (Phase 2), it allows users to start tracking immediately and proves the expense-tracking value proposition.

**Independent Test**: Can be fully tested by adding an expense transaction, viewing it in the transaction list, and verifying totals update correctly. Delivers expense awareness.

**Acceptance Scenarios**:

1. **Given** an authenticated user, **When** they tap "Add Transaction" and enter amount (5,000,000 Toman), select category (Food), add optional note ("رستوران"), and select date (Jalali picker), **Then** the transaction is saved and appears in the transaction list
2. **Given** a user is adding a transaction, **When** they select "Income" type and enter amount, **Then** the transaction is recorded as positive cash flow
3. **Given** a user views their transaction list, **When** transactions exist, **Then** they see a scrollable list sorted by date (newest first) with amount, category icon, and note preview
4. **Given** a user, **When** they view a transaction, **Then** they see the amount displayed in both Toman and USD equivalent (using the rate at transaction time)

---

### User Story 4 - View Net Worth Dashboard (Priority: P4)

As a user, I want to see my total net worth displayed in both Rial and USD/Gold equivalent so I understand my true financial position relative to inflation.

**Why this priority**: This is where the inflation-centric design principle manifests. After users add transactions, they need to see the "so what" - their purchasing power over time.

**Independent Test**: Can be fully tested by adding sample transactions and verifying the dashboard displays total balance in dual currencies. Delivers inflation-awareness insight.

**Acceptance Scenarios**:

1. **Given** a user with recorded transactions, **When** they view the dashboard, **Then** they see total cash balance in Toman and equivalent value in USD and Gold grams
2. **Given** a user views the dashboard, **When** exchange rates update, **Then** the USD/Gold equivalents recalculate automatically
3. **Given** a user with no transactions, **When** they view the dashboard, **Then** they see zero balances with an encouraging prompt to add their first transaction

---

### User Story 5 - Categorize Transactions (Priority: P5)

As a user, I want to assign categories to my transactions so I can understand my spending patterns by category.

**Why this priority**: Categories enable the budgeting and analysis features planned for Phase 2. MVP needs the data structure even if advanced analytics come later.

**Independent Test**: Can be tested by creating transactions with different categories and viewing a simple category breakdown. Delivers spending visibility.

**Acceptance Scenarios**:

1. **Given** a user is adding a transaction, **When** they tap category selector, **Then** they see predefined categories: خوراک (Food), حمل‌ونقل (Transport), قبوض (Bills), خرید (Shopping), سلامت (Health), تفریح (Entertainment), سایر (Other)
2. **Given** a user views the dashboard, **When** they have categorized transactions, **Then** they see a simple pie chart or list showing spending by category for the current Jalali month
3. **Given** a user, **When** they do not select a category for a transaction, **Then** it defaults to "سایر" (Other)

---

### Edge Cases

- What happens when the market data API is unavailable? → Show cached rates with "آخرین به‌روزرسانی" (Last updated) timestamp and offline indicator
- How does the system handle transactions with very large amounts (e.g., billions of Toman)? → Support amounts up to 99,999,999,999 Toman with proper formatting (e.g., ۱۲,۳۴۵,۶۷۸,۹۰۰)
- What happens if a user enters a future date for a transaction? → Allow future dates for planned expenses with visual distinction
- How does the system handle currency conversion when historical rates are unavailable? → Use the nearest available rate and display a note indicating approximation

## Requirements *(mandatory)*

### Functional Requirements

**Authentication & User Management**
- **FR-001**: System MUST allow user registration with Iranian mobile number (+98) and password
- **FR-002**: System MUST verify mobile numbers via SMS OTP before account activation
- **FR-003**: System MUST support secure login with mobile number and password
- **FR-004**: System MUST implement token-based authentication with 7-day session expiry
- **FR-005**: System MUST lock accounts after 5 failed login attempts for 15 minutes

**Market Data**
- **FR-006**: System MUST fetch and display live Gold price (per gram) in Toman
- **FR-007**: System MUST fetch and display live Bahar Azadi Coin price in Toman
- **FR-008**: System MUST fetch and display live USD free-market exchange rate
- **FR-009**: System MUST display last-updated timestamp in Jalali format for all rates
- **FR-010**: System MUST cache market rates locally for display when offline

**Transaction Management**
- **FR-011**: System MUST allow users to create manual transactions with: amount, type (income/expense), category, date, optional note
- **FR-012**: System MUST support Jalali date picker for transaction dates
- **FR-013**: System MUST store the USD exchange rate at the time of each transaction
- **FR-014**: System MUST display all monetary amounts in Persian numerals (۰۱۲۳۴۵۶۷۸۹)
- **FR-015**: System MUST support transaction amounts up to 99,999,999,999 Toman

**Dashboard & Display**
- **FR-016**: System MUST calculate and display total cash balance from all transactions
- **FR-017**: System MUST display cash balance in both Toman and USD equivalent
- **FR-018**: System MUST display cash balance in Gold gram equivalent
- **FR-019**: System MUST show spending breakdown by category for current Jalali month
- **FR-020**: System MUST update dual-currency displays when exchange rates refresh

**Localization**
- **FR-021**: All UI text MUST be in Persian (Farsi) as the default language
- **FR-022**: All dates MUST use Jalali (Shamsi) calendar format
- **FR-023**: All numbers MUST use Persian numerals in display contexts
- **FR-024**: UI layout MUST be Right-to-Left (RTL)

### Key Entities

- **User**: Represents a registered user; attributes include mobile number (unique), hashed password, authentication tokens, account status (active/locked), created date
- **Transaction**: Represents a financial event; attributes include amount (Toman), type (income/expense), category, date (Jalali), optional note, USD rate at creation time, associated user
- **Category**: Predefined spending categories; attributes include Persian name, icon identifier, display order
- **MarketRate**: Point-in-time exchange rate snapshot; attributes include rate type (USD/Gold/Coin), value in Toman, timestamp
- **UserBalance**: Calculated aggregate of user's transactions; derived attributes include total Toman, equivalent USD, equivalent Gold grams

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can register and log in within 2 minutes of first app launch
- **SC-002**: Market rates display within 3 seconds of app launch (with network connectivity)
- **SC-003**: Users can add a complete transaction (amount, category, date) in under 30 seconds
- **SC-004**: Dashboard loads and displays dual-currency balances within 2 seconds
- **SC-005**: 95% of users successfully complete their first transaction on the first attempt
- **SC-006**: System maintains rate data freshness with updates every 5 minutes during market hours
- **SC-007**: App remains functional (cached data, transaction entry) for at least 24 hours without network connectivity

## Assumptions

- Market rate data is available from free/affordable APIs (e.g., Bonbast, TGJU, or similar Iranian market data providers)
- SMS OTP delivery services are available and reliable in Iran
- Users have smartphones running Android 6.0+ or iOS 12+ with Persian language support
- Iranian mobile numbers follow the standard +98 9XX XXX XXXX format
- All monetary amounts are stored and displayed in Toman (the commonly used unit in Iran)

## Out of Scope (Deferred to Future Phases)

- Automatic SMS parsing from bank notifications (Phase 2)
- AI-powered investment recommendations (Phase 3)
- Crypto exchange integrations (Phase 3)
- Budget planning and alerts (Phase 2)
- English language support (Phase 2)
- Gregorian calendar option (Phase 2)
