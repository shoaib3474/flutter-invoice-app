enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  static String get appName {
    switch (_environment) {
      case Environment.development:
        return 'GST Invoice (Dev)';
      case Environment.staging:
        return 'GST Invoice (Staging)';
      case Environment.production:
        return 'GST Invoice';
    }
  }

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://development.example.com/api';
      case Environment.staging:
        return 'https://staging.example.com/api';
      case Environment.production:
        return 'https://production.example.com/api';
    }
  }

  static bool get enableDebugMode {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static String get logLevel {
    switch (_environment) {
      case Environment.development:
        return 'DEBUG';
      case Environment.staging:
        return 'INFO';
      case Environment.production:
        return 'ERROR';
    }
  }

  static bool get enableAnalytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }

  static bool get enableCrashReporting {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
}
