import 'app_localizations.dart';

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'आईटैक्स इनवॉइस';

  @override
  String get home => 'होम';

  @override
  String get firebaseMonitoring => 'फायरबेस मॉनिटरिंग';

  @override
  String get crashlytics => 'क्रैशलिटिक्स';

  @override
  String get analytics => 'एनालिटिक्स';

  @override
  String get testTools => 'टेस्ट टूल्स';

  @override
  String get quickLinks => 'त्वरित लिंक';

  @override
  String get crashReports => 'क्रैश रिपोर्ट';

  @override
  String get crashReportsDescription => 'ऐप क्रैश और स्थिरता की निगरानी करें';

  @override
  String get crashSimulator => 'क्रैश सिमुलेटर';

  @override
  String get crashSimulatorDescription => 'क्रैश रिपोर्टिंग कार्यक्षमता का परीक्षण करें';

  @override
  String get authError => 'प्रमाणीकरण त्रुटि';

  @override
  String get networkError => 'नेटवर्क त्रुटि';

  @override
  String get validationError => 'सत्यापन त्रुटि';

  @override
  String get criticalError => 'गंभीर त्रुटि';

  @override
  String get crashSimulatorNote => 'ये केवल विकास उद्देश्यों के लिए परीक्षण क्रैश हैं';

  @override
  String get analyticsTest => 'एनालिटिक्स परीक्षण';

  @override
  String get analyticsTestDescription => 'एनालिटिक्स इवेंट ट्रैकिंग का परीक्षण करें';

  @override
  String get screenView => 'स्क्रीन व्यू';

  @override
  String get userAction => 'उपयोगकर्ता क्रिया';

  @override
  String get businessEvent => 'व्यावसायिक घटना';

  @override
  String get customEvent => 'कस्टम इवेंट';
}
