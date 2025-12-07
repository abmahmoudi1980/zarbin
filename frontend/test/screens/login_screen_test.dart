import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/screens/login_screen.dart';
import 'package:zarbin/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  group('LoginScreen', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    testWidgets('renders all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('submit button is disabled when form is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final loginButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(loginButton).enabled, false);
    });

    testWidgets('enables submit button when form is valid', (WidgetTester tester) async {
      when(() => mockAuthProvider.loginUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      final passwordTF = find.byType(TextField).at(1);

      await tester.enterText(mobileTF, '09123456789');
      await tester.enterText(passwordTF, 'Password123');
      await tester.pumpAndSettle();

      final loginButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(loginButton).enabled, true);
    });

    testWidgets('shows error for invalid mobile number', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      await tester.enterText(mobileTF, '123');
      await tester.pumpAndSettle();

      expect(find.text('Invalid mobile number'), findsOneWidget);
    });

    testWidgets('shows error for empty password', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final passwordTF = find.byType(TextField).at(1);
      await tester.enterText(passwordTF, '');
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('calls loginUser on button press', (WidgetTester tester) async {
      when(() => mockAuthProvider.loginUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      final passwordTF = find.byType(TextField).at(1);

      await tester.enterText(mobileTF, '09123456789');
      await tester.enterText(passwordTF, 'Password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockAuthProvider.loginUser(
        mobileNumber: '09123456789',
        password: 'Password123',
      )).called(1);
    });

    testWidgets('shows loading indicator during login', (WidgetTester tester) async {
      when(() => mockAuthProvider.isLoading).thenReturn(true);
      when(() => mockAuthProvider.loginUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on login failure', (WidgetTester tester) async {
      when(() => mockAuthProvider.loginUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => false);

      when(() => mockAuthProvider.error).thenReturn('Invalid credentials');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      final passwordTF = find.byType(TextField).at(1);

      await tester.enterText(mobileTF, '09123456789');
      await tester.enterText(passwordTF, 'WrongPassword');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('shows account locked error', (WidgetTester tester) async {
      when(() => mockAuthProvider.loginUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => false);

      when(() => mockAuthProvider.error).thenReturn(
        'Account is locked. Try again in 15 minutes.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      final passwordTF = find.byType(TextField).at(1);

      await tester.enterText(mobileTF, '09123456789');
      await tester.enterText(passwordTF, 'Password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Account is locked. Try again in 15 minutes.'), findsOneWidget);
    });

    testWidgets('displays password visibility toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      final visibilityIcon = find.byIcon(Icons.visibility).first;
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('has link to register screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });

    testWidgets('displays forgot password link', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Forgot Password?'), findsOneWidget);
    });
  });
}
