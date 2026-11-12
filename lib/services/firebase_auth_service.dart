import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication Service for Calley App.
/// Handles Email/Password, Phone OTP, Google Sign-In, Password Reset, and Verification.
class FirebaseAuthService {
  // Web Client ID from google-services.json for OAuth token exchange
  static const String serverClientId =
      '275574460475-u2euhnjvt1c10ld6nc8elm51rrkor7b2.apps.googleusercontent.com';

  final FirebaseAuth? _authOverride;

  FirebaseAuthService({FirebaseAuth? authOverride})
      : _authOverride = authOverride;

  /// Safe accessor for [FirebaseAuth.instance] to prevent exceptions in test environments
  FirebaseAuth get auth {
    if (_authOverride != null) return _authOverride!;
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      throw StateError(
        'FirebaseAuth has not been initialized. Ensure Firebase.initializeApp() is called.',
      );
    }
  }

  /// Safe accessor for current Firebase user
  User? get currentUser {
    if (_authOverride != null) return _authOverride!.currentUser;
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Safe stream of Firebase authentication state changes
  Stream<User?> get authStateChanges {
    if (_authOverride != null) return _authOverride!.authStateChanges();
    try {
      return FirebaseAuth.instance.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Check whether a user is currently signed in to Firebase
  bool get isSignedIn => currentUser != null;

  // ==================== GOOGLE SIGN-IN ====================

  /// Sign in with Google using modern GoogleSignIn 7.x API and Firebase Credential
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize with backend server client ID for ID token issuance
      await GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
      );

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      debugPrint(
        '[FirebaseAuthService] Google sign-in successful: ${userCredential.user?.email}',
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('[FirebaseAuthService] Google Sign-In exception: $e');
      rethrow;
    }
  }

  // ==================== EMAIL & PASSWORD ====================

  /// Register a new account with email, password, and optional display name
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      // Automatically send email verification link upon registration
      try {
        await credential.user?.sendEmailVerification();
        debugPrint(
          '[FirebaseAuthService] Verification email sent to ${credential.user?.email}',
        );
      } catch (e) {
        debugPrint('[FirebaseAuthService] Email verification send note: $e');
      }

      return credential;
    } catch (e) {
      debugPrint('[FirebaseAuthService] Email registration error: $e');
      rethrow;
    }
  }

  /// Sign in with existing email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('[FirebaseAuthService] Email login error: $e');
      rethrow;
    }
  }

  /// Send password reset link to user email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('[FirebaseAuthService] Password reset sent to $email');
    } catch (e) {
      debugPrint('[FirebaseAuthService] Password reset error: $e');
      rethrow;
    }
  }

  /// Send email verification link to current authenticated user
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      debugPrint('[FirebaseAuthService] Verification email sent to ${user.email}');
    }
  }

  /// Check whether the current user's email has been verified
  Future<bool> isEmailVerified() async {
    final user = currentUser;
    if (user == null) return false;
    await user.reload();
    return currentUser?.emailVerified ?? false;
  }

  // ==================== PHONE OTP AUTHENTICATION ====================

  /// Initiate Phone OTP verification via Firebase
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException exception) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('[FirebaseAuthService] verifyPhoneNumber exception: $e');
      rethrow;
    }
  }

  /// Verify 6-digit SMS code using Firebase Phone Auth credential
  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      return await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('[FirebaseAuthService] Phone verification error: $e');
      rethrow;
    }
  }

  // ==================== CALLEY EMAIL OTP SYNC ====================

  /// Support Calley REST API Email OTP by ensuring user exists in Firebase Auth
  Future<UserCredential?> signInOrRegisterWithEmailOtp({
    required String email,
    String? displayName,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    final internalPassword =
        'CalleyOTP#Auth_${cleanEmail.hashCode.abs()}_!2026';

    try {
      return await auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: internalPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        final credential = await auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: internalPassword,
        );

        final name = displayName ??
            (cleanEmail.contains('@')
                ? cleanEmail.split('@').first
                : 'Calley User');

        await credential.user?.updateDisplayName(name);
        return credential;
      }
      rethrow;
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out completely from Firebase Auth and Google Sign-In
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      debugPrint('[FirebaseAuthService] FirebaseAuth sign-out notice: $e');
    }
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('[FirebaseAuthService] GoogleSignIn sign-out notice: $e');
    }
  }

  // ==================== ERROR CODES ====================

  /// Convert Firebase Authentication exception codes to user-friendly messages
  static String getReadableErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please check or register.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password or email. Please verify and try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment before trying again.';
      case 'operation-not-allowed':
        return 'This sign-in method is currently disabled in Firebase Console.';
      case 'invalid-verification-code':
        return 'Invalid 6-digit OTP code. Please enter the correct code.';
      case 'session-expired':
        return 'The OTP verification session has expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded for today. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication error occurred (${e.code}).';
    }
  }
}
