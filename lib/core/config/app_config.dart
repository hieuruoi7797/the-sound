enum Environment {
  production,
  dev,
}

class AppConfig {
  static Environment _environment = Environment.production;
  static const String _environmentKey = 'app_environment';
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static String get databaseUrl {
    switch (_environment) {
      case Environment.production:
        return "https://my-tune-1ac48-default-rtdb.asia-southeast1.firebasedatabase.app";
      case Environment.dev:
        return "https://my-tune-dev.asia-southeast1.firebasedatabase.app";
    }
  }
  
  static String get appName {
    switch (_environment) {
      case Environment.production:
        return "MyTune";
      case Environment.dev:
        return "MyTune Dev";
    }
  }
  
  static String get bundleId => "com.splat.mytune"; // Same for both flavors
  
  static bool get isProduction => _environment == Environment.production;
  static bool get isDev => _environment == Environment.dev;
  
  /// Get environment key for cache invalidation
  static String get environmentKey => _environment.name;
}