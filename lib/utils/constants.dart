import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// API Configuration
// =============================================================================

const String baseUrl = 'https://mock-api.calleyacd.com/api';

// API Endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // Lists
  static const String lists = '/lists';
  static const String createList = '/lists/create';
  static const String deleteList = '/lists/delete';
  static const String listDetail = '/lists/detail';
  static const String importContacts = '/lists/import';

  // Contacts
  static const String contacts = '/contacts';
  static const String addContact = '/contacts/add';
  static const String updateContact = '/contacts/update';
  static const String deleteContact = '/contacts/delete';

  // Calls
  static const String callHistory = '/calls/history';
  static const String startCall = '/calls/start';
  static const String endCall = '/calls/end';
  static const String callStats = '/calls/stats';

  // Analytics
  static const String analytics = '/analytics';
  static const String analyticsDaily = '/analytics/daily';
  static const String analyticsWeekly = '/analytics/weekly';
  static const String analyticsMonthly = '/analytics/monthly';
}

// =============================================================================
// Colors
// =============================================================================

class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color darkBg = Color(0xFF1A237E);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  static const Color red = Color(0xFFD32F2F);
  static const Color green = Color(0xFF388E3C);

  static const Color scaffoldBg = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

// =============================================================================
// Text Styles
// =============================================================================

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}

// =============================================================================
// Dimensions & Padding
// =============================================================================

class AppDimens {
  AppDimens._();

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}
