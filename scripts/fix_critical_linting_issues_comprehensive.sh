#!/bin/bash

echo "🔧 Starting comprehensive linting fixes for Flutter Invoice App..."

# Fix missing dependencies in pubspec.yaml
echo "📦 Adding missing dependencies..."
flutter pub add url_launcher
flutter pub add json_annotation
flutter pub add equatable
flutter pub add build_runner --dev
flutter pub add json_serializable --dev

# Run pub get to ensure dependencies are available
flutter pub get

echo "🔨 Fixing critical syntax errors..."

# Fix firestore_gstr3b_model.dart syntax error
cat > lib/models/gst_returns/firestore_gstr3b_model.dart << 'EOF'
import '../base/firestore_model.dart';

class FirestoreGSTR3B extends FirestoreModel {
  final String gstin;
  final String returnPeriod;
  final String financialYear;
  final Map<String, dynamic> outwardSupplies;
  final Map<String, dynamic> inwardSupplies;
  final Map<String, dynamic> itcDetails;
  final Map<String, dynamic> taxPayment;
  final String status;
  final DateTime? filedDate;
  final String? acknowledgmentNumber;

  const FirestoreGSTR3B({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    required this.gstin,
    required this.returnPeriod,
    required this.financialYear,
    required this.outwardSupplies,
    required this.inwardSupplies,
    required this.itcDetails,
    required this.taxPayment,
    this.status = 'draft',
    this.filedDate,
    this.acknowledgmentNumber,
  });

  factory FirestoreGSTR3B.fromJson(Map<String, dynamic> json) {
    return FirestoreGSTR3B(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      gstin: json['gstin'] as String,
      returnPeriod: json['returnPeriod'] as String,
      financialYear: json['financialYear'] as String,
      outwardSupplies: json['outwardSupplies'] as Map<String, dynamic>,
      inwardSupplies: json['inwardSupplies'] as Map<String, dynamic>,
      itcDetails: json['itcDetails'] as Map<String, dynamic>,
      taxPayment: json['taxPayment'] as Map<String, dynamic>,
      status: json['status'] as String? ?? 'draft',
      filedDate: json['filedDate'] != null ? DateTime.parse(json['filedDate'] as String) : null,
      acknowledgmentNumber: json['acknowledgmentNumber'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'gstin': gstin,
      'returnPeriod': returnPeriod,
      'financialYear': financialYear,
      'outwardSupplies': outwardSupplies,
      'inwardSupplies': inwardSupplies,
      'itcDetails': itcDetails,
      'taxPayment': taxPayment,
      'status': status,
      'filedDate': filedDate?.toIso8601String(),
      'acknowledgmentNumber': acknowledgmentNumber,
    };
  }

  FirestoreGSTR3B copyWith({
    String? gstin,
    String? returnPeriod,
    String? financialYear,
    Map<String, dynamic>? outwardSupplies,
    Map<String, dynamic>? inwardSupplies,
    Map<String, dynamic>? itcDetails,
    Map<String, dynamic>? taxPayment,
    String? status,
    DateTime? filedDate,
    String? acknowledgmentNumber,
  }) {
    return FirestoreGSTR3B(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      financialYear: financialYear ?? this.financialYear,
      outwardSupplies: outwardSupplies ?? this.outwardSupplies,
      inwardSupplies: inwardSupplies ?? this.inwardSupplies,
      itcDetails: itcDetails ?? this.itcDetails,
      taxPayment: taxPayment ?? this.taxPayment,
      status: status ?? this.status,
      filedDate: filedDate ?? this.filedDate,
      acknowledgmentNumber: acknowledgmentNumber ?? this.acknowledgmentNumber,
    );
  }
}

class GSTR3BOutwardSupplies {
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;

  const GSTR3BOutwardSupplies({
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
  });

