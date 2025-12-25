# Zarbin Flutter Frontend

**Status**: Phase 1 Setup ✅ Complete
**Framework**: Flutter 3.16+ with Dart 3.2+
**Language**: Persian (Farsi) - Default locale
**Dates**: Jalali calendar only (v1.0)

## Quick Start

### Prerequisites
- Flutter SDK 3.16 or later
- Dart 3.2 or later
- iOS Simulator or Android Emulator
- Xcode (for iOS) or Android Studio (for Android)

### Setup

```bash
cd frontend

# Get dependencies
flutter pub get

# Generate code (models, providers, etc.)
flutter pub run build_runner build

# Run on simulator/emulator
flutter run

# Run with release mode
flutter run --release
```

### Project Structure

```
lib/
├── config/         # Configuration (API, theme)
├── models/         # Data models
├── services/       # External services (API, storage)
├── providers/      # State management (Provider, Riverpod)
├── screens/        # UI screens
├── widgets/        # Reusable widgets
├── utils/          # Utilities (formatters, validators)
└── main.dart       # Entry point

test/
├── screens/        # Screen tests
└── widgets/        # Widget tests

assets/
├── fonts/          # Persian fonts (Vazir)
├── images/         # Images
└── locales/        # Localization files
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/screens/market_rates_screen_test.dart
```

### Code Generation

```bash
# Generate Hive models
flutter pub run build_runner build

# Generate freezed models
flutter pub run build_runner build
```

### Linting & Formatting

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/ --set-exit-if-changed

# Run linter
flutter pub run custom_lint
```

## Key Features

- ✅ Persian (Farsi) localization - Primary language
- ✅ Jalali calendar date picker
- ✅ Dual-currency display (Toman + USD)
- ✅ Local SQLite + Hive storage
- ✅ Secure JWT token storage
- ✅ Offline-first architecture
- ✅ RTL layout support
- ✅ Real-time market rates
- ✅ **Automatic rate refresh** (every 5 minutes) - New in v0.2.0
- ✅ Category-based transaction tracking
- ✅ Net worth dashboard

### Auto-Refresh Feature (v0.2.0)

The market rates screen automatically updates exchange rates every 5 minutes while visible:

- **Automatic Updates**: Rates refresh periodically without manual intervention
- **Visual Feedback**: Subtle progress indicator shows when data is updating
- **Battery Efficient**: Auto-refresh pauses when app is backgrounded
- **Smart Coordination**: Pull-to-refresh resets the 5-minute timer
- **Non-Blocking**: UI remains fully interactive during updates
- **Lifecycle Aware**: Automatically resumes refreshing when app returns to foreground

**User Experience**:
- Open market rates screen → Auto-refresh starts automatically
- Wait 5 minutes → Rates update with subtle indicator
- Background the app → Auto-refresh pauses (saves battery)
- Return to app → Immediate refresh + auto-refresh resumes
- Pull to refresh → Manual update + timer resets

## Architecture

### State Management
- **Provider**: For simple state (theme, auth)
- **Riverpod**: For complex data flow

### Storage
- **SQLite**: Transaction data persistence
- **Hive**: Market rates caching
- **Secure Storage**: JWT tokens

### Networking
- **Dio**: HTTP client with interceptors
- **retry_interceptor**: Automatic retry logic

## API Integration

Base URL: `http://localhost:3000/api/v1` (development)

See `lib/config/api_config.dart` for endpoints.

## Localization

- **Default**: Persian (fa_IR)
- **Secondary**: English (en_US)
- **Dates**: Jalali calendar only for MVP

## Next Phase (Phase 2)

Will implement:
- User authentication screens
- Market rates fetching and display
- Transaction management
- Dashboard and analytics
- Offline sync capabilities
