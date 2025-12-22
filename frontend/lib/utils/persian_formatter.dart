// lib/utils/persian_formatter.dart
import 'package:intl/intl.dart';

class PersianFormatter {
  // Persian digit mapping
  static const Map<String, String> _persianDigits = {
    '0': '۰',
    '1': '۱',
    '2': '۲',
    '3': '۳',
    '4': '۴',
    '5': '۵',
    '6': '۶',
    '7': '۷',
    '8': '۸',
    '9': '۹',
    ',': '٬',
  };

  // Convert English digits to Persian
  static String toPersianDigits(String input) {
    String result = input;
    _persianDigits.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  // Convert Persian digits to English
  static String toEnglish(String input) {
    String result = input;
    _persianDigits.forEach((key, value) {
      result = result.replaceAll(value, key);
    });
    return result;
  }

  // Format number with thousand separators (Persian style)
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'en_US');
    return toPersianDigits(formatter.format(number));
  }

  // Format currency (Toman)
  static String formatToman(int amount) {
    final formatted = formatNumber(amount);
    return '$formatted تومان';
  }

  // Format currency with symbol
  static String formatCurrency(double amount, String currencySymbol) {
    final formatter = NumberFormat('#,##0.00');
    return '${toPersianDigits(formatter.format(amount))} $currencySymbol';
  }

  // Format percentage
  static String formatPercentage(double percentage, {int decimals = 2}) {
    final formatter = NumberFormat('0.${'0' * decimals}');
    return '${toPersianDigits(formatter.format(percentage))}%';
  }

  // Format large numbers with abbreviations (K, M, B)
  static String formatCompactNumber(int number) {
    if (number >= 1000000000) {
      return '${toPersianDigits(((number / 1000000000).toStringAsFixed(2)))} میلیارد';
    } else if (number >= 1000000) {
      return '${toPersianDigits(((number / 1000000).toStringAsFixed(2)))} میلیون';
    } else if (number >= 1000) {
      return '${toPersianDigits(((number / 1000).toStringAsFixed(2)))} هزار';
    } else {
      return toPersianDigits(number.toString());
    }
  }

  // Format phone number (Iranian format: 0912 1234 567)
  static String formatPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 11) {
      return phoneNumber;
    }
    final formatted =
        '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    return toPersianDigits(formatted);
  }

  // Abbreviate text with ellipsis
  static String abbreviate(String text, {int maxLength = 20}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  // Convert number to Persian words (1 -> یک)
  static String numberToWords(int number) {
    const ones = [
      '',
      'یک',
      'دو',
      'سه',
      'چهار',
      'پنج',
      'شش',
      'هفت',
      'هشت',
      'نه'
    ];

    const teens = [
      'ده',
      'یازده',
      'دوازده',
      'سیزده',
      'چهارده',
      'پانزده',
      'شانزده',
      'هفده',
      'هجده',
      'نوزده'
    ];

    const tens = [
      '',
      '',
      'بیست',
      'سی',
      'چهل',
      'پنجاه',
      'شصت',
      'هفتاد',
      'هشتاد',
      'نود'
    ];

    if (number == 0) return 'صفر';
    if (number < 0) return 'منفی ${numberToWords(-number)}';
    if (number < 10) return ones[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      final ten = number ~/ 10;
      final one = number % 10;
      return '${tens[ten]}${one > 0 ? ' و ${ones[one]}' : ''}';
    }
    if (number < 1000) {
      final hundred = number ~/ 100;
      final remainder = number % 100;
      return 'صد ${hundreds[hundred]}${remainder > 0 ? ' و ${numberToWords(remainder)}' : ''}';
    }

    return number.toString();
  }

  static const Map<int, String> hundreds = {
    1: 'یکصد',
    2: 'دویست',
    3: 'سیصد',
    4: 'چهارصد',
    5: 'پانصد',
    6: 'ششصد',
    7: 'هفتصد',
    8: 'هشتصد',
    9: 'نهصد',
  };
}
