# Data Model: MVP Foundation

**Feature**: 001-mvp-foundation  
**Date**: 2025-12-06  
**Status**: Complete

This document defines the data model for the MVP Foundation feature, extracted from the feature specification and aligned with the constitution.

---

## Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│      User       │       │   Transaction   │       │    Category     │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (PK)         │───┐   │ id (PK)         │   ┌───│ id (PK)         │
│ mobile_number   │   │   │ user_id (FK)    │───┘   │ name_fa         │
│ password_digest │   └──▶│ category_id(FK) │       │ icon            │
│ status          │       │ amount          │       │ display_order   │
│ failed_attempts │       │ type            │       │ created_at      │
│ locked_until    │       │ date            │       └─────────────────┘
│ created_at      │       │ note            │
│ updated_at      │       │ usd_rate        │
└─────────────────┘       │ created_at      │
                          │ updated_at      │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   MarketRate    │       │  RefreshToken   │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ id (PK)         │
│ rate_type       │       │ user_id (FK)    │───▶ User
│ value           │       │ token_jti       │
│ fetched_at      │       │ expires_at      │
│ source          │       │ revoked_at      │
│ created_at      │       │ device_info     │
└─────────────────┘       │ created_at      │
                          └─────────────────┘
```

---

## Entities

### 1. User

Represents a registered user of the application.

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| `id` | UUID | PK, auto-generated | Unique identifier |
| `mobile_number` | String | Unique, encrypted, indexed | Iranian mobile (+98 format), encrypted at rest |
| `password_digest` | String | Required | bcrypt hashed password |
| `status` | Enum | Default: 'pending' | Account status: pending, active, locked, suspended |
| `failed_attempts` | Integer | Default: 0 | Consecutive failed login attempts |
| `locked_until` | DateTime | Nullable | Account lock expiration timestamp |
| `created_at` | DateTime | Auto | Account creation timestamp |
| `updated_at` | DateTime | Auto | Last modification timestamp |

**Validation Rules**:
- `mobile_number`: Must match pattern `^\\+989[0-9]{9}$` (Iranian mobile)
- `password`: Minimum 8 characters, at least 1 digit (validated before hashing)
- `status`: Must be one of: `pending`, `active`, `locked`, `suspended`
- `failed_attempts`: Reset to 0 on successful login

**State Transitions**:
```
pending ──(OTP verified)──▶ active
active ──(5 failed attempts)──▶ locked
locked ──(15 minutes elapsed)──▶ active
active ──(admin action)──▶ suspended
```

**Indexes**:
- Unique index on `mobile_number` (deterministic encryption for lookups)

---

### 2. Transaction

Represents a financial event (income or expense).

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| `id` | UUID | PK, auto-generated | Unique identifier |
| `user_id` | UUID | FK → User, indexed | Owner of transaction |
| `category_id` | UUID | FK → Category, indexed | Spending category |
| `amount` | BigInteger | Required, > 0 | Amount in Toman (no decimals) |
| `type` | Enum | Required | Transaction type: income, expense |
| `date` | Date | Required | Transaction date (stored as Gregorian, displayed as Jalali) |
| `note` | String | Optional, max 500 chars | User-provided description |
| `usd_rate` | Decimal(12,2) | Required | USD/Toman rate at transaction time |
| `created_at` | DateTime | Auto | Record creation timestamp |
| `updated_at` | DateTime | Auto | Last modification timestamp |

**Validation Rules**:
- `amount`: Must be positive, max 99,999,999,999 Toman (FR-015)
- `type`: Must be one of: `income`, `expense`
- `date`: Cannot be more than 1 year in the past
- `note`: Max 500 characters, UTF-8 (Persian allowed)
- `usd_rate`: Captured automatically from current market rate

**Derived Fields** (computed, not stored):
- `amount_usd`: `amount / usd_rate`
- `amount_gold_grams`: `amount / current_gold_rate`

**Indexes**:
- Composite index on `(user_id, date)` for listing queries
- Index on `user_id` for balance calculations

---

### 3. Category

Predefined spending categories (seed data, not user-editable in MVP).

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| `id` | UUID | PK, auto-generated | Unique identifier |
| `name_fa` | String | Required, unique | Persian category name |
| `name_en` | String | Required | English category name (for future use) |
| `icon` | String | Required | Icon identifier (Material Icons name) |
| `display_order` | Integer | Required | Sort order in UI |
| `created_at` | DateTime | Auto | Record creation timestamp |

**Seed Data**:

| name_fa | name_en | icon | display_order |
|---------|---------|------|---------------|
| خوراک | Food | restaurant | 1 |
| حمل‌ونقل | Transport | directions_car | 2 |
| قبوض | Bills | receipt_long | 3 |
| خرید | Shopping | shopping_bag | 4 |
| سلامت | Health | medical_services | 5 |
| تفریح | Entertainment | movie | 6 |
| سایر | Other | more_horiz | 7 |

---

### 4. MarketRate

Point-in-time snapshot of market exchange rates.

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| `id` | UUID | PK, auto-generated | Unique identifier |
| `rate_type` | Enum | Required, indexed | Type: usd, gold_gram, bahar_coin |
| `value` | Decimal(15,2) | Required | Rate value in Toman |
| `fetched_at` | DateTime | Required | When rate was fetched from API |
| `source` | String | Default: 'tgju' | Data source identifier |
| `created_at` | DateTime | Auto | Record creation timestamp |

**Validation Rules**:
- `rate_type`: Must be one of: `usd`, `gold_gram`, `bahar_coin`
- `value`: Must be positive
- `fetched_at`: Must be in the past

**Query Patterns**:
- Get latest rate: `WHERE rate_type = ? ORDER BY fetched_at DESC LIMIT 1`
- Get rate at time: `WHERE rate_type = ? AND fetched_at <= ? ORDER BY fetched_at DESC LIMIT 1`

**Indexes**:
- Composite index on `(rate_type, fetched_at)` for latest rate queries

**Retention Policy**:
- Keep last 30 days of rates for historical calculations
- Aggregate older rates to daily snapshots (future optimization)

---

### 5. RefreshToken

Manages user authentication sessions.

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| `id` | UUID | PK, auto-generated | Unique identifier |
| `user_id` | UUID | FK → User, indexed | Token owner |
| `token_jti` | String | Unique, indexed | JWT ID for token identification |
| `expires_at` | DateTime | Required | Token expiration (7 days from creation) |
| `revoked_at` | DateTime | Nullable | When token was revoked (null if active) |
| `device_info` | String | Optional | Device/client identifier |
| `created_at` | DateTime | Auto | Token creation timestamp |

**Validation Rules**:
- `token_jti`: Must be unique (UUID format)
- `expires_at`: Must be in the future at creation time

**Query Patterns**:
- Validate token: `WHERE token_jti = ? AND revoked_at IS NULL AND expires_at > NOW()`
- Revoke all user tokens: `UPDATE SET revoked_at = NOW() WHERE user_id = ?`

**Indexes**:
- Unique index on `token_jti`
- Index on `user_id` for session management

---

## Database Schema (PostgreSQL)

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mobile_number TEXT NOT NULL UNIQUE,  -- Encrypted by Active Record
    password_digest TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    locked_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_status CHECK (status IN ('pending', 'active', 'locked', 'suspended'))
);

-- Categories table (seed data)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_fa VARCHAR(100) NOT NULL UNIQUE,
    name_en VARCHAR(100) NOT NULL,
    icon VARCHAR(50) NOT NULL,
    display_order INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Transactions table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id),
    amount BIGINT NOT NULL,
    type VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    note VARCHAR(500),
    usd_rate DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    CONSTRAINT positive_amount CHECK (amount > 0),
    CONSTRAINT max_amount CHECK (amount <= 99999999999),
    CONSTRAINT valid_type CHECK (type IN ('income', 'expense'))
);

CREATE INDEX idx_transactions_user_date ON transactions(user_id, date DESC);

-- Market rates table
CREATE TABLE market_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rate_type VARCHAR(20) NOT NULL,
    value DECIMAL(15,2) NOT NULL,
    fetched_at TIMESTAMP WITH TIME ZONE NOT NULL,
    source VARCHAR(50) NOT NULL DEFAULT 'tgju',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    CONSTRAINT positive_value CHECK (value > 0),
    CONSTRAINT valid_rate_type CHECK (rate_type IN ('usd', 'gold_gram', 'bahar_coin'))
);

CREATE INDEX idx_market_rates_type_time ON market_rates(rate_type, fetched_at DESC);

-- Refresh tokens table
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_jti VARCHAR(100) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE,
    device_info VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
```

