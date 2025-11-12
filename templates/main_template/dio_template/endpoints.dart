/// API Endpoints configuration
/// Supports multiple environments (development, staging, production)
class Endpoints {
  Endpoints._();

  // Environment configuration
  static Environment _environment = Environment.development;
  
  /// Set the current environment
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  /// Get the current environment
  static Environment get environment => _environment;

  // Base URLs for different environments
  static const String _baseUrlDev = "";
  static const String _baseUrlStaging = "";
  static const String _baseUrlProduction = "";

  /// Get base URL based on current environment
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return _baseUrlDev;
      case Environment.staging:
        return _baseUrlStaging;
      case Environment.production:
        return _baseUrlProduction;
    }
  }

  // API Version
  static const String apiVersion = "v1";
  
  /// Get full API path
  static String apiPath(String path) => "/$apiVersion$path";

  // Timeout configurations
  static const int receiveTimeout = 30000; // 30 seconds
  static const int connectionTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Headers
  static const String contentType = "application/json";
  static const String accept = "application/json";
  static const String tokenHeader = "token";
  static const String authorizationHeader = "Authorization";
}

/// Environment enum for API configuration
enum Environment {
  development,
  staging,
  production,
}


