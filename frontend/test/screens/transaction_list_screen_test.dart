import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/screens/transaction_list_screen.dart';
import 'package:zarbin/screens/add_transaction_screen.dart';
import 'package:zarbin/providers/transaction_provider.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
import 'package:zarbin/models/transaction.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionProvider extends Mock implements TransactionProvider {}
class MockMarketRateProvider extends Mock implements MarketRateProvider {}

void main() {
  group('TransactionListScreen', () {
    late MockTransactionProvider mockTransactionProvider;
    late MockMarketRateProvider mockMarketRateProvider;

    setUp(() {
      mockTransactionProvider = MockTransactionProvider();
      mockMarketRateProvider = MockMarketRateProvider();

      // Default stubs to prevent Null pointer exceptions
      when(() => mockTransactionProvider.isLoading).thenReturn(false);
      when(() => mockTransactionProvider.error).thenReturn(null);
      when(() => mockTransactionProvider.transactions).thenReturn([]);
      when(() => mockTransactionProvider.fetchTransactions())
          .thenAnswer((_) async {});

      when(() => mockMarketRateProvider.isLoading).thenReturn(false);
      when(() => mockMarketRateProvider.rates).thenReturn([]);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionProvider>.value(
            value: mockTransactionProvider,
          ),
          ChangeNotifierProvider<MarketRateProvider>.value(
            value: mockMarketRateProvider,
          ),
        ],
        child: const MaterialApp(
          home: TransactionListScreen(),
        ),
      );
    }

    testWidgets('displays empty state when no transactions', (WidgetTester tester) async {
      when(() => mockTransactionProvider.transactions).thenReturn([]);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.text('Start adding transactions to track your finances'), findsOneWidget);
    });

    testWidgets('displays list of transactions', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Grocery shopping',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
        Transaction(
          id: '2',
          userId: '1',
          amountToman: 10000000,
          transactionType: 'income',
          categoryId: '2',
          categoryName: 'درآمد',
          transactionDate: '1403/01/20',
          notes: 'Monthly salary',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('خوراک'), findsOneWidget);
      expect(find.text('درآمد'), findsOneWidget);
    });

    testWidgets('displays transaction details correctly', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Grocery shopping',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('-۵٬۰۰۰٬۰۰۰'), findsOneWidget); // Persian formatted amount with prefix
      expect(find.text('1403/01/15'), findsOneWidget);
      expect(find.text('Grocery shopping'), findsOneWidget);
    });

    testWidgets('displays transactions sorted by date (newest first)', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Old transaction',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Transaction(
          id: '2',
          userId: '1',
          amountToman: 10000000,
          transactionType: 'income',
          categoryId: '2',
          categoryName: 'درآمد',
          transactionDate: '1403/01/20',
          notes: 'Recent transaction',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions.reversed.toList());

      await tester.pumpWidget(createTestWidget());

      // Verify newer transaction appears first
      expect(find.text('Recent transaction'), findsOneWidget);
      final recentPos = tester.getTopLeft(find.text('Recent transaction'));
      final oldPos = tester.getTopLeft(find.text('Old transaction'));
      expect(recentPos.dy < oldPos.dy, true); // dy increases downwards, so smaller dy is higher
    });

    testWidgets('displays dual currency amounts', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Grocery',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions);

      await tester.pumpWidget(createTestWidget());

      // Verify both Toman and USD are shown
      expect(find.text('-۵٬۰۰۰٬۰۰۰'), findsOneWidget); // Toman in Persian
      expect(find.text('117.65 USD'), findsOneWidget); // USD equivalent
    });

    testWidgets('displays category icons', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Food',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions);

      await tester.pumpWidget(createTestWidget());

      // Verify category icons are rendered
      expect(find.byIcon(Icons.restaurant), findsWidgets);
    });

    testWidgets('distinguishes income and expense transactions', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Expense',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
        Transaction(
          id: '2',
          userId: '1',
          amountToman: 10000000,
          transactionType: 'income',
          categoryId: '2',
          categoryName: 'درآمد',
          transactionDate: '1403/01/20',
          notes: 'Income',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions);

      await tester.pumpWidget(createTestWidget());

      // Expense should be red/negative, Income should be green/positive
      final expenseWidget = find.text('-۵٬۰۰۰٬۰۰۰');
      final incomeWidget = find.text('+۱۰٬۰۰۰٬۰۰۰');

      expect(expenseWidget, findsOneWidget);
      expect(incomeWidget, findsOneWidget);
      
      final expenseText = tester.widget<Text>(expenseWidget);
      final incomeText = tester.widget<Text>(incomeWidget);
      
      expect(expenseText.style?.color, Colors.red);
      expect(incomeText.style?.color, Colors.green);
    });

    testWidgets('shows note preview in transaction list', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Grocery shopping at Hyperstar',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions);

      await tester.pumpWidget(createTestWidget());

      // Verify note is visible
      expect(find.text('Grocery shopping at Hyperstar'), findsOneWidget);
    });

    testWidgets('tapping transaction shows details or edit option', (WidgetTester tester) async {
      final mockTransactions = [
        Transaction(
          id: '1',
          userId: '1',
          amountToman: 5000000,
          transactionType: 'expense',
          categoryId: '1',
          categoryName: 'خوراک',
          transactionDate: '1403/01/15',
          notes: 'Grocery',
          usdRateAtCreation: 42500.0,
          goldRateAtCreation: 0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockTransactionProvider.transactions).thenReturn(mockTransactions);

      await tester.pumpWidget(createTestWidget());

      // Tap on transaction
      await tester.tap(find.text('Grocery'));
      await tester.pumpAndSettle();

      // Verify details or edit screen is shown
      expect(find.byType(BottomSheet), findsWidgets);
    });

    testWidgets('add button navigates to AddTransactionScreen', (WidgetTester tester) async {
      when(() => mockTransactionProvider.transactions).thenReturn([]);

      await tester.pumpWidget(createTestWidget());

      // Use find.byType(FloatingActionButton) to avoid ambiguity with other Icons.add
      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify navigation occurs
      expect(find.byType(AddTransactionScreen), findsOneWidget);
    });

    testWidgets('displays loading state while fetching transactions', (WidgetTester tester) async {
      when(() => mockTransactionProvider.isLoading).thenReturn(true);
      when(() => mockTransactionProvider.transactions).thenReturn([]);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message on load failure', (WidgetTester tester) async {
      when(() => mockTransactionProvider.error).thenReturn('Failed to load transactions');
      when(() => mockTransactionProvider.transactions).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TransactionProvider>.value(
            value: mockTransactionProvider,
            child: const TransactionListScreen(),
          ),
        ),
      );

      expect(find.text('Failed to load transactions'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
    });
  });
}
