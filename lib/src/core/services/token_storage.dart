import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';

  Future<void> save({
    required String token,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
  }

  Future<(String?, String?)> read() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_tokenKey), prefs.getString(_emailKey));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
  }
}
