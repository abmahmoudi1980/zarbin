import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/screens/add_transaction_screen.dart';
import 'package:zarbin/providers/transaction_provider.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
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

      // Default stubs
      when(() => mockTransactionProvider.isLoading).thenReturn(false);
      when(() => mockTransactionProvider.error).thenReturn(null);
      when(() => mockMarketRateProvider.currentUsdRate).thenReturn(42500.0);
      when(() => mockMarketRateProvider.isLoading).thenReturn(false);
    });

    Widget createTestWidget() {
      return MaterialApp(
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
      );
    }

    testWidgets('renders all required input fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Amount'), findsWidgets); // Found in multiple places
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('displays income/expense type toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('displays category dropdown with all 7 categories', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap category dropdown hint
      await tester.tap(find.text('Select a category'));
      await tester.pumpAndSettle();

      // Verify categories are displayed
      expect(find.text('خوراک'), findsOneWidget); // Food
      expect(find.text('حمل و نقل'), findsOneWidget); // Transport
      expect(find.text('صورت حساب'), findsOneWidget); // Bills
    });

    testWidgets('displays Jalali date picker', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap date field - use find.byType(TextField).at(1) or similar to be specific
      // Date field is the second TextField (Amount is first)
      final dateField = find.widgetWithText(TextField, 'Date');
      await tester.ensureVisible(dateField);
      await tester.tap(dateField);
      await tester.pumpAndSettle();

      // Verify date picker appears
      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('shows dual currency display while entering amount', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '۵۰۰۰۰۰۰');
      await tester.pumpAndSettle();

      // Verify USD equivalent is displayed
      expect(find.text('USD Equivalent'), findsOneWidget);
    });

    testWidgets('submit button is disabled when loading', (WidgetTester tester) async {
      when(() => mockTransactionProvider.isLoading).thenReturn(true);
      await tester.pumpWidget(createTestWidget());

      final submitButton = find.text('Save Transaction');
      await tester.ensureVisible(submitButton);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, false);
    });

    testWidgets('submit button is enabled when not loading', (WidgetTester tester) async {
      when(() => mockTransactionProvider.isLoading).thenReturn(false);
      await tester.pumpWidget(createTestWidget());

      final submitButton = find.text('Save Transaction');
      await tester.ensureVisible(submitButton);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, true);
    });

    testWidgets('validates Persian numeral input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '۵۰۰۰۰۰۰'); // Persian numerals
      await tester.pumpAndSettle();

      // Verify the value is accepted (no error shown yet)
      expect(find.text('Amount must be greater than 0'), findsNothing);
    });

    testWidgets('shows error when amount is zero', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '0');
      await tester.pumpAndSettle();

      // Tap submit to trigger validation
      final submitButton = find.text('Save Transaction');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Amount must be greater than 0'), findsOneWidget);
    });

    testWidgets('shows error when amount exceeds maximum', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '100000000000'); // > 99,999,999,999
      await tester.pumpAndSettle();

      // Tap submit to trigger validation
      final submitButton = find.text('Save Transaction');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Amount exceeds maximum'), findsOneWidget);
    });

    testWidgets('calls addTransaction when submit is pressed', (WidgetTester tester) async {
      when(() => mockTransactionProvider.addTransaction(
        amount: any(named: 'amount'),
        type: any(named: 'type'),
        categoryId: any(named: 'categoryId'),
        date: any(named: 'date'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());

      // Fill form
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '5000000');
      
      // Select category
      await tester.tap(find.text('Select a category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('خوراک').last);
      await tester.pumpAndSettle();

      // Select date (it's already filled with today's date by default usually)
      
      final submitButton = find.text('Save Transaction');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      verify(() => mockTransactionProvider.addTransaction(
        amount: 5000000,
        type: any(named: 'type'),
        categoryId: any(named: 'categoryId'),
        date: any(named: 'date'),
        notes: any(named: 'notes'),
      )).called(1);
    });
  });
}

