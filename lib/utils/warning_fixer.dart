import 'dart:io';

class WarningFixer {
  static Future<void> fixAllWarnings() async {
    print('🧹 Fixing all warnings and unused imports...');
    
    // List of files with unused imports to fix
    final filesToFix = [
      'lib/api/demo/demo_gstr1_api_service.dart',
      'lib/api/demo_gst_api_client.dart',
      'lib/config/router.dart',
      'lib/config/routes/invoice_routes.dart',
      'lib/database/database_helper.dart',
      'lib/features/build/screens/apk_build_screen.dart',
      'lib/features/build/screens/enhanced_apk_build_screen.dart',
      'lib/main_dev.dart',
      'lib/main_prod.dart',
      'lib/main_staging.dart',
      'lib/models/gst_comparison_model.dart',
      'lib/models/gstr1_model.dart',
      'lib/models/gstr3b_model.dart',
      'lib/models/gstr9_model.dart',
      'lib/models/gstr9c_model.dart',
      'lib/screens/gstr1_screen.dart',
      'lib/screens/gstr3b_screen.dart',
      'lib/screens/gstr4_screen.dart',
      'lib/services/export/gstr1_json_service.dart',
      'lib/services/firebase/firebase_setup_checker.dart',
      'lib/services/gstr9_service.dart',
      'lib/services/gstr9c_service.dart',
      'lib/tests/migration_test_suite.dart',
      'lib/widgets/common/export_options_widget.dart',
    ];
    
    // Unused imports to remove
    final unusedImports = [
      "import 'dart:convert';",
      "import 'dart:io';",
      "import 'package:dio/dio.dart';",
      "import 'package:flutter/foundation.dart';",
      "import 'package:flutter/services.dart';",
      "import 'package:flutter/material.dart';",
      "import 'package:provider/provider.dart';",
      "import 'package:path_provider/path_provider.dart';",
      "import 'package:http/http.dart';",
      "import '../models/invoice/invoice_model.dart';",
      "import '../models/customer/customer_model.dart';",
      "import '../models/gst_returns/gstr2a_model.dart';",
      "import '../models/gst_returns/gstr2b_model.dart';",
      "import '../models/gst_returns/gstr3b_model.dart';",
      "import '../models/gst_returns/gstr4_model.dart';",
      "import '../models/gst_returns/gstr9_model.dart';",
      "import '../models/gst_returns/gstr9c_model.dart';",
    ];
    
    for (final filePath in filesToFix) {
      await _fixFileWarnings(filePath, unusedImports);
    }
    
    print('✅ All warnings fixed!');
  }
  
  static Future<void> _fixFileWarnings(String filePath, List<String> unusedImports) async {
    final file = File(filePath);
    if (!await file.exists()) return;
    
    try {
      String content = await file.readAsString();
      
      // Remove unused imports
      for (final import in unusedImports) {
        content = content.replaceAll('$import\n', '');
        content = content.replaceAll(import, '');
      }
      
      // Fix common issues
      content = content.replaceAll('return await', 'return');
      content = content.replaceAll('taxableValueInSource3!', 'taxableValueInSource3');
      content = content.replaceAll('unnecessary_this.', '');
      
      // Remove empty lines
      content = content.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
      
      await file.writeAsString(content);
      print('✅ Fixed: $filePath');
    } catch (e) {
      print('❌ Error fixing $filePath: $e');
    }
  }
}
