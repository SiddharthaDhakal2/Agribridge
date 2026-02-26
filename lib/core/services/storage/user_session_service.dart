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
    //     print('========================');
  }
}
