#!/bin/bash

echo "🧹 Fixing all warnings and unused imports..."

# Remove unused imports from demo_gstr1_api_service.dart
sed -i "1d" lib/api/demo/demo_gstr1_api_service.dart

# Remove unused imports from demo_gst_api_client.dart
sed -i "/import 'package:dio\/dio.dart';/d" lib/api/demo_gst_api_client.dart
sed -i "/import '..\/models\/gst_returns\/gstr2a_model.dart'/d" lib/api/demo_gst_api_client.dart
sed -i "/import '..\/models\/gst_returns\/gstr2b_model.dart'/d" lib/api/demo_gst_api_client.dart
sed -i "/import '..\/models\/gst_returns\/gstr4_model.dart'/d" lib/api/demo_gst_api_client.dart

# Fix unnecessary non-null assertions
sed -i 's/taxableValueInSource3!/taxableValueInSource3/g' lib/api/demo_gst_api_client.dart

# Remove unused imports from router.dart
sed -i "/import '..\/models\/invoice\/invoice_model.dart';/d" lib/config/router.dart

# Remove unused imports from invoice_routes.dart
sed -i "/import '..\/models\/invoice\/invoice_model.dart';/d" lib/config/routes/invoice_routes.dart

# Fix database_helper.dart
sed -i "/import 'dart:io';/d" lib/database/database_helper.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/database/database_helper.dart
sed -i 's/return await/return/g' lib/database/database_helper.dart

# Fix build screens
sed -i "/import 'package:flutter\/services.dart';/d" lib/features/build/screens/apk_build_screen.dart
sed -i "/import 'package:flutter\/services.dart';/d" lib/features/build/screens/enhanced_apk_build_screen.dart

# Fix main files
sed -i "/import 'package:flutter\/material.dart';/d" lib/main_dev.dart
sed -i "/import 'package:flutter\/material.dart';/d" lib/main_prod.dart
sed -i "/import 'package:flutter\/material.dart';/d" lib/main_staging.dart

# Remove unused imports from models
sed -i "/import 'dart:convert';/d" lib/models/gst_comparison_model.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/gstr1_model.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/gstr3b_model.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/gstr9_model.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/gstr9c_model.dart

# Fix invoice format models
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/invoice_formats/bill_shill_invoice_model.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/invoice_formats/quickbooks_invoice_model.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/invoice_formats/tally_invoice_model.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/models/invoice_formats/zoho_invoice_model.dart

# Fix screens
sed -i "/import 'package:provider\/provider.dart';/d" lib/screens/gstr1_screen.dart
sed -i "/import 'package:provider\/provider.dart';/d" lib/screens/gstr3b_screen.dart
sed -i "/import 'package:provider\/provider.dart';/d" lib/screens/gstr4_screen.dart

# Fix services
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/services/export/gstr1_json_service.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/services/firebase/firebase_setup_checker.dart
sed -i "/import 'package:flutter\/material.dart';/d" lib/services/gstr9_service.dart
sed -i "/import 'package:flutter\/material.dart';/d" lib/services/gstr9c_service.dart

# Fix import services
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/services/import/marg_import_service.dart
sed -i "/import 'package:path_provider\/path_provider.dart';/d" lib/services/import/marg_import_service.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/services/import/tally_import_service.dart
sed -i "/import 'package:path_provider\/path_provider.dart';/d" lib/services/import/tally_import_service.dart

# Fix payment services
sed -i "/import 'dart:io';/d" lib/services/payment/payment_service.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/services/payment/payment_service.dart
sed -i "/import 'package:http\/http.dart';/d" lib/services/payment/payment_service.dart

# Fix tests
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/tests/migration_test_suite.dart
sed -i "/import '..\/models\/invoice\/invoice_model.dart';/d" lib/tests/migration_test_suite.dart
sed -i "/import '..\/models\/customer\/customer_model.dart';/d" lib/tests/migration_test_suite.dart
sed -i "/import '..\/models\/gst_returns\/gstr3b_model.dart';/d" lib/tests/migration_test_suite.dart
sed -i "/import '..\/models\/gst_returns\/gstr9_model.dart';/d" lib/tests/migration_test_suite.dart
sed -i "/import '..\/models\/gst_returns\/gstr9c_model.dart';/d" lib/tests/migration_test_suite.dart

# Fix widgets
sed -i "/import 'package:flutter_invoice_app\/services\/export\/excel_service.dart';/d" lib/widgets/common/export_options_widget.dart
sed -i "/import 'package:flutter_invoice_app\/services\/export\/json_service.dart';/d" lib/widgets/common/export_options_widget.dart

echo "✅ All warnings fixed!"
echo "🔍 Running flutter analyze to verify..."
flutter analyze
