import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  StreamSubscription<fb.User?>? _authSubscription;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // ---------- Getters ----------

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated =>
      (_token != null && _token!.isNotEmpty) || _firebaseAuthService.isSignedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get lastGeneratedOtp => _apiService.lastGeneratedOtp;
  FirebaseAuthService get firebaseAuthService => _firebaseAuthService;
  fb.User? get firebaseUser => _firebaseAuthService.currentUser;
  bool get isFirebaseSignedIn => _firebaseAuthService.isSignedIn;

  AuthProvider() {
    _initUser();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authSubscription = _firebaseAuthService.authStateChanges.listen((fbUser) {
      if (fbUser != null && _user == null) {
        _user = User(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'Calley User',
          email: fbUser.email ?? 'user@getcalley.com',
          phone: fbUser.phoneNumber ?? '+91 977119044',
          token: _token ?? 'firebase_${fbUser.uid}',
          parentAccountId: '#977119044',
          subscription: 'Calley Personal',
        );
        notifyListeners();
      }
    });
  }

  Future<void> _initUser() async {
    await _storageService.init();
    _token = _storageService.getToken();
    _user = _storageService.getUserData();

    // Check if user is already authenticated in Firebase
    final currentFbUser = _firebaseAuthService.currentUser;
    if (currentFbUser != null) {
      debugPrint(
        '[AuthProvider] Firebase user already authenticated: ${currentFbUser.uid}',
      );
      _user = User(
        id: currentFbUser.uid,
        name: currentFbUser.displayName ?? (_user?.name ?? 'Swati S'),
        email: currentFbUser.email ?? (_user?.email ?? 'swati@getcalley.com'),
        phone: currentFbUser.phoneNumber ?? (_user?.phone ?? '+91 977119044'),
        token: _token ?? 'firebase_${currentFbUser.uid}',
        parentAccountId: '#977119044',
        subscription: 'Calley Personal',
      );
    } else if (_token != null && _token!.isNotEmpty) {
      _apiService.setAuthToken(_token!);
    } else {
      // Default initial mock profile matching Figma Swati S
      _user = User(
        id: ApiConstants.defaultUserId,
        name: 'Swati S',
        email: 'swati@getcalley.com',
        phone: '+91 977119044',
        parentAccountId: '#977119044',
        subscription: 'Calley Personal',
      );
    }
    notifyListeners();
  }

  // ---------- Auth Methods ----------

  /// Register a new user in Firebase Auth and sync with Calley REST API.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    fb.UserCredential? fbCredential;

    // 1. Firebase Authentication Registration
    try {
      fbCredential = await _firebaseAuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );
      debugPrint(
        '[AuthProvider] Firebase register successful for: ${fbCredential.user?.uid}',
      );
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('[AuthProvider] Firebase Auth notice: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        _setError('This email is already registered in Firebase.');
        _setLoading(false);
        return false;
      } else if (e.code == 'weak-password') {
        _setError('Password is too weak. Please use at least 6 characters.');
        _setLoading(false);
        return false;
      } else {
        _setError(FirebaseAuthService.getReadableErrorMessage(e));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('[AuthProvider] Firebase register exception: $e');
    }

    // 2. Calley Backend Mock REST API Sync
    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      final uid = fbCredential?.user?.uid ?? ApiConstants.defaultUserId;
      final authToken = response.token ?? 'fb_jwt_$uid';

      _user = User(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        token: authToken,
      );
      _token = authToken;

      _apiService.setAuthToken(authToken);
      await _storageService.saveToken(authToken);
      await _storageService.saveUserData(_user!);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Login with email and password using Firebase Auth and Calley REST API.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    fb.UserCredential? fbCredential;

    // 1. Firebase Authentication Sign-In
    try {
      fbCredential = await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
        '[AuthProvider] Firebase sign-in successful: ${fbCredential.user?.uid}',
      );
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('[AuthProvider] Firebase sign-in note: ${e.code} - ${e.message}');
      _setError(FirebaseAuthService.getReadableErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('[AuthProvider] Firebase sign-in exception: $e');
    }

    // 2. Calley Backend REST API Login Sync
    try {
      final user = await _apiService.login(
        email: email,
        password: password,
      );

      final uid = fbCredential?.user?.uid ?? user.id;
      final name = fbCredential?.user?.displayName ?? user.name;
      final liveUser = User(
        id: uid,
        name: name,
        email: email,
        phone: user.phone,
        token: user.token ?? 'fb_token_$uid',
        parentAccountId: user.parentAccountId,
        subscription: user.subscription,
      );

      _user = liveUser;
      _token = liveUser.token;

      _apiService.setAuthToken(_token!);
      await _storageService.saveToken(_token!);
      await _storageService.saveUserData(liveUser);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Google using Firebase Authentication
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _firebaseAuthService.signInWithGoogle();
      if (credential == null || credential.user == null) {
        _setLoading(false);
        return false; // User cancelled
      }

      final fbUser = credential.user!;
      final idToken = await fbUser.getIdToken() ?? 'google_${fbUser.uid}';

      final liveUser = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'Google User',
        email: fbUser.email ?? 'user@gmail.com',
        phone: fbUser.phoneNumber ?? '+91 977119044',
        token: idToken,
        parentAccountId: '#${fbUser.uid.substring(0, 8)}',
        subscription: 'Calley Personal',
      );

      _user = liveUser;
      _token = idToken;

      _apiService.setAuthToken(idToken);
      await _storageService.saveToken(idToken);
      await _storageService.saveUserData(liveUser);

      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setError(FirebaseAuthService.getReadableErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Google sign-in error: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Firebase Phone OTP credentials
  Future<bool> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _firebaseAuthService.signInWithPhoneCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final fbUser = credential.user;
      final phone = fbUser?.phoneNumber ?? phoneNumber ?? '+91 977119044';
      final uid = fbUser?.uid ?? 'phone_user_${DateTime.now().millisecondsSinceEpoch}';
      final token = await fbUser?.getIdToken() ?? 'phone_token_$uid';

      final liveUser = User(
        id: uid,
        name: fbUser?.displayName ?? 'Calley User',
        email: fbUser?.email ?? 'phone_${digitsOnly(phone)}@getcalley.com',
        phone: phone,
        token: token,
        parentAccountId: '#${digitsOnly(phone).substring(0, 8)}',
        subscription: 'Calley Personal',
      );

      _user = liveUser;
      _token = token;

      _apiService.setAuthToken(token);
      await _storageService.saveToken(token);
      await _storageService.saveUserData(liveUser);

      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setError(FirebaseAuthService.getReadableErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Phone verification error: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email via Firebase Authentication
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setError(FirebaseAuthService.getReadableErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error sending password reset: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Send email verification link
  Future<bool> sendEmailVerification() async {
    try {
      await _firebaseAuthService.sendEmailVerification();
      return true;
    } catch (e) {
      _setError('Error sending verification email: $e');
      return false;
    }
  }

  /// Check whether current user email is verified
  Future<bool> isEmailVerified() async {
    return await _firebaseAuthService.isEmailVerified();
  }

  /// Send OTP to Email or Phone (REST API + Firebase Phone Auth capability)
  Future<String> sendOtp({String? phone, String? email}) async {
    final otp = await _apiService.sendOtp(phone: phone, email: email);
    notifyListeners();
    return otp;
  }

  /// Verify OTP and establish user session with Firebase Auth and Calley REST API
  Future<bool> verifyOtp({
    String? phone,
    String? email,
    required String otp,
    bool isLogin = false,
  }) async {
    _setLoading(true);
    final verified =
        await _apiService.verifyOtp(phone: phone, email: email, otp: otp);

    if (verified && email != null && email.isNotEmpty) {
      final userName =
          email.contains('@') ? email.split('@').first : 'Calley User';
      final formattedName = userName.isNotEmpty
          ? '${userName[0].toUpperCase()}${userName.substring(1)}'
          : 'Calley User';

      // Authenticate in Firebase Authentication so user appears in Firebase Console
      String? fbUid;
      try {
        final fbCred =
            await _firebaseAuthService.signInOrRegisterWithEmailOtp(
          email: email,
          displayName: formattedName,
        );
        fbUid = fbCred?.user?.uid;
        debugPrint(
          '[AuthProvider] Email OTP user registered/signed-in on Firebase UID: $fbUid',
        );
      } catch (e) {
        debugPrint('[AuthProvider] Firebase Email OTP auth note: $e');
      }

      final activeUid = fbUid ??
          _firebaseAuthService.currentUser?.uid ??
          ApiConstants.defaultUserId;

      _user = User(
        id: activeUid,
        name: formattedName,
        email: email,
        phone: phone ?? '+91 977119044',
        token: 'calley_firebase_jwt_${DateTime.now().millisecondsSinceEpoch}',
        parentAccountId: '#977119044',
        subscription: 'Calley Personal',
      );
      _token = _user!.token;
      _apiService.setAuthToken(_token!);
      await _storageService.saveToken(_token!);
      await _storageService.saveUserData(_user!);
    }

    _setLoading(false);
    return verified;
  }

  /// Logout from both Firebase Auth and Calley local session
  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    _user = null;
    _token = null;
    _apiService.clearAuthToken();
    await _storageService.clearAll();
    notifyListeners();
  }

  // ---------- Helpers ----------

  static String digitsOnly(String text) {
    final d = text.replaceAll(RegExp(r'\D'), '');
    return d.isNotEmpty ? d : '977119044';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
