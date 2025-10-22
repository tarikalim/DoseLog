/// Environment configuration for different build modes
class EnvConfig {
  // Build flavor (development, staging, production)
  static const String _environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Base URL from environment variable or default
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.50:8080',
  );

  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';

  static String get environment => _environment;
  static String get apiBaseUrl => _apiBaseUrl;

  // Print current configuration (useful for debugging)
  static void printConfig() {
    print('Environment: $_environment');
    print('API Base URL: $_apiBaseUrl');
  }
}
