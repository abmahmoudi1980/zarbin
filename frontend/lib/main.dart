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
import 'providers/auth_provider.dart';
import 'providers/market_rate_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/market_rates_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  final apiClient = ApiClient();
  final secureStorage = SecureStorage();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();

    // Configure Crashlytics
    if (!kIsWeb) {
      // Pass all uncaught errors from the framework to Crashlytics.
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Initialize Analytics Service
    await AnalyticsService().init();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue app execution even if Firebase fails (e.g. missing config files in dev)
  }

  // Initialize Jalali date formatting for Persian locale
  await initializeDateFormatting('fa', null);

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

  // Restore session if token exists
  await authProvider.restoreSession();

  runApp(ZarbinApp(
    authProvider: authProvider,
    marketRateProvider: marketRateProvider,
    dashboardProvider: dashboardProvider,
  ));
}

class ZarbinApp extends StatelessWidget {
  final AuthProvider authProvider;
  final MarketRateProvider marketRateProvider;
  final DashboardProvider dashboardProvider;

  const ZarbinApp({
    Key? key,
    required this.authProvider,
    required this.marketRateProvider,
    required this.dashboardProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: marketRateProvider),
        ChangeNotifierProvider.value(value: dashboardProvider),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.vazirmatnTextTheme(),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.vazirmatnTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),

      themeMode: ThemeMode.system,

      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/rates': (context) => const MarketRatesScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    ),);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.welcomeMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.appSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/rates');
              },
              child: Text(l10n.viewMarketRates),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
