import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/calley_button.dart';
import '../widgets/calley_logo.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;

  const EmailVerificationScreen({super.key, this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _resendCountdown = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  Future<void> _handleCheckVerification() async {
    setState(() => _isChecking = true);
    final authProvider = context.read<AuthProvider>();
    final isVerified = await authProvider.isEmailVerified();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (isVerified) {
      _showMessage('Email verified successfully! Welcome to Calley.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/landing',
        (route) => false,
      );
    } else {
      _showMessage(
        'Your email is not verified yet. Please check your inbox and tap the link in the email from Firebase.',
        error: true,
      );
    }
  }

  Future<void> _handleResendVerification() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendEmailVerification();

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      _startTimer();
      _showMessage('A new verification email has been sent to your inbox.');
    } else {
      _showMessage(
        authProvider.errorMessage ?? 'Could not resend verification email.',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayEmail = widget.email ??
        context.watch<AuthProvider>().user?.email ??
        'your email';

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Hero(tag: 'app_logo', child: CalleyLogo(height: 38)),
              const SizedBox(height: 28),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 38,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A verification link has been sent to:',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  displayEmail,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Click the link in the verification email to activate your Calley account, then return here and tap "I Have Verified".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),
              CalleyButton(
                text: 'I Have Verified',
                isLoading: _isChecking,
                onPressed: _handleCheckVerification,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed:
                    _resendCountdown == 0 && !_isResending
                        ? _handleResendVerification
                        : null,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  _resendCountdown > 0
                      ? 'Resend Email (${_resendCountdown}s)'
                      : 'Resend Verification Email',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/landing',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Skip for now & Continue to App',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
