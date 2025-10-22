import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/token_manager.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final TokenManager _tokenManager = TokenManager();

  // Login
  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        body: request.toJson(),
        includeAuth: false,
      );

      final loginResponse = LoginResponse.fromJson(response);

      // Save token and user data
      await _tokenManager.saveToken(loginResponse.token);
      await _tokenManager.saveUserData(
        userId: loginResponse.user.id,
        email: loginResponse.user.email,
      );

      return loginResponse;
    } catch (e) {
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  // Register
  Future<User> register(String email, String password) async {
    try {
      final request = RegisterRequest(email: email, password: password);
      final response = await _apiClient.post(
        AppConstants.registerEndpoint,
        body: request.toJson(),
        includeAuth: false,
      );

      return User.fromJson(response);
    } catch (e) {
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  // Get current user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get(AppConstants.meEndpoint);
      return User.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to get user info: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _tokenManager.clearAll();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _tokenManager.isLoggedIn();
  }
}
