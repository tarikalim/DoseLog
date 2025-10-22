import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.authTokenKey, value: token);
  }

  // Get authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }

  // Save user data
  Future<void> saveUserData({
    required String userId,
    required String email,
  }) async {
    await _storage.write(key: AppConstants.userIdKey, value: userId);
    await _storage.write(key: AppConstants.userEmailKey, value: email);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  // Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: AppConstants.userEmailKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
