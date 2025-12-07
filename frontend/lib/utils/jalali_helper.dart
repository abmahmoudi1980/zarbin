// lib/utils/jalali_helper.dart
import 'package:shamsi_date/shamsi_date.dart';

class JalaliHelper {
  // Convert Gregorian DateTime to Jalali date string (YYYY/MM/DD)
  static String toJalaliString(DateTime gregorianDate) {
    final jalali = Jalali.fromDateTime(gregorianDate);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  // Convert Jalali date string (YYYY/MM/DD) to Gregorian DateTime
  static DateTime fromJalaliString(String jalaliDateString) {
    final parts = jalaliDateString.split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid Jalali date format: $jalaliDateString');
    }

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    try {
      final jalali = Jalali(year, month, day);
      return jalali.toDateTime();
    } catch (e) {
      throw FormatException('Invalid Jalali date: $jalaliDateString');
    }
  }

  // Get current Jalali date as string
  static String getCurrentJalaliDate() {
    return toJalaliString(DateTime.now());
  }

  // Get Jalali date from DateTime with optional format
  static String formatJalaliDate(
    DateTime date, {
    bool includeTime = false,
    bool shortMonth = false,
  }) {
    final jalali = Jalali.fromDateTime(date);
    final monthName = _getMonthName(jalali.month, shortMonth);
    
    String formatted = '$monthName ${jalali.day}, ${jalali.year}';
    
    if (includeTime) {
      formatted += ' ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    
    return formatted;
  }

  // Get Jalali day name (شنبه, یکشنبه, ...)
  static String getJalaliDayName(DateTime date, {bool shortForm = false}) {
    final jalali = Jalali.fromDateTime(date);
    const dayNames = [
      'شنبه', // Saturday
      'یکشنبه', // Sunday
      'دوشنبه', // Monday
      'سه‌شنبه', // Tuesday
      'چهارشنبه', // Wednesday
      'پنج‌شنبه', // Thursday
      'جمعه', // Friday
    ];
    
    const shortDayNames = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    
    final dayIndex = jalali.weekDay % 7;
    return shortForm ? shortDayNames[dayIndex] : dayNames[dayIndex];
  }

  // Get Jalali week number
  static int getJalaliWeekNumber(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final firstDayOfYear = Jalali(jalali.year, 1, 1).toDateTime();
    final firstDayOfYearJalali = Jalali.fromDateTime(firstDayOfYear);
    
    final dayOfYear = jalali.dayOfYear;
    final firstDayWeekday = firstDayOfYearJalali.weekDay;
    
    return ((dayOfYear - 1 + firstDayWeekday) ~/ 7) + 1;
  }

  // Get Jalali month name
  static String getJalaliMonthName(int month, {bool shortForm = false}) {
    return _getMonthName(month, shortForm);
  }

  // Check if Jalali year is leap year
  static bool isLeapYear(int jalaliYear) {
    final jalali = Jalali(jalaliYear, 1, 1);
    return jalali.isLeapYear;
  }

  // Get number of days in Jalali month
  static int getDaysInMonth(int jalaliYear, int jalaliMonth) {
    if (jalaliMonth < 1 || jalaliMonth > 12) {
      throw ArgumentError('Invalid month: $jalaliMonth');
    }

    if (jalaliMonth <= 6) {
      return 31;
    } else if (jalaliMonth <= 11) {
      return 30;
    } else {
      // Month 12 (Esfand)
      return isLeapYear(jalaliYear) ? 30 : 29;
    }
  }

  // Get difference between two Jalali dates in days
  static int daysBetween(DateTime date1, DateTime date2) {
    final jalali1 = Jalali.fromDateTime(date1);
    final jalali2 = Jalali.fromDateTime(date2);
    
    return jalali2.toDateTime().difference(jalali1.toDateTime()).inDays;
  }

  // Helper: Get Jalali month name
  static String _getMonthName(int month, bool shortForm) {
    const monthNames = [
      'فروردین', // Farvardin
      'اردیبهشت', // Ordibehesht
      'خرداد', // Khordad
      'تیر', // Tir
      'مرداد', // Mordad
      'شهریور', // Shahrivar
      'مهر', // Mehr
      'آبان', // Aban
      'آذر', // Azar
      'دی', // Dey
      'بهمن', // Bahman
      'اسفند', // Esfand
    ];

    const shortMonthNames = [
      'فروردین',
      'اردی',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];

    if (month < 1 || month > 12) {
      throw ArgumentError('Invalid month: $month');
    }

    return shortForm ? shortMonthNames[month - 1] : monthNames[month - 1];
  }
}
