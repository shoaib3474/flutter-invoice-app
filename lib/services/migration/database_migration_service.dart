import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:flutter_invoice_app/models/migration/migration_config.dart';
import 'package:flutter_invoice_app/models/migration/migration_result.dart';
import 'package:flutter_invoice_app/models/migration/migration_status.dart';
import 'package:flutter_invoice_app/services/migration/migration_source_factory.dart';
import 'package:flutter_invoice_app/services/migration/migration_target_factory.dart';
import 'package:flutter_invoice_app/services/migration/sources/migration_source.dart';
import 'package:flutter_invoice_app/services/migration/targets/migration_target.dart';
import 'package:flutter_invoice_app/services/logger_service.dart';

class DatabaseMigrationService {
  final LoggerService _logger = LoggerService();
  final MigrationSourceFactory _sourceFactory = MigrationSourceFactory();
  final MigrationTargetFactory _targetFactory = MigrationTargetFactory();
  
  // Stream controllers for progress updates
  final _progressController = StreamController<MigrationStatus>.broadcast();
  Stream<MigrationStatus> get progressStream => _progressController.stream;
  
  // Migration state
  MigrationStatus _status = MigrationStatus.notStarted;
  MigrationStatus get status => _status;
  
  // Singleton pattern
  static final DatabaseMigrationService _instance = DatabaseMigrationService._internal();
  factory DatabaseMigrationService() => _instance;
  DatabaseMigrationService._internal();
  
