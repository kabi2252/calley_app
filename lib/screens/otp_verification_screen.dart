import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/calley_button.dart';
import '../widgets/calley_logo.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? email;
  final bool isLogin;
  final String? initialOtp;
  final String? verificationId;
  final int? resendToken;

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
    this.email,
    this.isLogin = false,
    this.initialOtp,
    this.verificationId,
    this.resendToken,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  bool _isVerifying = false;
  int _resendCountdown = 30;
  Timer? _timer;
  String? _verificationId;
  int? _resendToken;
  String? _receivedOtp;

  bool get _isPhoneFlow =>
      widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _receivedOtp = widget.email != null ? widget.initialOtp : null;
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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _autoFillEmailOtp() {
    final code = _receivedOtp;
    if (code == null) return;
    for (int i = 0; i < 6 && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    _focusNodes[5].requestFocus();
    setState(() {});
  }

  Future<void> _handleVerify() async {
    final code = _otpCode;
    if (code.length != 6) {
      _showMessage('Please enter the complete 6-digit OTP code.', error: true);
      return;
    }

    setState(() => _isVerifying = true);
    final authProvider = context.read<AuthProvider>();

    try {
      bool success;

      if (_isPhoneFlow) {
        final id = _verificationId;
        if (id == null || id.isEmpty) {
          throw Exception(
            'Verification session expired. Please request a new OTP.',
          );
        }

        success = await authProvider.signInWithPhoneCredential(
          verificationId: id,
          smsCode: code,
          phoneNumber: widget.phoneNumber,
        );
      } else {
        // Calley REST API email OTP verification
        success = await authProvider.verifyOtp(
          phone: widget.phoneNumber,
          email: widget.email,
          otp: code,
          isLogin: widget.isLogin,
        );
      }

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (success) {
        _showMessage('OTP verified successfully!');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/landing',
          (route) => false,
        );
      } else {
        _showMessage(
          authProvider.errorMessage ??
              'Invalid verification code. Please try again.',
          error: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      _showMessage(FirebaseAuthService.getReadableErrorMessage(e), error: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      _showMessage(e.toString(), error: true);
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    if (_isPhoneFlow) {
      setState(() => _isVerifying = true);
      try {
        await _firebaseAuthService.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber!,
          resendToken: _resendToken,
          onCodeSent: (verificationId, token) {
            if (!mounted) return;
            setState(() {
              _verificationId = verificationId;
              _resendToken = token;
              _isVerifying = false;
            });
            _startTimer();
            _showMessage('A new SMS OTP has been sent.');
          },
          onVerificationFailed: (exception) {
            if (!mounted) return;
            setState(() => _isVerifying = false);
            _showMessage(
              FirebaseAuthService.getReadableErrorMessage(exception),
              error: true,
            );
          },
          onVerificationCompleted: (credential) async {
            try {
              await context.read<AuthProvider>().signInWithPhoneCredential(
                    verificationId: credential.verificationId ?? '',
                    smsCode: credential.smsCode ?? '',
                    phoneNumber: widget.phoneNumber,
                  );
              if (!mounted) return;
              setState(() => _isVerifying = false);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/landing',
                (route) => false,
              );
            } catch (e) {
              if (mounted) {
                setState(() => _isVerifying = false);
                _showMessage('Automatic verification failed: $e', error: true);
              }
            }
          },
          onCodeAutoRetrievalTimeout: (verificationId) {
            _verificationId = verificationId;
          },
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isVerifying = false);
          _showMessage('Could not resend OTP: $e', error: true);
        }
      }
    } else {
      try {
        final otp = await context.read<AuthProvider>().sendOtp(
              phone: widget.phoneNumber,
              email: widget.email,
            );
        if (!mounted) return;
        setState(() => _receivedOtp = otp);
        _startTimer();
        _showMessage('A new email OTP has been requested.');
      } catch (e) {
        _showMessage('Could not resend email OTP: $e', error: true);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.email != null && widget.email!.isNotEmpty;
    final target = isEmail ? widget.email! : (widget.phoneNumber ?? '');

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
              Text(
                isEmail ? 'Email OTP Verification' : 'Phone OTP Verification',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isEmail
                    ? 'Enter the 6-digit verification code sent to your email.'
                    : 'Enter the 6-digit SMS code sent to your phone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  target,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              if (isEmail && _receivedOtp != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Email OTP requested. Use the code delivered by your email/API.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _autoFillEmailOtp,
                        child: const Text('Fill'),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 44,
                    height: 52,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive OTP? ",
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                  GestureDetector(
                    onTap: _resendCountdown == 0 && !_isVerifying
                        ? _handleResend
                        : null,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend in (${_resendCountdown}s)'
                          : 'Resend OTP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _resendCountdown > 0
                            ? AppColors.textLight
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CalleyButton(
                text: 'Verify & Sign In',
                isLoading: _isVerifying,
                onPressed: _handleVerify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
