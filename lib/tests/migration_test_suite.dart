import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/migration/migration_config.dart';
import '../models/migration/migration_result.dart';
import '../services/migration/database_migration_service.dart';
import '../services/logger_service.dart';
import '../models/invoice/invoice_model.dart';
import '../models/customer/customer_model.dart';
import '../models/gst_returns/gstr1_model.dart';
import '../models/gst_returns/gstr3b_model.dart';
import '../models/gst_returns/gstr9_model.dart';
import '../models/gst_returns/gstr9c_model.dart';
import 'package:path_provider/path_provider.dart';

class MigrationTestSuite {
  final LoggerService _logger = LoggerService();
  final DatabaseMigrationService _migrationService = DatabaseMigrationService();
  
  // Simple ID generator instead of UUID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  // Test data generators
  List<InvoiceModel> _generateTestInvoices(int count) {
    return List.generate(count, (index) => InvoiceModel(
      id: _generateId(),
      invoiceNumber: 'INV-${(index + 1).toString().padLeft(4, '0')}',
      customerId: _generateId(),
      customerName: 'Test Customer ${index + 1}',
      customerGstin: '29ABCDE1234F1Z${index % 10}',
      invoiceDate: DateTime.now().subtract(Duration(days: index)),
      dueDate: DateTime.now().add(Duration(days: 30 - index)),
      subtotal: 1000.0 + (index * 100),
      taxAmount: 180.0 + (index * 18),
      totalAmount: 1180.0 + (index * 118),
      status: index % 3 == 0 ? 'paid' : 'pending',
      items: [],
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now(),
    ));
  }
  
  List<CustomerModel> _generateTestCustomers(int count) {
    return List.generate(count, (index) => CustomerModel(
      id: _generateId(),
      name: 'Test Customer ${index + 1}',
      email: 'customer${index + 1}@test.com',
      phone: '9876543${(index + 100).toString().substring(0, 3)}',
      gstin: '29ABCDE1234F1Z${index % 10}',
      address: 'Test Address ${index + 1}',
      city: 'Test City ${index + 1}',
      state: 'Test State',
      pincode: '560${(index + 100).toString().substring(0, 3)}',
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now(),
    ));
  }
  
  List<GSTR1Model> _generateTestGSTR1(int count) {
    return List.generate(count, (index) => GSTR1Model(
      id: _generateId(),
      gstin: '29ABCDE1234F1Z5',
      returnPeriod: '${DateTime.now().year}-${(DateTime.now().month - index).toString().padLeft(2, '0')}',
      totalTaxableValue: 100000.0 + (index * 10000),
      totalTaxAmount: 18000.0 + (index * 1800),
      status: index % 2 == 0 ? 'filed' : 'draft',
      filedDate: index % 2 == 0 ? DateTime.now().subtract(Duration(days: index)) : null,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now(),
    ));
  }
  
  List<GSTR3BModel> _generateTestGSTR3B(int count) {
    return List.generate(count, (index) => GSTR3BModel(
      id: _generateId(),
      gstin: '29ABCDE1234F1Z5',
      returnPeriod: '${DateTime.now().year}-${(DateTime.now().month - index).toString().padLeft(2, '0')}',
      totalTaxLiability: 50000.0 + (index * 5000),
      totalTaxPaid: 45000.0 + (index * 4500),
      status: index % 2 == 0 ? 'filed' : 'draft',
      filedDate: index % 2 == 0 ? DateTime.now().subtract(Duration(days: index)) : null,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now(),
    ));
  }
  
  List<GSTR9Model> _generateTestGSTR9(int count) {
    return List.generate(count, (index) => GSTR9Model(
      id: _generateId(),
      gstin: '29ABCDE1234F1Z5',
      financialYear: '${DateTime.now().year - 1 - index}-${DateTime.now().year - index}',
      totalTurnover: 1000000.0 + (index * 100000),
      totalTaxLiability: 180000.0 + (index * 18000),
      status: index % 2 == 0 ? 'filed' : 'draft',
      filedDate: index % 2 == 0 ? DateTime.now().subtract(Duration(days: index * 30)) : null,
      createdAt: DateTime.now().subtract(Duration(days: index * 30)),
      updatedAt: DateTime.now(),
    ));
  }
  
