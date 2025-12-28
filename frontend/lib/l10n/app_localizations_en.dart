// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zarbin';

  @override
  String get welcomeMessage => 'Welcome to Zarbin';

  @override
  String get appSubtitle =>
      'AI-powered financial advisor for high-inflation economies';

  @override
  String get viewMarketRates => 'View Market Rates';

  @override
  String get signIn => 'Sign In';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createAccount => 'Create Your Account';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get agreeToTerms => 'I agree to Terms and Conditions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get enterAmountInToman => 'Enter amount in Toman';

  @override
  String get date => 'Date';

  @override
  String get selectDate => 'Select a date';

  @override
  String get notes => 'Notes';

  @override
  String get optionalNotes => 'Optional notes about this transaction';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get amountExceedsMaximum => 'Amount exceeds maximum (99,999,999,999)';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get transactionCreatedSuccessfully =>
      'Transaction created successfully';

  @override
  String get failedToCreateTransaction => 'Failed to create transaction';
}
