import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences. Call once at app startup.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError(
          'StorageService not initialized. Call init() before use.');
    }
    return _prefs!;
  }

  // ---------- Token ----------

  Future<bool> saveToken(String token) async {
    return _p.setString(_tokenKey, token);
  }

  String? getToken() {
    return _p.getString(_tokenKey);
  }

  Future<bool> removeToken() async {
    return _p.remove(_tokenKey);
  }

  // ---------- User ID ----------

  Future<bool> saveUserId(String userId) async {
    return _p.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _p.getString(_userIdKey);
  }

  // ---------- User Data ----------

  Future<bool> saveUserData(User user) async {
    final jsonString = jsonEncode(user.toJson());
    return _p.setString(_userDataKey, jsonString);
  }

  User? getUserData() {
    final jsonString = _p.getString(_userDataKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ---------- Clear ----------

  Future<bool> clear() async {
    return _p.clear();
  }

  Future<bool> clearAll() async {
    return _p.clear();
  }
}
