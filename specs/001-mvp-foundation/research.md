# Research: MVP Foundation

**Feature**: 001-mvp-foundation  
**Date**: 2025-12-06  
**Status**: Complete

This document captures all technology decisions and research findings for the MVP Foundation feature.

---

## 1. Market Data API

### Decision: **TGJU API**

### Rationale
- Industry standard for Iranian free-market prices
- **Free tier** with no authentication required
- Covers all required assets: USD, Gold, Bahar Azadi coin
- Real-time updates during Tehran market hours (9 AM - 6 PM Iran time)
- Widely used by Iranian fintech applications

### Alternatives Considered

| API | Pros | Cons | Rejected Because |
|-----|------|------|------------------|
| Bonbast | Trusted street rates, popular | No official API, Cloudflare protected, scraping required | Unreliable, ToS violation risk |
| Navasan | Official docs, CORS enabled | Rate limits, registration required | Extra complexity for MVP |
| AccessBan | No auth needed | Third-party wrapper | Reliability concerns, indirect source |

### Implementation Details

**Endpoints**:
```
USD:   https://api.tgju.org/v1/market/indicator/summary-table-data/price_dollar_rl
Gold:  https://api.tgju.org/v1/market/indicator/summary-table-data/geram18
Coin:  https://api.tgju.org/v1/market/indicator/summary-table-data/sekee
```

**Response Format** (example for USD):
```json
{
  "data": {
    "p": "685000",        // Current price in Rial
    "d": "5000",          // Daily change
    "dp": "0.74",         // Daily change percentage
    "dt": "1404/09/16"    // Jalali date
  }
}
```

**Key Notes**:
- Prices returned in **Rial** → divide by 10 for Toman
- Unofficial rate limit: ~60 requests/minute
- Cache recommended: 5 minutes during market hours
- No authentication required

---

## 2. SMS OTP Service

### Decision: **Kavenegar**

### Rationale
- Official Ruby gem (`gem 'kavenegar'`) reduces integration complexity
- Purpose-built OTP/Verify API with template-based messaging
- Industry standard in Iranian fintech - most widely used
- 98%+ delivery rate across all Iranian mobile operators (MCI, MTN Irancell, Rightel)
- Best documentation with Ruby code samples

### Alternatives Considered

| Provider | Pros | Cons | Rejected Because |
|----------|------|------|------------------|
| Ghasedak | Competitive pricing, good reliability | No Ruby gem, custom client needed | Extra development effort |
| SMS.ir | Modern API, cheaper | Smaller market share | Less proven in production |
| Mediana | Long track record | Older API design | Developer experience |
| Faraz SMS | Enterprise features | Less developer-friendly | Over-engineered for MVP |

### Implementation Details

**Installation**:
```ruby
# Gemfile
gem 'kavenegar'
```

**Usage**:
```ruby
# config/initializers/kavenegar.rb
Kavenegar.configure do |config|
  config.api_key = ENV['KAVENEGAR_API_KEY']
end

# app/services/sms_otp_service.rb
class SmsOtpService
  def send_otp(phone_number, otp_code)
    client = Kavenegar::Client.new
    client.verify_lookup(
      receptor: phone_number,
      token: otp_code,
      template: 'zarbin-verify'  # Pre-registered template
    )
  end
end
```

**Pricing**:
- Per OTP: ~45-60 Toman (~$0.001)
- Monthly estimate (10K users): ~$30/month
- Free credit: 10,000 Toman on registration

**Delivery Metrics**:
- Speed: 3-10 seconds typical, 15-30 seconds peak hours
- Success rate: ~98% for valid numbers
- Rate limit: 30 requests/second

---

## 3. Jalali Calendar (Ruby on Rails)

### Decision: **parsi-date** gem

### Rationale
- Native Ruby Date extension - seamless integration
- ActiveRecord support with `parsi_date_accessor`
- Full date arithmetic support
- Persian month and day names built-in
- Well-maintained and documented

### Alternatives Considered

| Gem | Pros | Cons | Rejected Because |
|-----|------|------|------------------|
| jdate | Simple API | Less maintained | Activity concerns |
| jalali | Basic conversion | No ActiveRecord integration | Missing features |

### Implementation Details

**Installation**:
```ruby
# Gemfile
gem 'parsi-date'
```

**Usage**:
```ruby
# Conversion
Date.today.to_parsi              # => Parsi::Date 1404/09/16
Parsi::Date.today.to_gregorian   # => Date 2025-12-06

# Formatting
parsi_date.strftime('%Y/%m/%d')  # => "1404/09/16"
parsi_date.strftime('%A %d %B')  # => "جمعه ۱۶ آذر"

# ActiveRecord integration
class Transaction < ApplicationRecord
  parsi_date_accessor :transaction_date
end
```

---

## 4. Jalali Calendar (Flutter/Dart)

### Decision: **shamsi_date** package + **persian_datetime_picker**

### Rationale
- `shamsi_date`: Comprehensive Jalali date handling with null-safety
- `persian_datetime_picker`: Material Design Jalali picker with RTL support
- Both actively maintained with good documentation
- Persian/Farsi output support built-in

### Alternatives Considered

