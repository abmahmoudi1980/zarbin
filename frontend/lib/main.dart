import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/analytics_service.dart';
import 'services/api_client.dart';
import 'services/secure_storage.dart';
import 'services/database_service.dart';
import 'providers/auth_provider.dart';
import 'providers/market_rate_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/market_rates_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  final apiClient = ApiClient();
  final secureStorage = SecureStorage();

  // Initialize Firebase (skip for web until configured)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();

      // Configure Crashlytics
      // Pass all uncaught errors from the framework to Crashlytics.
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Initialize Analytics Service
      await AnalyticsService().init();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      // Continue app execution even if Firebase fails (e.g. missing config files in dev)
    }
  } else {
    debugPrint('Running on web - Firebase initialization skipped');
  }

  // Initialize Jalali date formatting for Persian locale
  await initializeDateFormatting('fa', null);

  // Initialize Database Service (skip for web - sqflite not supported)
  if (!kIsWeb) {
    try {
      await DatabaseService.database;
    } catch (e) {
      debugPrint('Database initialization failed: $e');
    }
  }

  // Create Providers
  final authProvider = AuthProvider(
    apiClient: apiClient,
    secureStorage: secureStorage,
  );

  final marketRateProvider = MarketRateProvider(
    apiClient: apiClient,
  );

  final dashboardProvider = DashboardProvider(
    apiClient: apiClient,
  );

  final transactionProvider = TransactionProvider(
    apiClient: apiClient,
    databaseService: DatabaseService(),
  );

  // Restore session if token exists
  await authProvider.restoreSession();

  runApp(ZarbinApp(
    authProvider: authProvider,
    marketRateProvider: marketRateProvider,
    dashboardProvider: dashboardProvider,
    transactionProvider: transactionProvider,
  ));
}

class ZarbinApp extends StatelessWidget {
  final AuthProvider authProvider;
  final MarketRateProvider marketRateProvider;
  final DashboardProvider dashboardProvider;
  final TransactionProvider transactionProvider;

  const ZarbinApp({
    Key? key,
    required this.authProvider,
    required this.marketRateProvider,
    required this.dashboardProvider,
    required this.transactionProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: marketRateProvider),
        ChangeNotifierProvider.value(value: dashboardProvider),
        ChangeNotifierProvider.value(value: transactionProvider),
      ],
      child: MaterialApp(
        title: 'Zarbin - Financial Advisor',
      debugShowCheckedModeBanner: false,

      // Analytics Observer
      navigatorObservers: [
        if (AnalyticsService().getAnalyticsObserver() != null)
          AnalyticsService().getAnalyticsObserver()!,
      ],

      // Localization for Persian language
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fa', 'IR'), // Default to Persian

      // Theme
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,

      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/rates': (context) => const MarketRatesScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
      },
    ),);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo or Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.appSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/rates'),
                    icon: const Icon(Icons.trending_up_rounded),
                    label: Text(
                      l10n.viewMarketRates,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    icon: const Icon(Icons.login_rounded),
                    label: Text(
                      l10n.signIn,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
