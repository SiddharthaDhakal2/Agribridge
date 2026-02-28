import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class BiometricCredentials {
  final String email;
  final String password;

  const BiometricCredentials({required this.email, required this.password});
}

class UserSessionService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUsername = 'user_name';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyUserAddress = 'user_address';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyToken = 'auth_token';
  static const String _keyUserCartPrefix = 'user_cart_';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyBiometricEmail = 'biometric_email';
  static const String _keyBiometricPassword = 'biometric_password';
  static const String _keyBiometricEnabledUserId = 'biometric_enabled_user_id';
  static const String _keyBiometricCredentialsPrefix = 'biometric_credentials_';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    String? address,
    required String profilePicture,
    required String username,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUsername, username);
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      await _prefs.remove(_keyUserPhoneNumber);
    } else {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber.trim());
    }
    if (address == null || address.trim().isEmpty) {
      await _prefs.remove(_keyUserAddress);
    } else {
      await _prefs.setString(_keyUserAddress, address.trim());
    }
    await _prefs.setString(_keyUserProfilePicture, profilePicture);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  String? getCurrentUserUsername() {
    return _prefs.getString(_keyUsername);
  }

  String? getCurrentUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }

  String? getCurrentUserAddress() {
    return _prefs.getString(_keyUserAddress);
  }

  Future<void> setCurrentUserFullName(String fullName) async {
    await _prefs.setString(_keyUserFullName, fullName);
  }

  Future<void> setCurrentUserEmail(String email) async {
    await _prefs.setString(_keyUserEmail, email);
  }

  Future<void> setCurrentUserPhoneNumber(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      await _prefs.remove(_keyUserPhoneNumber);
      return;
    }
    await _prefs.setString(_keyUserPhoneNumber, phoneNumber.trim());
  }

  Future<void> setCurrentUserAddress(String? address) async {
    if (address == null || address.trim().isEmpty) {
      await _prefs.remove(_keyUserAddress);
      return;
    }
    await _prefs.setString(_keyUserAddress, address.trim());
  }

  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  Future<void> setCurrentUserProfilePicture(String profilePicture) async {
    await _prefs.setString(_keyUserProfilePicture, profilePicture);
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  // Get token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  bool isBiometricLoginEnabled() {
    return _prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  bool isBiometricLoginEnabledForCurrentUser() {
    if (!isBiometricLoginEnabled()) return false;

    final currentUserId = getCurrentUserId()?.trim();
    final ownerUserId = getBiometricEnabledUserId()?.trim();
    if (currentUserId == null || currentUserId.isEmpty) return false;
    if (ownerUserId == null || ownerUserId.isEmpty) return false;
    return currentUserId == ownerUserId;
  }

  Future<void> setBiometricLoginEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricEnabled, enabled);
    if (enabled) {
      final currentUserId = getCurrentUserId();
      if (currentUserId != null && currentUserId.trim().isNotEmpty) {
        await _prefs.setString(_keyBiometricEnabledUserId, currentUserId);
      }
      return;
    }

    final ownerUserId = getBiometricEnabledUserId();
    if (ownerUserId != null && ownerUserId.trim().isNotEmpty) {
      await clearBiometricCredentialsForUser(ownerUserId);
    }
    await _prefs.remove(_keyBiometricEnabledUserId);
    await _clearLegacyBiometricCredentials();
  }

  String? getBiometricEnabledUserId() {
    return _prefs.getString(_keyBiometricEnabledUserId);
  }

  Future<void> syncBiometricStateAfterLogin({
    required String loggedInUserId,
  }) async {
    final enabled = isBiometricLoginEnabled();
    if (!enabled) return;

    final ownerUserId = getBiometricEnabledUserId();
    final normalizedLoggedInUserId = loggedInUserId.trim();
    final normalizedOwnerUserId = ownerUserId?.trim() ?? '';

    if (normalizedOwnerUserId.isEmpty) {
      await _prefs.setString(
        _keyBiometricEnabledUserId,
        normalizedLoggedInUserId,
      );
    }
  }

  String _biometricCredentialsKey(String userId) {
    return '$_keyBiometricCredentialsPrefix${userId.trim()}';
  }

  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      await _saveLegacyBiometricCredentials(email: email, password: password);
      return;
    }

    await saveBiometricCredentialsForUser(
      userId: currentUserId,
      email: email,
      password: password,
    );
  }

  Future<void> saveBiometricCredentialsForUser({
    required String userId,
    required String email,
    required String password,
  }) async {
    final trimmedUserId = userId.trim();
    final trimmedEmail = email.trim();
    if (trimmedUserId.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return;
    }

    final payload = jsonEncode({'email': trimmedEmail, 'password': password});
    await _secureStorage.write(
      key: _biometricCredentialsKey(trimmedUserId),
      value: payload,
    );
  }

  Future<void> _saveLegacyBiometricCredentials({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) return;
    await _secureStorage.write(key: _keyBiometricEmail, value: trimmedEmail);
    await _secureStorage.write(key: _keyBiometricPassword, value: password);
  }

  Future<BiometricCredentials?> getBiometricCredentials() async {
    if (!isBiometricLoginEnabled()) {
      return null;
    }

    final ownerUserId = getBiometricEnabledUserId();
    if (ownerUserId == null || ownerUserId.trim().isEmpty) {
      return _getLegacyBiometricCredentials();
    }

    final credentials = await getBiometricCredentialsForUser(ownerUserId);
    if (credentials != null) {
      return credentials;
    }

    return _getLegacyBiometricCredentials();
  }

  Future<BiometricCredentials?> getBiometricCredentialsForUser(
    String userId,
  ) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) return null;

    final raw = await _secureStorage.read(
      key: _biometricCredentialsKey(trimmedUserId),
    );
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final email = (decoded['email'] as String?)?.trim() ?? '';
      final password = decoded['password'] as String?;
      if (email.isEmpty || password == null || password.isEmpty) {
        return null;
      }
      return BiometricCredentials(email: email, password: password);
    } catch (_) {
      return null;
    }
  }

  Future<BiometricCredentials?> _getLegacyBiometricCredentials() async {
    final email = await _secureStorage.read(key: _keyBiometricEmail);
    final password = await _secureStorage.read(key: _keyBiometricPassword);
    if (email == null || email.trim().isEmpty || password == null) return null;
    if (password.isEmpty) return null;

    return BiometricCredentials(email: email.trim(), password: password);
  }

  Future<bool> hasBiometricCredentials() async {
    final credentials = await getBiometricCredentials();
    return credentials != null;
  }

  Future<bool> hasBiometricCredentialsForCurrentUser() async {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return false;
    }

    final credentials = await getBiometricCredentialsForUser(currentUserId);
    if (credentials != null) {
      return true;
    }

    final ownerUserId = getBiometricEnabledUserId()?.trim();
    if (ownerUserId == currentUserId.trim()) {
      final legacyCredentials = await _getLegacyBiometricCredentials();
      return legacyCredentials != null;
    }

    return false;
  }

  Future<void> clearBiometricCredentialsForUser(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) return;
    await _secureStorage.delete(key: _biometricCredentialsKey(trimmedUserId));
  }

  Future<void> clearBiometricCredentials() async {
    final ownerUserId = getBiometricEnabledUserId();
    if (ownerUserId != null && ownerUserId.trim().isNotEmpty) {
      await clearBiometricCredentialsForUser(ownerUserId);
    }
    await _clearLegacyBiometricCredentials();
  }

  Future<void> _clearLegacyBiometricCredentials() async {
    await _secureStorage.delete(key: _keyBiometricEmail);
    await _secureStorage.delete(key: _keyBiometricPassword);
  }

  Future<void> clearBiometricDataForCurrentUser() async {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return;
    }

    await clearBiometricCredentialsForUser(currentUserId);
    final ownerUserId = getBiometricEnabledUserId()?.trim();
    if (ownerUserId == currentUserId.trim()) {
      await _prefs.remove(_keyBiometricEnabled);
      await _prefs.remove(_keyBiometricEnabledUserId);
      await _clearLegacyBiometricCredentials();
    }
  }

  Future<void> clearBiometricLoginSetup() async {
    final ownerUserId = getBiometricEnabledUserId();
    if (ownerUserId != null && ownerUserId.trim().isNotEmpty) {
      await clearBiometricCredentialsForUser(ownerUserId);
    }
    await _prefs.remove(_keyBiometricEnabled);
    await _prefs.remove(_keyBiometricEnabledUserId);
    await _clearLegacyBiometricCredentials();
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyUserAddress);
    await _prefs.remove(_keyUserProfilePicture);
    await _secureStorage.delete(key: _keyToken);
  }

  String _cartKey(String userId) => '$_keyUserCartPrefix$userId';

  Future<void> saveCartForUser({
    required String userId,
    required String cartJson,
  }) async {
    await _prefs.setString(_cartKey(userId), cartJson);
  }

  String? getCartForUser(String userId) {
    return _prefs.getString(_cartKey(userId));
  }

  Future<void> clearCartForUser(String userId) async {
    await _prefs.remove(_cartKey(userId));
  }

  // Debug: Print all saved user data
  void debugPrintUserData() {
    debugPrint('USER SESSION DATA');
    debugPrint('IsLoggedIn: ${isLoggedIn()}');
    debugPrint('UserId: ${getCurrentUserId()}');
    debugPrint('Email: ${getCurrentUserEmail()}');
    debugPrint('FullName: ${getCurrentUserFullName()}');
    debugPrint('BiometricEnabled: ${isBiometricLoginEnabled()}');
    debugPrint('BiometricOwnerUserId: ${getBiometricEnabledUserId()}');
    //     print('========================');
  }
}
