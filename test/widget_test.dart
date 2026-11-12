import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calley_app/models/user_model.dart';
import 'package:calley_app/models/call_list_model.dart';
import 'package:calley_app/services/api_service.dart';
import 'package:calley_app/screens/language_selection_screen.dart';
import 'package:calley_app/screens/register_screen.dart';
import 'package:calley_app/screens/otp_verification_screen.dart';
import 'package:calley_app/screens/login_screen.dart';
import 'package:calley_app/screens/forgot_password_screen.dart';
import 'package:calley_app/screens/email_verification_screen.dart';
import 'package:calley_app/screens/dashboard_screen.dart';
import 'package:calley_app/screens/analytics_screen.dart';
import 'package:calley_app/screens/list_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:calley_app/providers/auth_provider.dart';
import 'package:calley_app/providers/list_provider.dart';

Widget createTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ListProvider()),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        '/register': (_) => const RegisterScreen(),
        '/otp': (_) => const OtpVerificationScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/email-verification': (_) => const EmailVerificationScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/analytics': (_) => const AnalyticsScreen(),
        '/list-detail': (_) => const ListDetailScreen(),
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model Serialization Tests', () {
    test('User model parses JSON correctly', () {
      final json = {
        'id': '68626f9497757cb741f449b0',
        'name': 'Swati S',
        'email': 'swati@getcalley.com',
        'phone': '+91 977119044',
        'token': 'mock_jwt_token',
        'parentAccountId': '#977119044',
        'subscription': 'Calley Personal',
      };
      final user = User.fromJson(json);
      expect(user.id, '68626f9497757cb741f449b0');
      expect(user.name, 'Swati S');
      expect(user.email, 'swati@getcalley.com');
      expect(user.subscription, 'Calley Personal');
      expect(user.toJson()['parentAccountId'], '#977119044');
    });

    test('CallList and Contact models calculate stats correctly', () {
      final list = CallList(
        id: '68626fb697757cb741f449b9',
        userId: '68626f9497757cb741f449b0',
        name: 'Test List',
        description: 'Calling Test batch',
        totalContacts: 50,
        calledContacts: 22,
        pendingContacts: 28,
        scheduledContacts: 9,
        status: 'active',
        createdAt: DateTime.now(),
        contacts: [
          Contact(
            id: 'c1',
            name: 'Sarah Jenkins',
            phone: '+91 98765 43210',
            status: 'pending',
          ),
          Contact(
            id: 'c2',
            name: 'Rajesh Sharma',
            phone: '+91 97711 90441',
            status: 'done',
          ),
        ],
      );

      expect(list.totalContacts, 50);
      expect(list.completionPercentage, 44.0);
      expect(list.contacts?.length, 2);
    });
  });

  group('REST API Service Tests', () {
    final apiService = ApiService();

    test('register API fallback returns success and token', () async {
      final res = await apiService.register(
        name: 'Swati S',
        email: 'swati@getcalley.com',
        password: 'password123',
        phone: '7078398822',
      );
      expect(res.success, true);
      expect(res.token, isNotNull);
    });

    test('login API fallback returns user with matching email', () async {
      final user = await apiService.login(
        email: 'swati@getcalley.com',
        password: 'password123',
      );
      expect(user.email, 'swati@getcalley.com');
      expect(user.subscription, 'Calley Personal');
    });

    test('getLists API returns Test List for specified userId', () async {
      final lists = await apiService.getLists(userId: '68626f9497757cb741f449b0');
      expect(lists.isNotEmpty, true);
      expect(lists.first.name, 'Test List');
      expect(lists.first.totalContacts, 50);
    });

    test('getListDetail API returns contacts for 68626fb697757cb741f449b9', () async {
      final detail = await apiService.getListDetail(listId: '68626fb697757cb741f449b9');
      expect(detail.id, '68626fb697757cb741f449b9');
      expect(detail.contacts, isNotNull);
      expect(detail.contacts!.isNotEmpty, true);
    });
    test('sendOtp and verifyOtp API support email login', () async {
      final otp = await apiService.sendOtp(email: 'swati@getcalley.com');
      expect(otp, isNotEmpty);
      final verified = await apiService.verifyOtp(email: 'swati@getcalley.com', otp: otp);
      expect(verified, true);
    });
  });

  group('Widget UI Screen Tests', () {
    testWidgets('LanguageSelectionScreen displays languages and Select CTA', (tester) async {
      await tester.pumpWidget(createTestApp(const LanguageSelectionScreen()));
      expect(find.text('Choose Your Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Hindi'), findsOneWidget);
      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('RegisterScreen displays logo, form fields, and Sign Up', (tester) async {
      await tester.pumpWidget(createTestApp(const RegisterScreen()));
      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Please register to continue'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen displays OTP prompt and Verify button', (tester) async {
      await tester.pumpWidget(createTestApp(const OtpVerificationScreen(
        email: 'swati@getcalley.com',
      )));
      expect(find.textContaining('Verify'), findsOneWidget);
      expect(find.textContaining('Email OTP'), findsOneWidget);
      expect(find.text('swati@getcalley.com'), findsOneWidget);
    });

    testWidgets('LoginScreen displays Email OTP tab and Send OTP button', (tester) async {
      await tester.pumpWidget(createTestApp(const LoginScreen()));
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email OTP'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Send OTP to Email'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen displays email input and Send Reset Link button', (tester) async {
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));
      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('EmailVerificationScreen displays verification prompt and action buttons', (tester) async {
      await tester.pumpWidget(createTestApp(const EmailVerificationScreen(
        email: 'swati@getcalley.com',
      )));
      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('swati@getcalley.com'), findsOneWidget);
      expect(find.text('I Have Verified'), findsOneWidget);
    });

    testWidgets('DashboardScreen displays header and Web Panel action card', (tester) async {
      await tester.pumpWidget(createTestApp(const DashboardScreen()));
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('LOAD NUMBER TO CALL'), findsOneWidget);
      expect(find.text('Start Calling Now'), findsOneWidget);
    });

    testWidgets('AnalyticsScreen displays Donut Chart breakdown and badges', (tester) async {
      await tester.pumpWidget(createTestApp(const AnalyticsScreen()));
      expect(find.text('TEST LIMIT'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
    });
  });
}
