import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  EnvironmentConfig.environment = Environment.development;
  app.main();
}

class EnvironmentConfig {
  static Environment? environment;

  // existing fields and methods
}