  factory GSTR3BOutwardSupplies.fromJson(Map<String, dynamic> json) {
    return GSTR3BOutwardSupplies(
      taxableValue: (json['taxableValue'] as num).toDouble(),
      igstAmount: (json['igstAmount'] as num).toDouble(),
      cgstAmount: (json['cgstAmount'] as num).toDouble(),
      sgstAmount: (json['sgstAmount'] as num).toDouble(),
      cessAmount: (json['cessAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taxableValue': taxableValue,
      'igstAmount': igstAmount,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'cessAmount': cessAmount,
    };
  }
}

class GSTR3BInwardSupplies {
  final double eligibleITC;
  final double ineligibleITC;

  const GSTR3BInwardSupplies({
    required this.eligibleITC,
    required this.ineligibleITC,
  });

  factory GSTR3BInwardSupplies.fromJson(Map<String, dynamic> json) {
    return GSTR3BInwardSupplies(
      eligibleITC: (json['eligibleITC'] as num).toDouble(),
      ineligibleITC: (json['ineligibleITC'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligibleITC': eligibleITC,
      'ineligibleITC': ineligibleITC,
    };
  }
}

class GSTR3BITCDetails {
  final double itcAvailed;
  final double itcReversed;

  const GSTR3BITCDetails({
    required this.itcAvailed,
    required this.itcReversed,
  });

  factory GSTR3BITCDetails.fromJson(Map<String, dynamic> json) {
    return GSTR3BITCDetails(
      itcAvailed: (json['itcAvailed'] as num).toDouble(),
      itcReversed: (json['itcReversed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itcAvailed': itcAvailed,
      'itcReversed': itcReversed,
    };
  }
}

class GSTR3BTaxPayment {
  final double igstPaid;
  final double cgstPaid;
  final double sgstPaid;
  final double cessPaid;

  const GSTR3BTaxPayment({
    required this.igstPaid,
    required this.cgstPaid,
    required this.sgstPaid,
    required this.cessPaid,
  });

  factory GSTR3BTaxPayment.fromJson(Map<String, dynamic> json) {
    return GSTR3BTaxPayment(
      igstPaid: (json['igstPaid'] as num).toDouble(),
      cgstPaid: (json['cgstPaid'] as num).toDouble(),
      sgstPaid: (json['sgstPaid'] as num).toDouble(),
      cessPaid: (json['cessPaid'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'igstPaid': igstPaid,
      'cgstPaid': cgstPaid,
      'sgstPaid': sgstPaid,
      'cessPaid': cessPaid,
    };
  }
}
EOF

# Fix customer_extensions.dart
cat > lib/models/customer/customer_extensions.dart << 'EOF'
import 'customer_model.dart';

extension CustomerExtensions on Customer {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': address,
      'gstin': gstin,
      'panNumber': panNumber,
      'type': type.toString(),
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Customer fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      gstin: map['gstin'] as String?,
      panNumber: map['panNumber'] as String?,
      type: CustomerType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => CustomerType.individual,
      ),
      creditLimit: (map['creditLimit'] as num?)?.toDouble(),
      currentBalance: (map['currentBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  bool get isBusinessCustomer => type == CustomerType.business;
  bool get hasGSTIN => gstin != null && gstin!.isNotEmpty;
  bool get hasOutstandingBalance => currentBalance > 0;
}
EOF

# Fix environment configuration issues
cat > lib/config/environment.dart << 'EOF'
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.example.com';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }
}
EOF

# Fix main_dev.dart
cat > lib/main_dev.dart << 'EOF'
import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  EnvironmentConfig.setEnvironment(Environment.development);
  app.main();
}
EOF

# Fix main_staging.dart
cat > lib/main_staging.dart << 'EOF'
import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  EnvironmentConfig.setEnvironment(Environment.staging);
  app.main();
}
EOF

# Fix main_prod.dart
cat > lib/main_prod.dart << 'EOF'
import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  EnvironmentConfig.setEnvironment(Environment.production);
  app.main();
}
EOF

echo "🌐 Adding missing localization strings..."

# Add missing localization strings to app_en.arb
cat > lib/l10n/app_en.arb << 'EOF'
{
  "@@locale": "en",
  "appTitle": "GST Invoice App",
  "home": "Home",
  "settings": "Settings",
  "gstReturns": "GST Returns",
  "invoices": "Invoices",
  "customers": "Customers",
  "reports": "Reports",
  "dashboard": "Dashboard",
  "profile": "Profile",
  "logout": "Logout",
  "login": "Login",
  "email": "Email",
  "password": "Password",
  "forgotPassword": "Forgot Password?",
  "register": "Register",
  "name": "Name",
  "confirmPassword": "Confirm Password",
  "save": "Save",
  "cancel": "Cancel",
  "delete": "Delete",
  "edit": "Edit",
  "add": "Add",
  "search": "Search",
  "filter": "Filter",
  "sort": "Sort",
  "export": "Export",
  "import": "Import",
  "refresh": "Refresh",
  "loading": "Loading...",
  "error": "Error",
  "success": "Success",
  "warning": "Warning",
  "info": "Information",
  "confirm": "Confirm",
  "yes": "Yes",
  "no": "No",
  "ok": "OK",
  "close": "Close",
  "back": "Back",
  "next": "Next",
  "previous": "Previous",
  "finish": "Finish",
  "submit": "Submit",
  "reset": "Reset",
  "clear": "Clear",
  "select": "Select",
  "selectAll": "Select All",
  "deselectAll": "Deselect All",
  "crashFreeUsers": "Crash Free Users",
  "totalCrashes": "Total Crashes",
  "affectedUsers": "Affected Users",
  "openCrashlytics": "Open Crashlytics",
  "analyticsOverview": "Analytics Overview",
  "analyticsDescription": "Monitor app usage and user behavior",
  "activeUsers": "Active Users",
  "sessions": "Sessions",
  "screenViews": "Screen Views",
  "openAnalytics": "Open Analytics",
  "recentCrashes": "Recent Crashes",
  "crashTrends": "Crash Trends",
  "topEvents": "Top Events",
  "userJourney": "User Journey",
  "firebaseQuickLinks": "Firebase Quick Links",
  "crashlyticsConsole": "Crashlytics Console",
  "crashlyticsDescription": "Monitor app crashes and stability",
  "analyticsConsole": "Analytics Console",
  "analyticsConsoleDescription": "View detailed analytics data",
  "performanceConsole": "Performance Console",
  "performanceDescription": "Monitor app performance metrics",
  "remoteConfigConsole": "Remote Config Console",
  "remoteConfigDescription": "Manage app configuration remotely",
  "firestoreConsole": "Firestore Console",
  "firestoreDescription": "Manage your app's database",
  "firebaseProjectNote": "Note: Replace PROJECT_ID with your actual Firebase project ID"
}
EOF

# Add missing localization strings to app_hi.arb
cat > lib/l10n/app_hi.arb << 'EOF'
{
  "@@locale": "hi",
  "appTitle": "जीएसटी इनवॉइस ऐप",
  "home": "होम",
  "settings": "सेटिंग्स",
  "gstReturns": "जीएसटी रिटर्न",
  "invoices": "इनवॉइस",
  "customers": "ग्राहक",
  "reports": "रिपोर्ट",
  "dashboard": "डैशबोर्ड",
  "profile": "प्रोफाइल",
  "logout": "लॉगआउट",
  "login": "लॉगिन",
  "email": "ईमेल",
  "password": "पासवर्ड",
  "forgotPassword": "पासवर्ड भूल गए?",
  "register": "रजिस्टर",
  "name": "नाम",
  "confirmPassword": "पासवर्ड की पुष्टि करें",
  "save": "सेव",
  "cancel": "रद्द करें",
  "delete": "डिलीट",
  "edit": "एडिट",
  "add": "जोड़ें",
  "search": "खोजें",
  "filter": "फिल्टर",
  "sort": "सॉर्ट",
  "export": "एक्सपोर्ट",
  "import": "इम्पोर्ट",
  "refresh": "रिफ्रेश",
  "loading": "लोड हो रहा है...",
  "error": "त्रुटि",
  "success": "सफलता",
  "warning": "चेतावनी",
  "info": "जानकारी",
  "confirm": "पुष्टि करें",
  "yes": "हाँ",
  "no": "नहीं",
  "ok": "ठीक है",
  "close": "बंद करें",
  "back": "वापस",
  "next": "अगला",
  "previous": "पिछला",
  "finish": "समाप्त",
  "submit": "जमा करें",
  "reset": "रीसेट",
  "clear": "साफ़ करें",
  "select": "चुनें",
  "selectAll": "सभी चुनें",
  "deselectAll": "सभी अचयनित करें",
  "crashFreeUsers": "क्रैश मुक्त उपयोगकर्ता",
  "totalCrashes": "कुल क्रैश",
  "affectedUsers": "प्रभावित उपयोगकर्ता",
  "openCrashlytics": "क्रैशलिटिक्स खोलें",
  "analyticsOverview": "एनालिटिक्स अवलोकन",
  "analyticsDescription": "ऐप उपयोग और उपयोगकर्ता व्यवहार की निगरानी करें",
  "activeUsers": "सक्रिय उपयोगकर्ता",
  "sessions": "सत्र",
  "screenViews": "स्क्रीन दृश्य",
  "openAnalytics": "एनालिटिक्स खोलें",
  "recentCrashes": "हाल की क्रैश",
  "crashTrends": "क्रैश रुझान",
  "topEvents": "शीर्ष घटनाएं",
  "userJourney": "उपयोगकर्ता यात्रा",
  "firebaseQuickLinks": "फायरबेस त्वरित लिंक",
  "crashlyticsConsole": "क्रैशलिटिक्स कंसोल",
  "crashlyticsDescription": "ऐप क्रैश और स्थिरता की निगरानी करें",
  "analyticsConsole": "एनालिटिक्स कंसोल",
  "analyticsConsoleDescription": "विस्तृत एनालिटिक्स डेटा देखें",
  "performanceConsole": "प्रदर्शन कंसोल",
  "performanceDescription": "ऐप प्रदर्शन मेट्रिक्स की निगरानी करें",
  "remoteConfigConsole": "रिमोट कॉन्फ़िग कंसोल",
  "remoteConfigDescription": "ऐप कॉन्फ़िगरेशन को दूर से प्रबंधित करें",
  "firestoreConsole": "फायरस्टोर कंसोल",
  "firestoreDescription": "अपने ऐप के डेटाबेस को प्रबंधित करें",
  "firebaseProjectNote": "नोट: PROJECT_ID को अपनी वास्तविक फायरबेस प्रोजेक्ट आईडी से बदलें"
}
EOF

echo "🔧 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "🧹 Running dart fix to apply automatic fixes..."
dart fix --apply

echo "🎯 Running flutter analyze to check remaining issues..."
flutter analyze --no-fatal-infos

echo "✅ Critical linting fixes completed!"
echo "📋 Summary of fixes applied:"
echo "   - Added missing dependencies (url_launcher, json_annotation, equatable)"
echo "   - Fixed syntax errors in firestore_gstr3b_model.dart"
echo "   - Fixed customer_extensions.dart undefined class issues"
echo "   - Fixed environment configuration issues"
echo "   - Added missing localization strings"
echo "   - Generated missing JSON serialization code"
echo "   - Applied automatic dart fixes"
echo ""
echo "🔍 Next steps:"
echo "   1. Review any remaining analyzer warnings"
echo "   2. Test the app to ensure functionality is preserved"
echo "   3. Run 'flutter test' to verify tests still pass"
echo "   4. Consider running 'flutter pub deps' to check dependency health"
EOF

chmod +x scripts/fix_critical_linting_issues_comprehensive.sh