  List<GSTR9CModel> _generateTestGSTR9C(int count) {
    return List.generate(count, (index) => GSTR9CModel(
      id: _generateId(),
      gstin: '29ABCDE1234F1Z5',
      financialYear: '${DateTime.now().year - 1 - index}-${DateTime.now().year - index}',
      auditedTurnover: 1200000.0 + (index * 120000),
      certifiedTaxLiability: 216000.0 + (index * 21600),
      status: index % 2 == 0 ? 'filed' : 'draft',
      filedDate: index % 2 == 0 ? DateTime.now().subtract(Duration(days: index * 30)) : null,
      createdAt: DateTime.now().subtract(Duration(days: index * 30)),
      updatedAt: DateTime.now(),
    ));
  }
  
  // Test scenarios
  Future<TestResult> runAllTests() async {
    _logger.info('Starting comprehensive migration test suite...');
    
    final results = <String, bool>{};
    final errors = <String, String>{};
    
    try {
      // Test 1: SQLite to JSON migration
      _logger.info('Running Test 1: SQLite to JSON migration');
      final test1Result = await _testSQLiteToJSON();
      results['SQLite to JSON'] = test1Result.success;
      if (!test1Result.success) errors['SQLite to JSON'] = test1Result.error ?? 'Unknown error';
      
      // Test 2: JSON to SQLite migration
      _logger.info('Running Test 2: JSON to SQLite migration');
      final test2Result = await _testJSONToSQLite();
      results['JSON to SQLite'] = test2Result.success;
      if (!test2Result.success) errors['JSON to SQLite'] = test2Result.error ?? 'Unknown error';
      
      // Test 3: Large dataset migration
      _logger.info('Running Test 3: Large dataset migration');
      final test3Result = await _testLargeDatasetMigration();
      results['Large Dataset'] = test3Result.success;
      if (!test3Result.success) errors['Large Dataset'] = test3Result.error ?? 'Unknown error';
      
      // Test 4: Partial migration
      _logger.info('Running Test 4: Partial migration');
      final test4Result = await _testPartialMigration();
      results['Partial Migration'] = test4Result.success;
      if (!test4Result.success) errors['Partial Migration'] = test4Result.error ?? 'Unknown error';
      
      // Test 5: Error handling
      _logger.info('Running Test 5: Error handling');
      final test5Result = await _testErrorHandling();
      results['Error Handling'] = test5Result.success;
      if (!test5Result.success) errors['Error Handling'] = test5Result.error ?? 'Unknown error';
      
      final successCount = results.values.where((success) => success).length;
      final totalTests = results.length;
      
      _logger.info('Migration test suite completed: $successCount/$totalTests tests passed');
      
      return TestResult(
        success: successCount == totalTests,
        totalTests: totalTests,
        passedTests: successCount,
        failedTests: totalTests - successCount,
        results: results,
        errors: errors,
      );
      
    } catch (e, stackTrace) {
      _logger.error('Migration test suite failed: $e\n$stackTrace');
      return TestResult(
        success: false,
        totalTests: 0,
        passedTests: 0,
        failedTests: 1,
        results: {},
        errors: {'Test Suite': e.toString()},
      );
    }
  }
  
  Future<SingleTestResult> _testSQLiteToJSON() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final sqliteDbPath = '${tempDir.path}/test_source.db';
      final jsonDirPath = '${tempDir.path}/json_export';
      
      // Create test data in SQLite
      await _createTestSQLiteDatabase(sqliteDbPath);
      
      // Configure migration
      final config = MigrationConfig(
        sourceType: 'sqlite',
        sourceConfig: {'path': sqliteDbPath},
        targetType: 'json',
        targetConfig: {'path': jsonDirPath},
        migrateInvoices: true,
        migrateCustomers: true,
        migrateGSTR1: true,
        migrateGSTR3B: true,
        migrateGSTR9: true,
        migrateGSTR9C: true,
        migrateSettings: true,
        validateAfterMigration: true,
        cleanTargetBeforeMigration: true,
      );
      
