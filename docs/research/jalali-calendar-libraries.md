# Jalali (Shamsi/Persian) Calendar Libraries Research

## Overview

This document summarizes research on Jalali (Persian/Shamsi) calendar libraries for both Ruby on Rails backend and Flutter/Dart frontend development.

---

## Ruby on Rails

### Recommended: `parsi-date` gem

**Repository:** [hzamani/parsi-date](https://github.com/hzamani/parsi-date)  
**Installation:** `gem 'parsi-date'`

#### Key Features

1. **Date Conversion**
   - Seamless conversion between Gregorian and Jalali dates
   - `to_parsi` / `to_gregorian` methods
   - Extends Ruby's built-in `Date` and `DateTime` classes

2. **Date Creation & Validation**
   ```ruby
   # Create Jalali date
   date = Parsi::Date.civil(1403, 9, 15)
   date = Parsi::Date.today
   date = Parsi::Date.parse("1403/09/15")
   
   # Validate dates
   Parsi::Date.valid?(1403, 12, 30)  # Check if valid
   Parsi::Date.leap?(1403)           # Check leap year
   ```

3. **Date Formatting with `strftime`**
   ```ruby
   date = Parsi::Date.today
   
   # Persian output
   date.strftime("%A %d %B %Y")     # => "سه‌شنبه 12 دی 1391"
   
   # English/Finglish output
   date.strftime("%^EA %d %^EB %Y") # => "Seshambe 12 Day 1391"
   ```

4. **Persian Month/Day Names**
   - Built-in Persian month names: فروردین, اردیبهشت, خرداد, تیر, مرداد, شهریور, مهر, آبان, آذر, دی, بهمن, اسفند
   - Persian day names: یک‌شنبه, دوشنبه, سه‌شنبه, چهارشنبه, پنج‌شنبه, جمعه, شنبه
   - Abbreviated forms available

5. **ActiveRecord Integration**
   ```ruby
   class Model < ActiveRecord::Base
     extend Parsi::DateAccessors
     parsi_date_accessor :created_at, :updated_at
   end
   
   # Usage
   model.created_at_parsi          # Returns Parsi::Date
   model.created_at_parsi = "1403/09/15"  # Accepts string
   ```

6. **Date Arithmetic**
   ```ruby
   date = Parsi::Date.today
   date + 30           # Add 30 days
   date >> 2           # Add 2 months
   date.next_month
   date.prev_year
   date.upto(end_date) # Iterate
   ```

#### Code Example
```ruby
# Gemfile
gem 'parsi-date'

# Usage
require 'parsi-date'

# Convert Gregorian to Jalali
gregorian = Date.civil(2024, 12, 6)
jalali = gregorian.to_parsi
# => #<Parsi::Date: 1403-09-16>

# Format in Persian
jalali.strftime("%A %d %B %Y")
# => "جمعه 16 آذر 1403"

# Create Jalali date directly
date = Parsi::Date.civil(1403, 9, 16)

# Check leap year
Parsi::Date.leap?(1403)  # => true

# Month length
date.monthLength  # depends on month/leap year
```

### Alternative: `jalaali-ruby`

**Repository:** [jalaali/jalaali-ruby](https://github.com/jalaali/jalaali-ruby)

A simpler, algorithm-focused library for date conversion.

```ruby
require './jalaali'

# Gregorian to Jalali
toJalaali(2024, 12, 6)  # => {jy: 1403, jm: 9, jd: 16}

# Jalali to Gregorian  
toGregorian(1403, 9, 16)  # => {gy: 2024, gm: 12, gd: 6}

# Check leap year
isLeapJalaaliYear(1403)  # => true

# Month length
jalaaliMonthLength(1403, 12)  # => 30 (leap year)
```

**Pros:** Lightweight, simple API  
**Cons:** No DateTime support, no formatting, no Persian text output

---

## Flutter/Dart

### Recommended: `shamsi_date` package

**Package:** [shamsi_date on pub.dev](https://pub.dev/packages/shamsi_date)  
**Repository:** [FatulM/shamsi_date](https://github.com/FatulM/shamsi_date)

#### Key Features

1. **Date Conversion**
   ```dart
   // Gregorian to Jalali
   Gregorian g = Gregorian(2024, 12, 6);
   Jalali j = g.toJalali();
   
   // Jalali to Gregorian
   Jalali j = Jalali(1403, 9, 16);
   Gregorian g = j.toGregorian();
   
   // From DateTime
   DateTime dt = DateTime.now();
   Jalali j = dt.toJalali();  // Extension method
   Jalali j = Jalali.fromDateTime(dt);
   ```

2. **Date Creation**
   ```dart
   // With date only
   Jalali j = Jalali(1403, 9, 16);
   
   // With time
   Jalali j = Jalali(1403, 9, 16, 14, 30, 0, 0);
   
   // Today
   Jalali today = Jalali.now();
   
   // From milliseconds
   Jalali j = Jalali.fromMillisecondsSinceEpoch(timestamp);
   ```

3. **Date Properties**
   ```dart
   Jalali j = Jalali(1403, 9, 16);
   
   int year = j.year;           // 1403
   int month = j.month;         // 9
   int day = j.day;             // 16
   int weekDay = j.weekDay;     // 1-7 (Shanbe=1)
   int monthLength = j.monthLength;
   bool isLeap = j.isLeapYear();
   int dayOfYear = j.dayOfYear;
   ```

4. **Powerful Formatting**
   ```dart
   String format(Jalali d) {
     final f = d.formatter;
     return '${f.wN} ${f.d} ${f.mN} ${f.yyyy}';
   }
   // Output: "جمعه 16 آذر 1403"
   
   // Afghanistan month names
   String formatAf(Jalali d) {
     final f = d.formatter;
     return '${f.wN} ${f.d} ${f.mNAf} ${f.yy}';
   }
   // Output: "پنجشنبه 21 جدی 91"
   
   // Finglish (Latin)
   String formatFn(Jalali d) {
     final f = d.formatter;
     return '${f.wNFn} ${f.d} ${f.mNFn} ${f.yy}';
   }
   // Output: "Panjshanbeh 21 Dey 91"
   ```

5. **Formatter Properties**
   - `y`, `yy`, `yyyy` - Year formats
   - `m`, `mm` - Month number
   - `d`, `dd` - Day number
   - `mN` - Month name (Persian)
   - `mNAf` - Month name (Afghanistan)
   - `mNFn` - Month name (Finglish)
   - `wN` - Weekday name (Persian)
   - `wNFn` - Weekday name (Finglish)
   - `tH`, `tHH`, `tM`, `tMM`, `tS`, `tSS` - Time formats

6. **Date Arithmetic**
   ```dart
   Jalali j = Jalali(1403, 9, 16);
   
   // Add/subtract days
   Jalali next = j + 30;
   Jalali prev = j - 7;
   
   // Add years/months/days
   Jalali future = j.addYears(1).addMonths(2).addDays(5);
   // Or combined
   Jalali future = j.add(years: 1, months: 2, days: 5);
   
   // Distance between dates
   int distance = j1 ^ j2;  // Using ^ operator
   int distance = j1.distanceTo(j2);
   ```

7. **Immutable & Null-Safe**
   - All date objects are immutable
   - Full null-safety support
   - Copy methods for manipulation
   ```dart
   Jalali modified = j.copy(month: 1, day: 1);
   Jalali modified = j.withYear(1404).withMonth(1);
   ```

#### Installation
```yaml
dependencies:
  shamsi_date: ^latest_version
```

```dart
import 'package:shamsi_date/shamsi_date.dart';
```

### Recommended for UI: `persian_datetime_picker`

For date picker widgets in Flutter, use alongside `shamsi_date`:

**Package:** `persian_datetime_picker`

#### Features
- Material Design Jalali date picker
- Time picker support
- RTL layout built-in
- Customizable themes
- Range selection support

```dart
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

// Show date picker
Jalali? picked = await showPersianDatePicker(
  context: context,
  initialDate: Jalali.now(),
  firstDate: Jalali(1385, 8),
  lastDate: Jalali(1450, 9),
);

// Show date range picker
JalaliRange? range = await showPersianDateRangePicker(
  context: context,
  initialDateRange: JalaliRange(
    start: Jalali(1400, 1, 1),
    end: Jalali(1400, 1, 10),
  ),
  firstDate: Jalali(1385),
  lastDate: Jalali(1450),
);
```

---

## Persian Numeral Support

### Ruby
The `parsi-date` gem outputs Persian month/day names but uses Western numerals. For Persian numerals, apply a simple mapping:

```ruby
PERSIAN_NUMERALS = {
  '0' => '۰', '1' => '۱', '2' => '۲', '3' => '۳', '4' => '۴',
  '5' => '۵', '6' => '۶', '7' => '۷', '8' => '۸', '9' => '۹'
}

def to_persian_numerals(str)
  str.gsub(/[0-9]/, PERSIAN_NUMERALS)
end

date = Parsi::Date.today.strftime("%Y/%m/%d")
persian_date = to_persian_numerals(date)
# => "۱۴۰۳/۰۹/۱۶"
```

### Flutter/Dart
Similarly, `shamsi_date` outputs Western numerals. Use a helper:

```dart
const Map<String, String> persianNumerals = {
  '0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
  '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
};

String toPersianNumerals(String input) {
  return input.split('').map((c) => persianNumerals[c] ?? c).join();
}

// Usage
String date = '${j.formatter.yyyy}/${j.formatter.mm}/${j.formatter.dd}';
String persianDate = toPersianNumerals(date);
// => "۱۴۰۳/۰۹/۱۶"
```

**Alternative:** Use a Persian font that renders Latin digits as Persian numerals.

---

## RTL Layout Considerations (Flutter)

### App-Level RTL Setup
```dart
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('fa', 'IR'),  // Persian
    Locale('en', 'US'),
  ],
  locale: Locale('fa', 'IR'),  // Force Persian
)
```

### Widget-Level RTL
```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: YourWidget(),
)
```

### Text with RTL
```dart
Text(
  'تاریخ: ${j.formatter.yyyy}/${j.formatter.mm}/${j.formatter.dd}',
  textDirection: TextDirection.rtl,
  style: TextStyle(fontFamily: 'Vazir'),  // Persian font
)
```

### Recommended Persian Fonts
- **Vazir** - Clean, modern (recommended)
- **IRANSans** - Popular commercial font
- **Shabnam** - Free, good readability
- **Samim** - Good for UI

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Vazir
      fonts:
        - asset: assets/fonts/Vazir-Regular.ttf
        - asset: assets/fonts/Vazir-Bold.ttf
          weight: 700
```

---

## Summary Comparison

| Feature | Ruby (`parsi-date`) | Dart (`shamsi_date`) |
|---------|---------------------|----------------------|
| Date Conversion | ✅ | ✅ |
| Date Creation | ✅ | ✅ |
| Date Formatting | ✅ strftime | ✅ Formatter class |
| Persian Names | ✅ | ✅ |
| Afghanistan Names | ❌ | ✅ |
| Finglish Output | ✅ | ✅ |
| Date Arithmetic | ✅ | ✅ |
| Time Support | ✅ DateTime | ✅ Built-in |
| Leap Year | ✅ | ✅ |
| Immutable | ✅ | ✅ |
| Null-Safe | N/A | ✅ |
| ActiveRecord | ✅ | N/A |
| Persian Numerals | Manual | Manual |
| Date Picker | N/A | Separate package |

---

## Recommendations for Zarbin Project

### Backend (Ruby on Rails)
Use **`parsi-date`** gem:
- Mature, well-maintained library
- Native Ruby Date/DateTime integration
- ActiveRecord helpers for model attributes
- Comprehensive formatting options

### Frontend (Flutter)
Use **`shamsi_date`** + **`persian_datetime_picker`**:
- `shamsi_date` for all date logic and formatting
- `persian_datetime_picker` for UI date selection
- Add Persian numeral conversion helper
- Configure app for RTL with Persian locale

### Implementation Notes
1. Store dates in database as Gregorian (standard practice)
2. Convert to Jalali only for display/input
3. Use ISO 8601 format for API communication
4. Apply Persian numerals at the presentation layer
5. Ensure consistent RTL layout throughout the app