  // Perform database migration
  Future<MigrationResult> migrateData(MigrationConfig config) async {
    try {
      // Update status to starting
      _updateStatus(MigrationStatus.starting, 'Starting migration process');
      
      // Validate configuration
      if (!_validateConfig(config)) {
        return MigrationResult(
          success: false,
          message: 'Invalid migration configuration',
          details: 'Please check source and target database settings',
        );
      }
      
      // Create source and target handlers
      final source = _sourceFactory.createSource(config.sourceType, config.sourceConfig);
      final target = _targetFactory.createTarget(config.targetType, config.targetConfig);
      
      // Initialize source and target
      _updateStatus(MigrationStatus.initializing, 'Initializing source and target databases');
      await source.initialize();
      await target.initialize();
      
      // Start migration
      _updateStatus(MigrationStatus.inProgress, 'Migration in progress');
      
      // Migrate each data type
      final results = <String, dynamic>{};
      int totalEntities = 0;
      int migratedEntities = 0;
      
      // Migrate invoices if selected
      if (config.migrateInvoices) {
        _updateStatus(MigrationStatus.inProgress, 'Migrating invoices', progress: 0.1);
        final invoices = await source.getInvoices();
        totalEntities += invoices.length;
        
        for (int i = 0; i < invoices.length; i++) {
          await target.saveInvoice(invoices[i]);
          migratedEntities++;
          
          // Update progress
          final progress = 0.1 + (0.2 * (i + 1) / invoices.length);
          _updateStatus(
            MigrationStatus.inProgress, 
            'Migrated ${i + 1} of ${invoices.length} invoices',
            progress: progress
          );
        }
        
        results['invoices'] = invoices.length;
      }
      
      // Migrate customers if selected
      if (config.migrateCustomers) {
        _updateStatus(MigrationStatus.inProgress, 'Migrating customers', progress: 0.3);
        final customers = await source.getCustomers();
        totalEntities += customers.length;
        
        for (int i = 0; i < customers.length; i++) {
          await target.saveCustomer(customers[i]);
          migratedEntities++;
          
          // Update progress
          final progress = 0.3 + (0.1 * (i + 1) / customers.length);
          _updateStatus(
            MigrationStatus.inProgress, 
            'Migrated ${i + 1} of ${customers.length} customers',
            progress: progress
          );
        }
        
        results['customers'] = customers.length;
      }
      
      // Migrate GSTR1 returns if selected
      if (config.migrateGSTR1) {
        _updateStatus(MigrationStatus.inProgress, 'Migrating GSTR1 returns', progress: 0.4);
        final gstr1Returns = await source.getGSTR1Returns();
        totalEntities += gstr1Returns.length;
        
        for (int i = 0; i < gstr1Returns.length; i++) {
          await target.saveGSTR1(gstr1Returns[i]);
          migratedEntities++;
          
          // Update progress
          final progress = 0.4 + (0.1 * (i + 1) / gstr1Returns.length);
          _updateStatus(
            MigrationStatus.inProgress, 
            'Migrated ${i + 1} of ${gstr1Returns.length} GSTR1 returns',
            progress: progress
          );
        }
        
        results['gstr1'] = gstr1Returns.length;
      }
      
      // Migrate GSTR3B returns if selected
      if (config.migrateGSTR3B) {
        _updateStatus(MigrationStatus.inProgress, 'Migrating GSTR3B returns', progress: 0.5);
        final gstr3bReturns = await source.getGSTR3BReturns();
        totalEntities += gstr3bReturns.length;
        
        for (int i = 0; i < gstr3bReturns.length; i++) {
          await target.saveGSTR3B(gstr3bReturns[i]);
          migratedEntities++;
          
          // Update progress
          final progress = 0.5 + (0.1 * (i + 1) / gstr3bReturns.length);
          _updateStatus(
            MigrationStatus.inProgress, 
            'Migrated ${i + 1} of ${gstr3bReturns.length} GSTR3B returns',
            progress: progress
          );
        }
        
        results['gstr3b'] = gstr3bReturns.length;
      }
      
      // Migrate GSTR9 returns if selected
      if (config.migrateGSTR9) {
        _updateStatus(MigrationStatus.inProgress, 'Migrating GSTR9 returns', progress: 0.6);
        final gstr9Returns = await source.getGSTR9Returns();
        totalEntities += gstr9Returns.length;
        
        for (int i = 0; i < gstr9Returns.length; i++) {
          await target.saveGSTR9(gstr9Returns[i]);
          migratedEntities++;
          
          // Update progress
          final progress = 0.6 + (0.1 * (i + 1) / gstr9Returns.length);
          _updateStatus(
            MigrationStatus.inProgress, 
            'Migrated ${i + 1} of ${gstr9Returns.length} GSTR9 returns',
            progress: progress
          );
        }
        
        results['gstr9'] = gstr9Returns.length;
      }
      
      // Migrate GSTR9C returns if selected
      if (config.migrateGSTR9C) {
        _updateStatus(MigrationStatus.inProgress, 'Migrating GSTR9C returns', progress: 0.7);
        final gstr9cReturns = await source.getGSTR9CReturns();
        totalEntities += gstr9cReturns.length;
        
        for (int i = 0; i < gstr9cReturns.length; i++) {
          await target.saveGSTR9C(gstr9cReturns[i]);
          migratedEntities++;
          
          // Update progress
          final progress = 0.7 + (0.1 * (i + 1) / gstr9cReturns.length);
          _updateStatus(
            MigrationStatus.inProgress, 
            'Migrated ${i + 1} of ${gstr9cReturns.length} GSTR9C returns',
            progress: progress
          );
        }
        
        results['gstr9c'] = gstr9cReturns.length;
      }
      
      // Migrate settings if selected
      if (config.migrateSettings) {
        _updateStatus(MigrationStatus.inProgress, 'Migrating settings', progress: 0.8);
        final settings = await source.getSettings();
        totalEntities += settings.length;
        
        for (int i = 0; i < settings.length; i++) {
          await target.saveSetting(settings[i].key, settings[i].value);
          migratedEntities++;
          
          // Update progress
          final progress = 0.8 + (0.1 * (i + 1) / settings.length);
          _updateStatus(
            MigrationStatus.inProgress, 
            'Migrated ${i + 1} of ${settings.length} settings',
            progress: progress
          );
        }
        
        results['settings'] = settings.length;
      }
      
      // Validate migration
      _updateStatus(MigrationStatus.validating, 'Validating migrated data', progress: 0.9);
      final validationResult = await _validateMigration(source, target, config);
      
      // Finalize migration
      if (validationResult.success) {
        _updateStatus(MigrationStatus.completed, 'Migration completed successfully', progress: 1.0);
        
        return MigrationResult(
          success: true,
          message: 'Migration completed successfully',
          details: 'Migrated $migratedEntities of $totalEntities entities',
          data: results,
        );
      } else {
        _updateStatus(MigrationStatus.failed, 'Migration validation failed', progress: 1.0);
        
        return MigrationResult(
          success: false,
          message: 'Migration validation failed',
          details: validationResult.details,
          data: results,
        );
      }
    } catch (e, stackTrace) {
      _logger.error('Migration error: $e\n$stackTrace');
      _updateStatus(MigrationStatus.failed, 'Migration failed: $e', progress: 1.0);
      
      return MigrationResult(
        success: false,
        message: 'Migration failed',
        details: e.toString(),
      );
    } finally {
      // Clean up resources
      await _sourceFactory.dispose();
      await _targetFactory.dispose();
    }
  }
  