---

## Rails Migrations

```ruby
# db/migrate/001_create_users.rb
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.text :mobile_number, null: false
      t.string :password_digest, null: false
      t.string :status, null: false, default: 'pending'
      t.integer :failed_attempts, null: false, default: 0
      t.datetime :locked_until

      t.timestamps
    end

    add_index :users, :mobile_number, unique: true
  end
end

# db/migrate/002_create_categories.rb
class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name_fa, null: false
      t.string :name_en, null: false
      t.string :icon, null: false
      t.integer :display_order, null: false

      t.timestamp :created_at, null: false, default: -> { 'NOW()' }
    end

    add_index :categories, :name_fa, unique: true
  end
end

# db/migrate/003_create_transactions.rb
class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :category, null: false, foreign_key: true, type: :uuid
      t.bigint :amount, null: false
      t.string :type, null: false
      t.date :date, null: false
      t.string :note, limit: 500
      t.decimal :usd_rate, precision: 12, scale: 2, null: false

      t.timestamps
    end

    add_index :transactions, [:user_id, :date]
    add_check_constraint :transactions, 'amount > 0', name: 'positive_amount'
    add_check_constraint :transactions, 'amount <= 99999999999', name: 'max_amount'
  end
end

# db/migrate/004_create_market_rates.rb
class CreateMarketRates < ActiveRecord::Migration[8.0]
  def change
    create_table :market_rates, id: :uuid do |t|
      t.string :rate_type, null: false
      t.decimal :value, precision: 15, scale: 2, null: false
      t.datetime :fetched_at, null: false
      t.string :source, null: false, default: 'tgju'

      t.timestamp :created_at, null: false, default: -> { 'NOW()' }
    end

    add_index :market_rates, [:rate_type, :fetched_at]
    add_check_constraint :market_rates, 'value > 0', name: 'positive_value'
  end
end

# db/migrate/005_create_refresh_tokens.rb
class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token_jti, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.string :device_info

      t.timestamp :created_at, null: false, default: -> { 'NOW()' }
    end

    add_index :refresh_tokens, :token_jti, unique: true
  end
end
```

