import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  EnvironmentConfig.setEnvironment(Environment.production);
  app.main();
}
