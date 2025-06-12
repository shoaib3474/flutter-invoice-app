import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationsDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// \`\`\`dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// \`\`\`
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// \`\`\`yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// \`\`\`
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'iTax Invoice'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @firebaseMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Firebase Monitoring'**
  String get firebaseMonitoring;

  /// No description provided for @crashlytics.
  ///
  /// In en, this message translates to:
  /// **'Crashlytics'**
  String get crashlytics;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @testTools.
  ///
  /// In en, this message translates to:
  /// **'Test Tools'**
  String get testTools;

  /// No description provided for @quickLinks.
  ///
  /// In en, this message translates to:
  /// **'Quick Links'**
  String get quickLinks;

  /// No description provided for @crashReports.
  ///
  /// In en, this message translates to:
  /// **'Crash Reports'**
  String get crashReports;

  /// No description provided for @crashReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor app crashes and stability'**
  String get crashReportsDescription;

  /// No description provided for @crashSimulator.
  ///
  /// In en, this message translates to:
  /// **'Crash Simulator'**
  String get crashSimulator;

  /// No description provided for @crashSimulatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Test crash reporting functionality'**
  String get crashSimulatorDescription;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Auth Error'**
  String get authError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationError;

  /// No description provided for @criticalError.
  ///
  /// In en, this message translates to:
  /// **'Critical Error'**
  String get criticalError;

  /// No description provided for @crashSimulatorNote.
  ///
  /// In en, this message translates to:
  /// **'These are test crashes for development purposes only'**
  String get crashSimulatorNote;

  /// No description provided for @analyticsTest.
  ///
  /// In en, this message translates to:
  /// **'Analytics Test'**
  String get analyticsTest;

  /// No description provided for @analyticsTestDescription.
  ///
  /// In en, this message translates to:
  /// **'Test analytics event tracking'**
  String get analyticsTestDescription;

  /// No description provided for @screenView.
  ///
  /// In en, this message translates to:
  /// **'Screen View'**
  String get screenView;

  /// No description provided for @userAction.
  ///
  /// In en, this message translates to:
  /// **'User Action'**
  String get userAction;

  /// No description provided for @businessEvent.
  ///
  /// In en, this message translates to:
  /// **'Business Event'**
  String get businessEvent;

  /// No description provided for @customEvent.
  ///
  /// In en, this message translates to:
  /// **'Custom Event'**
  String get customEvent;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue on GitHub with a '
    'reproducible example of the issue and the full stacktrace.'
  );
}