---

## Flutter Data Models

```dart
// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String mobileNumber;
  final String status;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.mobileNumber,
    required this.status,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    mobileNumber: json['mobile_number'],
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
  );
}

// lib/data/models/transaction_model.dart
class TransactionModel {
  final String id;
  final String categoryId;
  final int amount;  // Toman
  final TransactionType type;
  final DateTime date;
  final String? note;
  final double usdRate;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    required this.usdRate,
    required this.createdAt,
  });

  double get amountUsd => amount / usdRate;

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'],
    categoryId: json['category_id'],
    amount: json['amount'],
    type: TransactionType.values.byName(json['type']),
    date: DateTime.parse(json['date']),
    note: json['note'],
    usdRate: json['usd_rate'].toDouble(),
    createdAt: DateTime.parse(json['created_at']),
  );
}

enum TransactionType { income, expense }

// lib/data/models/category_model.dart
class CategoryModel {
  final String id;
  final String nameFa;
  final String nameEn;
  final String icon;
  final int displayOrder;

  CategoryModel({
    required this.id,
    required this.nameFa,
    required this.nameEn,
    required this.icon,
    required this.displayOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    nameFa: json['name_fa'],
    nameEn: json['name_en'],
    icon: json['icon'],
    displayOrder: json['display_order'],
  );
}

// lib/data/models/market_rate_model.dart
class MarketRateModel {
  final String id;
  final RateType rateType;
  final double value;  // Toman
  final DateTime fetchedAt;

  MarketRateModel({
    required this.id,
    required this.rateType,
    required this.value,
    required this.fetchedAt,
  });

  factory MarketRateModel.fromJson(Map<String, dynamic> json) => MarketRateModel(
    id: json['id'],
    rateType: RateType.values.byName(json['rate_type']),
    value: json['value'].toDouble(),
    fetchedAt: DateTime.parse(json['fetched_at']),
  );
}

enum RateType { usd, gold_gram, bahar_coin }
```