  // Validate migration configuration
  bool _validateConfig(MigrationConfig config) {
    if (config.sourceType == config.targetType && 
        config.sourceConfig['path'] == config.targetConfig['path']) {
      _logger.error('Source and target databases cannot be the same');
      return false;
    }
    
    if (!config.migrateInvoices && 
        !config.migrateCustomers && 
        !config.migrateGSTR1 && 
        !config.migrateGSTR3B && 
        !config.migrateGSTR9 && 
        !config.migrateGSTR9C && 
        !config.migrateSettings) {
      _logger.error('No data types selected for migration');
      return false;
    }
    
    return true;
  }
  
  // Validate migrated data
  Future<MigrationResult> _validateMigration(
    MigrationSource source, 
    MigrationTarget target,
    MigrationConfig config
  ) async {
    try {
      final validationErrors = <String>[];
      
      // Validate invoices
      if (config.migrateInvoices) {
        final sourceInvoices = await source.getInvoices();
        final targetInvoices = await target.getInvoices();
        
        if (sourceInvoices.length != targetInvoices.length) {
          validationErrors.add('Invoice count mismatch: Source=${sourceInvoices.length}, Target=${targetInvoices.length}');
        }
      }
      
      // Validate customers
      if (config.migrateCustomers) {
        final sourceCustomers = await source.getCustomers();
        final targetCustomers = await target.getCustomers();
        
        if (sourceCustomers.length != targetCustomers.length) {
          validationErrors.add('Customer count mismatch: Source=${sourceCustomers.length}, Target=${targetCustomers.length}');
        }
      }
      
      // Validate GSTR1 returns
      if (config.migrateGSTR1) {
        final sourceReturns = await source.getGSTR1Returns();
        final targetReturns = await target.getGSTR1Returns();
        
        if (sourceReturns.length != targetReturns.length) {
          validationErrors.add('GSTR1 count mismatch: Source=${sourceReturns.length}, Target=${targetReturns.length}');
        }
      }
      
      // Validate GSTR3B returns
      if (config.migrateGSTR3B) {
        final sourceReturns = await source.getGSTR3BReturns();
        final targetReturns = await target.getGSTR3BReturns();
        
        if (sourceReturns.length != targetReturns.length) {
          validationErrors.add('GSTR3B count mismatch: Source=${sourceReturns.length}, Target=${targetReturns.length}');
        }
      }
      
      // Validate GSTR9 returns
      if (config.migrateGSTR9) {
        final sourceReturns = await source.getGSTR9Returns();
        final targetReturns = await target.getGSTR9Returns();
        
        if (sourceReturns.length != targetReturns.length) {
          validationErrors.add('GSTR9 count mismatch: Source=${sourceReturns.length}, Target=${targetReturns.length}');
        }
      }
      
      // Validate GSTR9C returns
      if (config.migrateGSTR9C) {
        final sourceReturns = await source.getGSTR9CReturns();
        final targetReturns = await target.getGSTR9CReturns();
        
        if (sourceReturns.length != targetReturns.length) {
          validationErrors.add('GSTR9C count mismatch: Source=${sourceReturns.length}, Target=${targetReturns.length}');
        }
      }
      
      // Validate settings
      if (config.migrateSettings) {
        final sourceSettings = await source.getSettings();
        final targetSettings = await target.getSettings();
        
        if (sourceSettings.length != targetSettings.length) {
          validationErrors.add('Settings count mismatch: Source=${sourceSettings.length}, Target=${targetSettings.length}');
        }
      }
      
      if (validationErrors.isEmpty) {
        return MigrationResult(
          success: true,
          message: 'Validation successful',
          details: 'All data was migrated correctly',
        );
      } else {
        return MigrationResult(
          success: false,
          message: 'Validation failed',
          details: validationErrors.join('\n'),
        );
      }
    } catch (e) {
      _logger.error('Validation error: $e');
      return MigrationResult(
        success: false,
        message: 'Validation failed',
        details: 'Error during validation: $e',
      );
    }
  }
  
  // Update migration status
  void _updateStatus(MigrationStatus status, String message, {double? progress}) {
    _status = status.copyWith(
      message: message,
      progress: progress ?? status.progress,
      timestamp: DateTime.now(),
    );
    
    _progressController.add(_status);
    _logger.info('Migration status: ${_status.statusText} - $message (${(_status.progress * 100).toStringAsFixed(1)}%)');
  }
  
  // Dispose resources
  void dispose() {
    _progressController.close();
  }
}