| Package | Pros | Cons | Rejected Because |
|---------|------|------|------------------|
| jalali | Simple | Less feature-rich | Missing formatter |
| shamsi | Basic | Abandoned | No updates since 2020 |

### Implementation Details

**Installation**:
```yaml
# pubspec.yaml
dependencies:
  shamsi_date: ^1.0.0
  persian_datetime_picker: ^2.0.0
```

**Usage**:
```dart
import 'package:shamsi_date/shamsi_date.dart';

// Conversion
final jalali = Jalali.now();              // 1404/09/16
final gregorian = jalali.toGregorian();   // 2025-12-06
final fromGregorian = Gregorian.now().toJalali();

// Formatting
final f = jalali.formatter;
f.yyyy;    // '1404'
f.mN;      // 'آذر'
f.wN;      // 'جمعه'

// Date Picker
final picked = await showPersianDatePicker(
  context: context,
  initialDate: Jalali.now(),
  firstDate: Jalali(1400, 1, 1),
  lastDate: Jalali(1410, 12, 29),
);
```

---

## 5. Persian Numerals

### Decision: Custom utility functions (no external dependency)

### Rationale
- Simple character mapping, no library needed
- Full control over formatting behavior
- Consistent implementation across Rails and Flutter

### Implementation Details

**Ruby**:
```ruby
# app/helpers/persian_helper.rb
module PersianHelper
  PERSIAN_DIGITS = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'].freeze

  def to_persian_numerals(number)
    number.to_s.chars.map { |c| c =~ /\d/ ? PERSIAN_DIGITS[c.to_i] : c }.join
  end
  
  def format_toman(amount)
    formatted = number_with_delimiter(amount)
    to_persian_numerals(formatted)
  end
end
```

**Dart/Flutter**:
```dart
// lib/core/utils/persian_numbers.dart
class PersianNumbers {
  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  
  static String convert(dynamic number) {
    return number.toString().split('').map((c) {
      final digit = int.tryParse(c);
      return digit != null ? _persianDigits[digit] : c;
    }).join();
  }
  
  static String formatToman(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return convert(formatted);
  }
}
```

---

## 6. RTL Layout (Flutter)

### Decision: App-level RTL configuration with Persian locale

### Implementation Details

```dart
// lib/main.dart
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  locale: const Locale('fa', 'IR'),
  supportedLocales: const [
    Locale('fa', 'IR'),
    Locale('en', 'US'),
  ],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: ThemeData(
    fontFamily: 'Vazirmatn',  // Persian-optimized font
  ),
);
```

**Recommended Font**: Vazirmatn (Google Fonts, supports all Persian characters)

---

## 7. Authentication Strategy

### Decision: In-house JWT-based authentication

### Rationale
- Constitution mandates no third-party auth services (data sovereignty)
- JWT tokens with 7-day expiry per spec requirements
- Device-bound refresh tokens for security

### Implementation Details

**Gems**:
```ruby
# Gemfile
gem 'jwt'
gem 'bcrypt'
```

**Token Structure**:
```ruby
# Access token (short-lived, 1 hour)
{
  sub: user_id,
  exp: 1.hour.from_now.to_i,
  iat: Time.current.to_i,
  type: 'access'
}

# Refresh token (long-lived, 7 days)
{
  sub: user_id,
  exp: 7.days.from_now.to_i,
  iat: Time.current.to_i,
  type: 'refresh',
  jti: SecureRandom.uuid  # For revocation
}
```

---

## 8. Rails 8 Specific Features

### Decisions

| Feature | Usage | Rationale |
|---------|-------|-----------|
| **Solid Queue** | Background job for market rate refresh | No Redis dependency per constitution |
| **Solid Cache** | Cache market rates (5-min TTL) | Database-backed, simpler deployment |
| **Active Record Encryption** | Encrypt user mobile numbers | Privacy-first per constitution |
| **Kamal** | Container deployment | Easy VPS deployment |

### Implementation Details

**Active Record Encryption**:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  encrypts :mobile_number, deterministic: true  # For lookups
end
```

**Solid Queue Job**:
```ruby
# app/jobs/market_rate_refresh_job.rb
class MarketRateRefreshJob < ApplicationJob
  queue_as :default
  
  def perform
    MarketDataFetcher.new.refresh_all_rates
  end
end

# config/recurring.yml (every 5 minutes during market hours)
market_rate_refresh:
  class: MarketRateRefreshJob
  schedule: every 5 minutes
```

---

## Summary of Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Backend Framework | Ruby on Rails | 8.x |
| Backend Language | Ruby | 3.4+ |
| Database | PostgreSQL | 15+ |
| Background Jobs | Solid Queue | Built-in |
| Caching | Solid Cache | Built-in |
| Market Data API | TGJU | v1 |
| SMS Provider | Kavenegar | Latest |
| Jalali (Ruby) | parsi-date | Latest |
| Mobile Framework | Flutter | Latest stable |
| Jalali (Flutter) | shamsi_date | ^1.0.0 |
| Date Picker | persian_datetime_picker | ^2.0.0 |
| Auth | JWT (in-house) | - |
| Deployment | Kamal | Latest |
