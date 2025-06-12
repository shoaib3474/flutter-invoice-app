import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'iTax Invoice';

  @override
  String get home => 'Home';

  @override
  String get firebaseMonitoring => 'Firebase Monitoring';

  @override
  String get crashlytics => 'Crashlytics';

  @override
  String get analytics => 'Analytics';

  @override
  String get testTools => 'Test Tools';

  @override
  String get quickLinks => 'Quick Links';

  @override
  String get crashReports => 'Crash Reports';

  @override
  String get crashReportsDescription => 'Monitor app crashes and stability';

  @override
  String get crashSimulator => 'Crash Simulator';

  @override
  String get crashSimulatorDescription => 'Test crash reporting functionality';

  @override
  String get authError => 'Auth Error';

  @override
  String get networkError => 'Network Error';

  @override
  String get validationError => 'Validation Error';

  @override
  String get criticalError => 'Critical Error';

  @override
  String get crashSimulatorNote => 'These are test crashes for development purposes only';

  @override
  String get analyticsTest => 'Analytics Test';

  @override
  String get analyticsTestDescription => 'Test analytics event tracking';

  @override
  String get screenView => 'Screen View';

  @override
  String get userAction => 'User Action';

  @override
  String get businessEvent => 'Business Event';

  @override
  String get customEvent => 'Custom Event';
}
