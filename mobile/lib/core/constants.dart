import 'env_config.dart';

class AppConstants {
  // API Configuration (uses environment config)
  static String get baseUrl => EnvConfig.apiBaseUrl;
  static const String apiBasePath = '/api';
  static String get apiUrl => '$baseUrl$apiBasePath';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/me';
  static const String medicationsEndpoint = '/medications';
  static const String userMedicationsEndpoint = '/user-medications';
  static const String activeUserMedicationsEndpoint = '/user-medications/active';
  static const String medicationLogsEndpoint = '/medication-logs';

  // Pagination
  static const int defaultLimit = 20;
  static const int defaultOffset = 0;
}
