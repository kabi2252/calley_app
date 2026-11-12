
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/list_provider.dart';

import 'screens/analytics_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/dialer_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/landing_video_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/list_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/profile_settings_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

import 'utils/constants.dart';
import 'utils/page_transitions.dart';

// SSL override for mock test environments only.
// Do not use certificate bypass in production.
class CalleyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase exactly once.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    '[Firebase] Initialized: '
        '${DefaultFirebaseOptions.currentPlatform.projectId}',
  );

  // Set preferred screen orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CalleyApp());
}

class CalleyApp extends StatelessWidget {
  const CalleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListProvider()),
      ],
      child: MaterialApp(
        title: 'Calley - Automatic Call Dialer',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/splash',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentOrange,
        surface: AppColors.cardBg,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      useMaterial3: true,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return FadeRoute(page: const SplashScreen());

      case '/language':
        return FadeRoute(page: const LanguageSelectionScreen());

      case '/register':
        return SlideRightRoute(page: const RegisterScreen());

      case '/otp':
        final args = settings.arguments as Map<String, dynamic>?;
        final phone = args?['phoneNumber'] as String?;
        final email = args?['email'] as String?;
        final isLogin = args?['isLogin'] as bool? ?? false;
        final initialOtp = args?['otp'] as String?;

        return SlideRightRoute(
          page: OtpVerificationScreen(
            phoneNumber: phone,
            email: email,
            isLogin: isLogin,
            initialOtp: initialOtp,
          ),
        );

      case '/login':
      case '/signin':
        return FadeRoute(page: const LoginScreen());

      case '/forgot-password':
        final args = settings.arguments as Map<String, dynamic>?;
        final initialEmail = args?['email'] as String?;
        return SlideRightRoute(
          page: ForgotPasswordScreen(initialEmail: initialEmail),
        );

      case '/email-verification':
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String?;
        return SlideRightRoute(
          page: EmailVerificationScreen(email: email),
        );

      case '/landing':
        return SlideRightRoute(
          page: const LandingVideoScreen(),
        );

      case '/dashboard':
      case '/home':
        return SlideRightRoute(
          page: const DashboardScreen(),
        );

      case '/profile-settings':
        return SlideUpRoute(
          page: const ProfileSettingsScreen(),
        );

      case '/analytics':
        return SlideRightRoute(
          page: const AnalyticsScreen(),
        );

      case '/list-detail':
        final args = settings.arguments as Map<String, dynamic>?;
        final listId =
            args?['listId'] as String? ?? '68626fb697757cb741f449b9';

        return SlideRightRoute(
          page: ListDetailScreen(listId: listId),
        );

      case '/dialer':
        return SlideUpRoute(
          page: const DialerScreen(),
        );

      default:
        return FadeRoute(
          page: const SplashScreen(),
        );
    }
  }
}
