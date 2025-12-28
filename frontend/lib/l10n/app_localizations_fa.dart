// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'زربین';

  @override
  String get welcomeMessage => 'به زربین خوش آمدید';

  @override
  String get appSubtitle => 'مشاور مالی هوشمند برای اقتصادهای با تورم بالا';

  @override
  String get viewMarketRates => 'مشاهده نرخ‌های بازار';

  @override
  String get signIn => 'ورود به حساب';

  @override
  String get mobileNumber => 'شماره موبایل';

  @override
  String get password => 'رمز عبور';

  @override
  String get login => 'ورود';

  @override
  String get register => 'ثبت‌نام';

  @override
  String get dontHaveAccount => 'حساب کاربری ندارید؟ ';

  @override
  String get alreadyHaveAccount => 'قبلاً ثبت‌نام کرده‌اید؟ ';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get createAccount => 'ایجاد حساب کاربری';

  @override
  String get confirmPassword => 'تکرار رمز عبور';

  @override
  String get agreeToTerms => 'با شرایط و قوانین موافقم';

  @override
  String get addTransaction => 'افزودن تراکنش';

  @override
  String get amount => 'مبلغ';

  @override
  String get enterAmountInToman => 'مبلغ را به تومان وارد کنید';

  @override
  String get date => 'تاریخ';

  @override
  String get selectDate => 'تاریخی انتخاب کنید';

  @override
  String get notes => 'یادداشت‌ها';

  @override
  String get optionalNotes => 'یادداشت‌های اختیاری درباره این تراکنش';

  @override
  String get saveTransaction => 'ذخیره تراکنش';

  @override
  String get amountMustBeGreaterThanZero => 'مبلغ باید بیشتر از صفر باشد';

  @override
  String get amountExceedsMaximum => 'مبلغ بیش از حداکثر (۹۹,۹۹۹,۹۹۹,۹۹۹) است';

  @override
  String get pleaseSelectCategory => 'لطفاً یک دسته انتخاب کنید';

  @override
  String get pleaseSelectDate => 'لطفاً تاریخ را انتخاب کنید';

  @override
  String get transactionCreatedSuccessfully => 'تراکنش با موفقیت ایجاد شد';

  @override
  String get failedToCreateTransaction => 'ایجاد تراکنش ناموفق بود';
}
