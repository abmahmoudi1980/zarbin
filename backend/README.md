# Zarbin Backend API

**Status**: Phase 1 Setup ✅ Complete
**Framework**: Rails 8 on Ruby 3.4
**Database**: PostgreSQL 15+
**Job Queue**: Solid Queue (database-backed)

## Quick Start

### Prerequisites
- Ruby 3.4.0 or later
- PostgreSQL 15 or later
- Bundler

### Setup

```bash
cd backend

# Install dependencies
bundle install

# Create environment file
cp .env.example .env
# Edit .env with your values

# Create and migrate database
bundle exec rails db:create
bundle exec rails db:migrate

# Seed categories
bundle exec rails db:seed

# Start server
bundle exec rails s -p 3000
```

### Running Tests

```bash
# Run all tests with coverage
bundle exec rspec

# Run specific test file
bundle exec rspec spec/requests/api/v1/rates_spec.rb

# Run with coverage report
bundle exec rspec --require spec_helper --format RspecJunitFormatter --out rspec.xml
```

### Linting

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

## API Documentation

See `contracts/` directory for OpenAPI specifications:
- `contracts/auth.yaml` - Authentication endpoints
- `contracts/market-rates.yaml` - Market rates endpoints
- `contracts/transactions.yaml` - Transaction endpoints

## Environment Variables

See `.env.example` for all required environment variables.

## Architecture

- **Controllers**: `app/controllers/api/v1/`
- **Models**: `app/models/`
- **Services**: `app/services/`
- **Jobs**: `app/jobs/`
- **Tests**: `spec/`

## Key Features

- ✅ JWT authentication
- ✅ Real-time market rates via TGJU API
- ✅ SMS OTP verification via Kavenegar
- ✅ Jalali date support
- ✅ Dual-currency (Toman + USD) tracking
- ✅ Offline-first local storage (Flutter)
- ✅ PostgreSQL with Active Record Encryption

## Phase 2: Foundation

Next phase will implement:
- User model with authentication
- MarketRate, Transaction, Category models
- JWT token generation and validation
- OTP service integration
- Background jobs for market data fetching
