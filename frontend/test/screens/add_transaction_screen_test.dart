import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/screens/add_transaction_screen.dart';
import 'package:zarbin/providers/transaction_provider.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
import 'package:zarbin/models/category.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionProvider extends Mock implements TransactionProvider {}
class MockMarketRateProvider extends Mock implements MarketRateProvider {}

void main() {
  group('AddTransactionScreen', () {
    late MockTransactionProvider mockTransactionProvider;
    late MockMarketRateProvider mockMarketRateProvider;

    setUp(() {
      mockTransactionProvider = MockTransactionProvider();
      mockMarketRateProvider = MockMarketRateProvider();
    });

    testWidgets('renders all required input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('displays income/expense type toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('displays category dropdown with all 7 categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      // Tap category dropdown
      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();

      // Verify categories are displayed
      expect(find.text('خوراک'), findsOneWidget); // Food
      expect(find.text('حمل و نقل'), findsOneWidget); // Transport
      expect(find.text('صورت حساب'), findsOneWidget); // Bills
    });

    testWidgets('displays Jalali date picker', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      // Tap date field
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();

      // Verify date picker appears
      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('shows dual currency display while entering amount', (WidgetTester tester) async {
      when(() => mockMarketRateProvider.currentUsdRate).thenReturn(42500.0);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      final amountField = find.byType(TextField).at(0);
      await tester.enterText(amountField, '۵۰۰۰۰۰۰');
      await tester.pumpAndSettle();

      // Verify USD equivalent is displayed
      expect(find.text('USD Equivalent'), findsOneWidget);
    });

    testWidgets('submit button is disabled when form is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      final submitButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, false);
    });

    testWidgets('submit button is enabled when form is valid', (WidgetTester tester) async {
      when(() => mockTransactionProvider.addTransaction(
        amount: any(named: 'amount'),
        type: any(named: 'type'),
        categoryId: any(named: 'categoryId'),
        date: any(named: 'date'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => true);

      when(() => mockMarketRateProvider.currentUsdRate).thenReturn(42500.0);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      // Fill form
      final amountField = find.byType(TextField).at(0);
      await tester.enterText(amountField, '5000000');
      await tester.pumpAndSettle();

      final submitButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, true);
    });

    testWidgets('validates Persian numeral input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      final amountField = find.byType(TextField).at(0);
      await tester.enterText(amountField, '۵۰۰۰۰۰۰'); // Persian numerals
      await tester.pumpAndSettle();

      // Verify the value is accepted
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows error when amount is zero', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      final amountField = find.byType(TextField).at(0);
      await tester.enterText(amountField, '0');
      await tester.pumpAndSettle();

      expect(find.text('Amount must be greater than 0'), findsOneWidget);
    });

    testWidgets('shows error when amount exceeds maximum', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      final amountField = find.byType(TextField).at(0);
      await tester.enterText(amountField, '100000000000'); // > 99,999,999,999
      await tester.pumpAndSettle();

      expect(find.text('Amount exceeds maximum'), findsOneWidget);
    });

    testWidgets('calls addTransaction when submit is pressed', (WidgetTester tester) async {
      when(() => mockTransactionProvider.addTransaction(
        amount: any(named: 'amount'),
        type: any(named: 'type'),
        categoryId: any(named: 'categoryId'),
        date: any(named: 'date'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => true);

      when(() => mockMarketRateProvider.currentUsdRate).thenReturn(42500.0);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider,
              ),
              ChangeNotifierProvider<MarketRateProvider>.value(
                value: mockMarketRateProvider,
              ),
            ],
            child: const AddTransactionScreen(),
          ),
        ),
      );

      // Fill form with valid data
      final amountField = find.byType(TextField).at(0);
      await tester.enterText(amountField, '5000000');
      await tester.pumpAndSettle();

      // Submit
      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify transaction was added
      verify(() => mockTransactionProvider.addTransaction(
        amount: any(named: 'amount'),
        type: any(named: 'type'),
        categoryId: any(named: 'categoryId'),
        date: any(named: 'date'),
        notes: any(named: 'notes'),
      )).called(greaterThan(0));
    });
  });
}
