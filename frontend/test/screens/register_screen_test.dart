import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/screens/register_screen.dart';
import 'package:zarbin/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  group('RegisterScreen', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    testWidgets('renders all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays password confirmation field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('submit button is disabled when form is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final registerButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(registerButton).enabled, false);
    });

    testWidgets('enables submit button when form is valid', (WidgetTester tester) async {
      when(() => mockAuthProvider.registerUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      final passwordTF = find.byType(TextField).at(1);
      final confirmPasswordTF = find.byType(TextField).at(2);

      await tester.enterText(mobileTF, '09123456789');
      await tester.enterText(passwordTF, 'Password123');
      await tester.enterText(confirmPasswordTF, 'Password123');
      await tester.pumpAndSettle();

      final registerButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(registerButton).enabled, true);
    });

    testWidgets('shows error for invalid mobile number', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      await tester.enterText(mobileTF, '123');
      await tester.pumpAndSettle();

      expect(find.text('Invalid mobile number'), findsOneWidget);
    });

    testWidgets('shows error for weak password', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final passwordTF = find.byType(TextField).at(1);
      await tester.enterText(passwordTF, 'weak');
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters and contain a number'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final passwordTF = find.byType(TextField).at(1);
      final confirmPasswordTF = find.byType(TextField).at(2);

      await tester.enterText(passwordTF, 'Password123');
      await tester.enterText(confirmPasswordTF, 'Password124');
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('calls registerUser on button press', (WidgetTester tester) async {
      when(() => mockAuthProvider.registerUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final mobileTF = find.byType(TextField).at(0);
      final passwordTF = find.byType(TextField).at(1);
      final confirmPasswordTF = find.byType(TextField).at(2);

      await tester.enterText(mobileTF, '09123456789');
      await tester.enterText(passwordTF, 'Password123');
      await tester.enterText(confirmPasswordTF, 'Password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockAuthProvider.registerUser(
        mobileNumber: '09123456789',
        password: 'Password123',
      )).called(1);
    });

    testWidgets('shows loading indicator during registration', (WidgetTester tester) async {
      when(() => mockAuthProvider.isLoading).thenReturn(true);
      when(() => mockAuthProvider.registerUser(
        mobileNumber: any(named: 'mobileNumber'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays terms and conditions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.text('I agree to Terms and Conditions'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('has link to login screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.text('Already have an account? Login'), findsOneWidget);
    });
  });
}
