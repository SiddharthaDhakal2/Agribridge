import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// provider
final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(prefs: ref.read(sharedPreferencesProvider));
});

class TokenService {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  // Get token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  // Remove token (for logout)
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }
}