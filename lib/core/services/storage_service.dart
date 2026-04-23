import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService(this._preferences);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final SharedPreferences _preferences;

  String? get token => _preferences.getString(_tokenKey);

  bool get hasToken => token != null && token!.isNotEmpty;

  Map<String, dynamic>? get userJson {
    final raw = _preferences.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    await _preferences.setString(_tokenKey, token);
    await _preferences.setString(_userKey, jsonEncode(userJson));
  }

  Future<void> clearSession() async {
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_userKey);
  }
}
