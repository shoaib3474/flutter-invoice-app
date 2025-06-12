import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  EnvironmentConfig.environment = Environment.staging;
  app.main();
}

class EnvironmentConfig {
  static Environment? environment;

  // existing fields and methods
}
