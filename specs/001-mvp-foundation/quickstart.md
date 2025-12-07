# Quickstart: MVP Foundation

**Feature**: 001-mvp-foundation  
**Date**: 2025-12-07  
**Status**: Setup Guide

This guide walks developers through setting up both the Rails 8 backend API and Flutter mobile app for local development and testing.

---

## Prerequisites

Before starting, ensure you have:

### System Requirements
- **macOS 12+** or **Linux (Ubuntu 20.04+)** or **Windows with WSL2**
- **Git** 2.30+
- **Docker** 20.10+ (for PostgreSQL, recommended)

### Backend (Rails)
- **Ruby** 3.4.0 ([install via rbenv](https://github.com/rbenv/rbenv) or asdf)
- **PostgreSQL** 15+ (via Homebrew, Docker, or system package manager)
- **Bundler** 2.x
- **Redis** (optional in MVP - we use Solid Queue/Cache instead)

### Frontend (Flutter)
- **Flutter SDK** 3.x ([download](https://flutter.dev/docs/get-started/install))
- **Dart** 3.x (included with Flutter)
- **Xcode 14+** (for iOS) or **Android Studio** 2021+ (for Android)
- **CocoaPods** 1.11+ (for iOS dependencies)

---

## Step 1: Clone Repository

```bash
git clone https://github.com/abmahmoudi1980/zarbin.git
cd zarbin
```

Ensure you're on the feature branch:

```bash
git checkout 001-mvp-foundation
```

---

## Step 2: Set Up Backend (Rails 8 API)

### 2.1 Install Ruby Dependencies

Navigate to the backend directory:

```bash
cd backend
bundle install
```

This installs all gems listed in `Gemfile`, including:
- Rails 8
- PostgreSQL adapter
- Solid Queue/Cache
- RSpec for testing
- Kavenegar (SMS OTP)
- parsi-date (Jalali calendar)

### 2.2 Configure Environment Variables

Create a `.env` file in the `backend/` directory:

```bash
cat > .env << 'EOF'
# Database
DATABASE_URL=postgresql://localhost:5432/zarbin_dev
DATABASE_TEST_URL=postgresql://localhost:5432/zarbin_test

# API Keys
KAVENEGAR_API_KEY=your_kavenegar_api_key_here
TGJU_API_BASE=https://api.tgju.org/v1

# Authentication
JWT_SECRET=your_very_secret_jwt_key_generate_with_openssl_rand

# Redis (not used in MVP, but Rails 8 may reference)
REDIS_URL=redis://localhost:6379/0

# CORS (allow Flutter app)
CORS_ORIGINS=localhost:3000,localhost:8000

# Rails
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=true
EOF
```

**Generate JWT Secret**:

```bash
openssl rand -hex 32
# Copy output to JWT_SECRET in .env
```

### 2.3 Set Up PostgreSQL Database

**Option A: Using Docker** (Recommended)

```bash
docker run --name zarbin-postgres \
  -e POSTGRES_USER=zarbin \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=zarbin_dev \
  -p 5432:5432 \
  -d postgres:15
```

**Option B: Using Homebrew** (macOS)

```bash
brew install postgresql@15
brew services start postgresql@15
createdb zarbin_dev
```

**Option C: Using System Package Manager** (Linux)

```bash
sudo apt-get install postgresql postgresql-contrib
sudo -u postgres createdb zarbin_dev
```

### 2.4 Create and Migrate Database

```bash
cd backend

# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed predefined data (categories, etc.)
rails db:seed
```

Verify the database is ready:

```bash
rails db:schema:dump
# Check db/schema.rb exists and lists User, Transaction, Category tables
```

### 2.5 Start Rails Development Server

```bash
cd backend
bundle exec rails s -p 3000
```

Expected output:
```
=> Booting Puma
=> Rails 8.0.0 application starting in development
=> Run `rails server --help` for more startup options
Puma starting in single mode...
* Listening on http://127.0.0.1:3000
```

**Test the API**:

```bash
curl http://localhost:3000/health
# Should return 200 OK
```

---

## Step 3: Set Up Frontend (Flutter App)

### 3.1 Install Flutter Dependencies

Navigate to the frontend directory:

```bash
cd frontend
flutter pub get
```

This installs all packages from `pubspec.yaml`, including:
- shamsi_date (Jalali calendar)
- persian_datetime_picker
- provider (state management)
- sqflite + hive (local storage)
- http (API client)

### 3.2 Configure API Endpoint

Create `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
```

Update this for production/staging environments as needed.

### 3.3 Set Up Localization (Persian)

Flutter automatically handles RTL for Persian locale. Verify in `pubspec.yaml`:

```yaml
flutter:
  # ... existing config
  
  assets:
    - assets/fonts/
    - assets/images/

  fonts:
    - family: Vazir
      fonts:
        - asset: assets/fonts/Vazir-Regular.ttf
        - asset: assets/fonts/Vazir-Bold.ttf
          weight: 700
```

### 3.4 Generate App Icons & Splash

Flutter uses platform-specific icons. For MVP, copy placeholder icons to:
- `android/app/src/main/res/mipmap-*` (Android)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (iOS)

Or use [Flutter Launcher Icons package](https://pub.dev/packages/flutter_launcher_icons):

```bash
flutter pub add flutter_launcher_icons
# Configure pubspec.yaml and run:
flutter pub run flutter_launcher_icons
```

### 3.5 Run on iOS Simulator

```bash
flutter run -d iPhone
```

Or specific device:

```bash
open -a Simulator  # Opens iOS Simulator
flutter run        # Automatically selects running simulator
```

Expected output:
```
✓ Built for iOS
✓ Install and launch application on iPhone
```

**On first run**: 
- Pod dependencies are downloaded (~1-2 minutes)
- App compiles and launches in simulator

### 3.6 Run on Android Emulator

Start Android Emulator:

```bash
$ANDROID_SDK_ROOT/emulator/emulator -avd Pixel_API_30
```

Then:

```bash
flutter run -d emulator
```

Or see available devices:

```bash
flutter devices
flutter run -d <device_id>
```

### 3.7 Run Web (for testing)

Flutter supports web for rapid UI testing:

```bash
flutter run -d chrome
```

Open http://localhost:56793 in browser.

---

## Step 4: Verify Full Stack Integration

### 4.1 API Health Check

Backend running on `http://localhost:3000`:

```bash
curl -X GET http://localhost:3000/health
# Expected: {"status":"ok"}
```

### 4.2 Market Rates Endpoint

```bash
curl -X GET http://localhost:3000/api/v1/rates
# Expected: JSON with current rates
```

### 4.3 Create Test User (via API)

```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "mobile_number": "+989121234567",
    "password": "TestPass123"
  }'
# Expected: {"message":"OTP sent"}
```

### 4.4 Verify OTP in Database

Check what OTP was generated:

```bash
cd backend
rails console

# In Rails console:
OtpVerification.last.otp_code
# => "123456" (or whatever code was generated)
```

### 4.5 Complete Registration (verify OTP)

```bash
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "mobile_number": "+989121234567",
    "otp_code": "123456"
  }'
# Expected: {"message":"User created", "token":"eyJhbGc..."}
```

### 4.6 Test Flutter Connection

In Flutter app, tap "Register" button and follow the flow. The app should:
1. Send mobile number to `/auth/register`
2. Receive OTP via Kavenegar SMS (or see in Rails console for testing)
3. Submit OTP to `/auth/verify-otp`
4. Store JWT token in secure storage
5. Navigate to home screen

---

## Step 5: Development Workflow

### Running Tests

**Backend (RSpec)**:

```bash
cd backend

# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage report
bundle exec rspec --format documentation
```

**Frontend (Flutter)**:

```bash
cd frontend

# Run unit tests
flutter test

# Run specific test
flutter test test/models/transaction_test.dart

# Run with coverage
flutter test --coverage
lcov --list coverage/lcov.info  # View coverage report
```

### Hot Reload (Flutter)

While `flutter run` is active:
- Press `r` to hot-reload code changes
- Press `R` to hot-restart (restarts Dart VM)
- Press `q` to quit

This enables rapid UI iteration without rebuilding.

### Database Migrations (Rails)

Create new migration:

```bash
cd backend
rails generate migration CreateNewTable
# Edit db/migrate/[timestamp]_create_new_table.rb

rails db:migrate
```

### Formatting & Linting

**Rails**:

```bash
cd backend

# RuboCop (linting)
bundle exec rubocop

# Beautify code
bundle exec rubocop -a
```

**Flutter**:

```bash
cd frontend

# Analyze code
flutter analyze

# Format code
dart format --set-exit-if-changed lib/
```

---

## Step 6: Common Issues & Fixes

### PostgreSQL Connection Refused

**Problem**: `PG::ConnectionBad: could not connect to server`

**Solution**:
```bash
# Check if PostgreSQL is running
brew services list  # macOS
sudo systemctl status postgresql  # Linux

# Start PostgreSQL
brew services start postgresql@15  # macOS
docker start zarbin-postgres  # Docker

# Verify connection
psql -h localhost -U zarbin -d zarbin_dev
```

### Flutter Pub Cache Issues

**Problem**: Packages not found after cloning

**Solution**:
```bash
cd frontend
flutter clean
flutter pub get
```

### iOS Pod Issues

**Problem**: CocoaPods dependency conflicts

**Solution**:
```bash
cd frontend/ios
rm -rf Pods Pod.lock
cd ..
flutter pub get
flutter run -d iPhone
```

### Android Emulator Slow

**Problem**: Emulator is extremely slow

**Solution**:
- Use hardware acceleration: `-accel on` flag
- Allocate more RAM to emulator (Settings > Memory)
- Use Pixel API 28+ (older APIs are slower)

### CORS Errors in Flutter Web

**Problem**: `Access to XMLHttpRequest at 'http://localhost:3000...' has been blocked by CORS`

**Solution**: Ensure CORS is configured in Rails:

```bash
# In backend/Gemfile
gem 'rack-cors'

# In backend/config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:5173', 'localhost:56793'  # Flutter web ports
    resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete]
  end
end
```

---

## Step 7: Deployment Preparation

### Backend Deployment (Kamal)

Kamal is a containerized deployment tool. Setup:

```bash
cd backend

# Install Kamal
gem install kamal

# Initialize Kamal config
kamal init

# Edit config/deploy.yml with your server details
```

For first deployment:

```bash
kamal setup         # Deploy and configure server
kamal deploy        # Push latest code
kamal logs         # View server logs
```

### Frontend Distribution

**iOS App Store**:
1. Create Apple Developer account
2. Create App ID on Apple Developer Portal
3. Generate signing certificates/provisioning profiles
4. In Xcode: Select Team and signing
5. Archive and submit via Xcode Organizer

**Android Play Store**:
1. Create Google Play Developer account
2. Create app entry in Google Play Console
3. Generate release signing key
4. Build release APK/AAB:
   ```bash
   flutter build appbundle --release
   ```
5. Upload via Google Play Console

---

## Step 8: Troubleshooting & Getting Help

### Check Logs

**Rails**:
```bash
cd backend
tail -f log/development.log
```

**Flutter**:
```bash
cd frontend
flutter logs
```

### Enable Debug Mode

**Rails** (access `localhost:3000/` and see detailed error pages in dev)

**Flutter**:
```bash
flutter run --verbose
```

### Contact & Resources

- **Rails Documentation**: https://guides.rubyonrails.org
- **Flutter Documentation**: https://flutter.dev/docs
- **Zarbin Issues**: https://github.com/abmahmoudi1980/zarbin/issues

---

## Summary Checklist

- [ ] Git cloned, on 001-mvp-foundation branch
- [ ] Ruby 3.4+ installed
- [ ] PostgreSQL running with zarbin_dev database
- [ ] `bundle install` completed in backend/
- [ ] `.env` file created with API keys
- [ ] `rails db:migrate` completed
- [ ] `rails s` running on http://localhost:3000
- [ ] Flutter SDK 3.x installed
- [ ] `flutter pub get` completed in frontend/
- [ ] iOS Simulator or Android Emulator running
- [ ] `flutter run` shows app on device/emulator
- [ ] Curl test to `/api/v1/rates` returns 200
- [ ] All tests passing: `bundle exec rspec` and `flutter test`

Once all items are checked, you're ready to start development! 🚀

---

## Next Steps

1. Review [spec.md](./spec.md) for feature requirements
2. Review [data-model.md](./data-model.md) for database schema
3. Check [contracts/](./contracts/) for API specifications
4. Start implementing user stories in order (P1, P2, P3...)
5. Write tests as you implement (TDD per Constitution IV)