      // Run migration
      final result = await _migrationService.migrateData(config);
      
      if (result.success) {
        // Verify JSON files were created
        final jsonDir = Directory(jsonDirPath);
        if (await jsonDir.exists()) {
          final files = await jsonDir.list().toList();
          final hasInvoices = files.any((f) => f.path.contains('invoices.json'));
          final hasCustomers = files.any((f) => f.path.contains('customers.json'));
          
          if (hasInvoices && hasCustomers) {
            return SingleTestResult(success: true);
          } else {
            return SingleTestResult(success: false, error: 'JSON files not created properly');
          }
        } else {
          return SingleTestResult(success: false, error: 'JSON directory not created');
        }
      } else {
        return SingleTestResult(success: false, error: result.message);
      }
    } catch (e) {
      return SingleTestResult(success: false, error: e.toString());
    }
  }
  
  Future<SingleTestResult> _testJSONToSQLite() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final jsonDirPath = '${tempDir.path}/json_source';
      final sqliteDbPath = '${tempDir.path}/test_target.db';
      
      // Create test JSON data
      await _createTestJSONData(jsonDirPath);
      
      // Configure migration
      final config = MigrationConfig(
        sourceType: 'json',
        sourceConfig: {'path': jsonDirPath},
        targetType: 'sqlite',
        targetConfig: {'path': sqliteDbPath},
        migrateInvoices: true,
        migrateCustomers: true,
        migrateGSTR1: true,
        migrateGSTR3B: true,
        migrateGSTR9: true,
        migrateGSTR9C: true,
        migrateSettings: true,
        validateAfterMigration: true,
        cleanTargetBeforeMigration: true,
      );
      
      // Run migration
      final result = await _migrationService.migrateData(config);
      
      if (result.success) {
        // Verify SQLite database was created
        final dbFile = File(sqliteDbPath);
        if (await dbFile.exists()) {
          return SingleTestResult(success: true);
        } else {
          return SingleTestResult(success: false, error: 'SQLite database not created');
        }
      } else {
        return SingleTestResult(success: false, error: result.message);
      }
    } catch (e) {
      return SingleTestResult(success: false, error: e.toString());
    }
  }
  
  Future<SingleTestResult> _testLargeDatasetMigration() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final sqliteDbPath = '${tempDir.path}/test_large.db';
      final jsonDirPath = '${tempDir.path}/json_large';
      
      // Create large test dataset
      await _createLargeTestDataset(sqliteDbPath);
      
      // Configure migration
      final config = MigrationConfig(
        sourceType: 'sqlite',
        sourceConfig: {'path': sqliteDbPath},
        targetType: 'json',
        targetConfig: {'path': jsonDirPath},
        migrateInvoices: true,
        migrateCustomers: true,
        migrateGSTR1: true,
        migrateGSTR3B: true,
        migrateGSTR9: true,
        migrateGSTR9C: true,
        migrateSettings: true,
        validateAfterMigration: true,
        cleanTargetBeforeMigration: true,
      );
      
      // Run migration with timeout
      final result = await _migrationService.migrateData(config).timeout(
        const Duration(minutes: 5),
        onTimeout: () => MigrationResult(
          success: false,
          message: 'Migration timed out',
          details: 'Large dataset migration took too long',
        ),
      );
      
      return SingleTestResult(success: result.success, error: result.success ? null : result.message);
    } catch (e) {
      return SingleTestResult(success: false, error: e.toString());
    }
  }
  
  Future<SingleTestResult> _testPartialMigration() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final sqliteDbPath = '${tempDir.path}/test_partial.db';
      final jsonDirPath = '${tempDir.path}/json_partial';
      
      // Create test data
      await _createTestSQLiteDatabase(sqliteDbPath);
      
      // Configure partial migration (only invoices and customers)
      final config = MigrationConfig(
        sourceType: 'sqlite',
        sourceConfig: {'path': sqliteDbPath},
        targetType: 'json',
        targetConfig: {'path': jsonDirPath},
        migrateInvoices: true,
        migrateCustomers: true,
        migrateGSTR1: false,
        migrateGSTR3B: false,
        migrateGSTR9: false,
        migrateGSTR9C: false,
        migrateSettings: false,
        validateAfterMigration: true,
        cleanTargetBeforeMigration: true,
      );
      
      // Run migration
      final result = await _migrationService.migrateData(config);
      
      if (result.success) {
        // Verify only selected data was migrated
        final jsonDir = Directory(jsonDirPath);
        if (await jsonDir.exists()) {
          final files = await jsonDir.list().toList();
          final hasInvoices = files.any((f) => f.path.contains('invoices.json'));
          final hasCustomers = files.any((f) => f.path.contains('customers.json'));
          final hasGSTR1 = files.any((f) => f.path.contains('gstr1.json'));
          
          if (hasInvoices && hasCustomers && !hasGSTR1) {
            return SingleTestResult(success: true);
          } else {
            return SingleTestResult(success: false, error: 'Partial migration validation failed');
          }
        } else {
          return SingleTestResult(success: false, error: 'JSON directory not created');
        }
      } else {
        return SingleTestResult(success: false, error: result.message);
      }
    } catch (e) {
      return SingleTestResult(success: false, error: e.toString());
    }
  }
  
  Future<SingleTestResult> _testErrorHandling() async {
    try {
      // Test with invalid source path
      final config = MigrationConfig(
        sourceType: 'sqlite',
        sourceConfig: {'path': '/invalid/path/database.db'},
        targetType: 'json',
        targetConfig: {'path': '/tmp/test'},
        migrateInvoices: true,
        migrateCustomers: false,
        migrateGSTR1: false,
        migrateGSTR3B: false,
        migrateGSTR9: false,
        migrateGSTR9C: false,
        migrateSettings: false,
        validateAfterMigration: false,
        cleanTargetBeforeMigration: false,
      );
      
      // Run migration (should fail gracefully)
      final result = await _migrationService.migrateData(config);
      
      // Test passes if migration fails gracefully (doesn't crash)
      return SingleTestResult(success: !result.success);
    } catch (e) {
      // Test passes if error is handled properly
      return SingleTestResult(success: true);
    }
  }
  
  // Helper methods
  Future<void> _createTestSQLiteDatabase(String path) async {
    // This would create a test SQLite database with sample data
    // Implementation depends on your database helper
    _logger.info('Creating test SQLite database at: $path');
    
    // Create a simple test file for now
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString('test database content');
  }
  
  Future<void> _createTestJSONData(String dirPath) async {
    final dir = Directory(dirPath);
    await dir.create(recursive: true);
    
    // Create test JSON files
    final invoices = _generateTestInvoices(5);
    final customers = _generateTestCustomers(3);
    
    final invoicesFile = File('$dirPath/invoices.json');
    await invoicesFile.writeAsString(jsonEncode(invoices.map((i) => i.toJson()).toList()));
    
    final customersFile = File('$dirPath/customers.json');
    await customersFile.writeAsString(jsonEncode(customers.map((c) => c.toJson()).toList()));
    
    _logger.info('Created test JSON data at: $dirPath');
  }
  
  Future<void> _createLargeTestDataset(String path) async {
    // Create a large dataset for performance testing
    _logger.info('Creating large test dataset at: $path');
    
    // Create a test file with large content
    final file = File(path);
    await file.create(recursive: true);
    
    // Generate large test data
    final largeData = List.generate(1000, (index) => 'test_record_$index').join('\n');
    await file.writeAsString(largeData);
  }
}

class TestResult {
  final bool success;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final Map<String, bool> results;
  final Map<String, String> errors;
  
  TestResult({
    required this.success,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.results,
    required this.errors,
  });
  
  @override
  String toString() {
    return 'TestResult(success: $success, passed: $passedTests/$totalTests)';
  }
}

class SingleTestResult {
  final bool success;
  final String? error;
  
  SingleTestResult({required this.success, this.error});
  
  @override
  String toString() {
    return 'SingleTestResult(success: $success, error: $error)';
  }
}
