// lib/utils/validators.dart
import 'package:shamsi_date/shamsi_date.dart';

class Validators {
  // Validate Iranian mobile number (09XXXXXXXXX)
  static String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'شماره موبایل الزامی است';
    }

    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    
    if (!RegExp(r'^09\d{9}$').hasMatch(cleaned)) {
      return 'شماره موبایل باید 11 رقم و با 09 شروع شود';
    }

    return null;
  }

  // Validate 6-digit OTP code
  static String? validateOtpCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'کد تایید الزامی است';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'کد تایید باید 6 رقم باشد';
    }

    return null;
  }

  // Validate transaction amount (1 to 99,999,999,999)
  static String? validateTransactionAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'مبلغ الزامی است';
    }

    final amount = int.tryParse(value);
    if (amount == null) {
      return 'مبلغ باید عدد صحیح باشد';
    }

    if (amount < 1) {
      return 'مبلغ باید بیشتر از صفر باشد';
    }

    if (amount > 99999999999) {
      return 'مبلغ حداکثر 99,999,999,999 تومان است';
    }

    return null;
  }

  // Validate transaction notes (max 500 chars)
  static String? validateNotes(String? value) {
    if (value != null && value.length > 500) {
      return 'توضیحات نباید بیشتر از 500 کاراکتر باشد';
    }
    return null;
  }

  // Validate Jalali date format (YYYY/MM/DD)
  static String? validateJalaliDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'تاریخ الزامی است';
    }

    try {
      final parts = value.split('/');
      if (parts.length != 3) {
        throw FormatException('Format invalid');
      }

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      if (month < 1 || month > 12) {
        return 'ماه باید بین 1 تا 12 باشد';
      }

      final daysInMonth = _getDaysInJalaliMonth(year, month);
      if (day < 1 || day > daysInMonth) {
        return 'روز نامعتبر';
      }

      return null;
    } catch (e) {
      return 'فرمت تاریخ نامعتبر است (YYYY/MM/DD)';
    }
  }

  // Validate currency conversion
  static String? validateCurrencyAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'مبلغ الزامی است';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'مبلغ معتبر نیست';
    }

    if (amount <= 0) {
      return 'مبلغ باید بیشتر از صفر باشد';
    }

    return null;
  }

  // Validate category selection
  static String? validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return 'دسته‌بندی الزامی است';
    }
    return null;
  }

  // Validate transaction type
  static String? validateTransactionType(String? type) {
    if (type == null || type.isEmpty) {
      return 'نوع تراکنش الزامی است';
    }
    if (type != 'income' && type != 'expense') {
      return 'نوع تراکنش نامعتبر است';
    }
    return null;
  }

  // Helper: Get days in Jalali month
  static int _getDaysInJalaliMonth(int year, int month) {
    if (month <= 6) {
      return 31;
    } else if (month <= 11) {
      return 30;
    } else {
      // Month 12 (Esfand)
      return _isJalaliLeapYear(year) ? 30 : 29;
    }
  }

  // Helper: Check if Jalali year is leap
  static bool _isJalaliLeapYear(int year) {
    try {
      final jalali = Jalali(year, 1, 1);
      return jalali.isLeapYear;
    } catch (e) {
      return false;
    }
  }
}
