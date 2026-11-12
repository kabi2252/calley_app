import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/calley_button.dart';
import '../widgets/calley_logo.dart';
import '../widgets/calley_text_field.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailOtpFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _emailOtpController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  int _selectedTab = 0; // 0: Email OTP, 1: Phone OTP, 2: Password
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOtpController.dispose();
    _emailPasswordController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.errorRed : AppColors.primaryBlue,
      ),
    );
  }

  // ---------- Email OTP (Calley API) ----------
  Future<void> _handleSendEmailOtp() async {
    if (!_emailOtpFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailOtpController.text.trim();
      final otp = await context.read<AuthProvider>().sendOtp(email: email);
      if (!mounted) return;
      setState(() => _isLoading = false);

      _showMessage('Email OTP requested. Check your inbox.');
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'email': email, 'isLogin': true, 'otp': otp},
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showMessage('Could not send email OTP: $e', error: true);
    }
  }

  // ---------- Phone OTP (Firebase) ----------
  Future<void> _handleSendPhoneOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final entered = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final digits = entered.replaceAll(RegExp(r'\D'), '');
    final phoneNumber = entered.startsWith('+')
        ? '+$digits'
        : (digits.length == 12 && digits.startsWith('91')
            ? '+$digits'
            : '+91$digits');

    setState(() => _isLoading = true);

    try {
      await _firebaseAuthService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: phoneNumber,
                isLogin: true,
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            ),
          );
        },
        onVerificationFailed: (FirebaseAuthException exception) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showMessage(
            FirebaseAuthService.getReadableErrorMessage(exception),
            error: true,
          );
        },
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await context.read<AuthProvider>().signInWithPhoneCredential(
                  verificationId: credential.verificationId ?? '',
                  smsCode: credential.smsCode ?? '',
                  phoneNumber: phoneNumber,
                );
            if (!mounted) return;
            setState(() => _isLoading = false);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/landing',
              (route) => false,
            );
          } catch (e) {
            if (mounted) {
              setState(() => _isLoading = false);
              _showMessage('Automatic phone verification failed: $e', error: true);
            }
          }
        },
        onCodeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showMessage('Could not send SMS OTP: $e', error: true);
      }
    }
  }

  // ---------- Google Sign-In ----------
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/landing',
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      _showMessage(authProvider.errorMessage!, error: true);
    }
  }

  // ---------- Email & Password Sign-In ----------
  Future<void> _handlePasswordSignIn() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailPasswordController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/landing',
        (route) => false,
      );
    } else {
      _showMessage(
        authProvider.errorMessage ?? 'Sign in failed. Check email and password.',
        error: true,
      );
    }
  }

  Widget _tab(int index, String label, IconData icon) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 4,
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primaryBlue : AppColors.textLight,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primaryBlue : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Hero(tag: 'app_logo', child: CalleyLogo(height: 38)),
              const SizedBox(height: 24),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please sign in to continue to Calley',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),

              // Segmented Tab Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    _tab(0, 'Email OTP', Icons.mark_email_read_outlined),
                    _tab(1, 'Phone OTP', Icons.phone_android_rounded),
                    _tab(2, 'Password', Icons.lock_outline_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab 0: Email OTP
              if (_selectedTab == 0)
                Form(
                  key: _emailOtpFormKey,
                  child: Column(
                    children: [
                      CalleyTextField(
                        controller: _emailOtpController,
                        hintText: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'A 6-digit verification code will be sent to your email.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CalleyButton(
                        text: 'Send OTP to Email',
                        isLoading: _isLoading,
                        onPressed: _handleSendEmailOtp,
                      ),
                    ],
                  ),
                )
              // Tab 1: Phone OTP
              else if (_selectedTab == 1)
                Form(
                  key: _phoneFormKey,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(11),
                                ),
                                border: Border(
                                  right:
                                      BorderSide(color: AppColors.borderLight),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text('🇮🇳', style: TextStyle(fontSize: 15)),
                                  SizedBox(width: 4),
                                  Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: AppColors.textLight,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '10-digit mobile number',
                                  hintStyle: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 14),
                                  suffixIcon: Icon(
                                    Icons.phone_iphone_rounded,
                                    size: 18,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                validator: (value) {
                                  final digits = (value ?? '')
                                      .replaceAll(RegExp(r'\D'), '');
                                  if (digits.length != 10 &&
                                      digits.length != 12) {
                                    return 'Enter a valid 10-digit mobile number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Firebase will deliver a real 6-digit SMS verification code.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CalleyButton(
                        text: 'Send SMS OTP',
                        isLoading: _isLoading,
                        onPressed: _handleSendPhoneOtp,
                      ),
                    ],
                  ),
                )
              // Tab 2: Password
              else
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    children: [
                      CalleyTextField(
                        controller: _emailPasswordController,
                        hintText: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: Icons.email_outlined,
                        validator: (value) =>
                            value == null || !value.contains('@')
                                ? 'Enter a valid email address'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      CalleyTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: _obscurePassword,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixIconTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Enter password'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            final email =
                                _emailPasswordController.text.trim();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(
                                  initialEmail: email,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CalleyButton(
                        text: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _handlePasswordSignIn,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google 'G' icon
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
