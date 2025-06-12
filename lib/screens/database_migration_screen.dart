import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/migration/migration_config.dart';
import 'package:flutter_invoice_app/models/migration/migration_result.dart';
import 'package:flutter_invoice_app/models/migration/migration_status.dart';
import 'package:flutter_invoice_app/services/migration/database_migration_service.dart';
import 'package:flutter_invoice_app/utils/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DatabaseMigrationScreen extends StatefulWidget {
  const DatabaseMigrationScreen({Key? key}) : super(key: key);

  @override
  _DatabaseMigrationScreenState createState() => _DatabaseMigrationScreenState();
}

class _DatabaseMigrationScreenState extends State<DatabaseMigrationScreen> {
  final DatabaseMigrationService _migrationService = DatabaseMigrationService();
  
  // Source and target selection
  String _sourceType = 'sqlite';
  String _targetType = 'supabase';
  Map<String, dynamic> _sourceConfig = {};
  Map<String, dynamic> _targetConfig = {};
  
  // Data types to migrate
  bool _migrateInvoices = true;
  bool _migrateCustomers = true;
  bool _migrateGSTR1 = true;
  bool _migrateGSTR3B = true;
  bool _migrateGSTR9 = true;
  bool _migrateGSTR9C = true;
  bool _migrateSettings = true;
  
  // Options
  bool _validateAfterMigration = true;
  bool _cleanTargetBeforeMigration = false;
  
  // Migration status
  MigrationStatus _status = MigrationStatus.notStarted;
  MigrationResult? _result;
  bool _isMigrating = false;
  
  @override
  void initState() {
    super.initState();
    _initializeConfigs();
    _subscribeToMigrationProgress();
  }
  
  void _initializeConfigs() {
    // Initialize source config
    _sourceConfig = {
      'path': '',
    };
    
    // Initialize target config
    _targetConfig = {
      'url': '',
      'anonKey': '',
    };
  }
  
  void _subscribeToMigrationProgress() {
    _migrationService.progressStream.listen((status) {
      setState(() {
        _status = status;
      });
    });
  }
  
  Future<void> _startMigration() async {
    if (_isMigrating) return;
    
    setState(() {
      _isMigrating = true;
      _result = null;
    });
    
    try {
      // Create migration config
      final config = MigrationConfig(
        sourceType: _sourceType,
        sourceConfig: _sourceConfig,
        targetType: _targetType,
        targetConfig: _targetConfig,
        migrateInvoices: _migrateInvoices,
        migrateCustomers: _migrateCustomers,
        migrateGSTR1: _migrateGSTR1,
        migrateGSTR3B: _migrateGSTR3B,
        migrateGSTR9: _migrateGSTR9,
        migrateGSTR9C: _migrateGSTR9C,
        migrateSettings: _migrateSettings,
        validateAfterMigration: _validateAfterMigration,
        cleanTargetBeforeMigration: _cleanTargetBeforeMigration,
      );
      
      // Start migration
      final result = await _migrationService.migrateData(config);
      
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = MigrationResult(
          success: false,
          message: 'Migration failed',
          details: e.toString(),
        );
      });
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }
  
  Future<void> _selectSourcePath() async {
    if (_sourceType == 'sqlite') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );
      
      if (result != null) {
        setState(() {
          _sourceConfig['path'] = result.files.single.path!;
        });
      }
    } else if (_sourceType == 'json') {
      final directory = await FilePicker.platform.getDirectoryPath();
      
      if (directory != null) {
        setState(() {
          _sourceConfig['path'] = directory;
        });
      }
    }
  }
  
  Future<void> _selectTargetPath() async {
    if (_targetType == 'sqlite') {
      // For SQLite, we can either select an existing database or create a new one
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('SQLite Database'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Select existing database'),
                leading: const Icon(Icons.folder_open),
                onTap: () async {
                  Navigator.pop(context, 'existing');
                },
              ),
              ListTile(
                title: const Text('Create new database'),
                leading: const Icon(Icons.create_new_folder),
                onTap: () {
                  Navigator.pop(context, 'new');
                },
              ),
            ],
          ),
        ),
      );
      
      if (result == 'existing') {
        final fileResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['db'],
        );
        
        if (fileResult != null) {
          setState(() {
            _targetConfig['path'] = fileResult.files.single.path!;
          });
        }
      } else if (result == 'new') {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/migrated_data.db';
        
        setState(() {
          _targetConfig['path'] = path;
        });
      }
    } else if (_targetType == 'json') {
      final directory = await FilePicker.platform.getDirectoryPath();
      
      if (directory != null) {
        setState(() {
          _targetConfig['path'] = directory;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Migration Tool'),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSourceSection(),
            const SizedBox(height: 16),
            _buildTargetSection(),
            const SizedBox(height: 16),
            _buildDataTypesSection(),
            const SizedBox(height: 16),
            _buildOptionsSection(),
            const SizedBox(height: 24),
            _buildMigrationSection(),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultSection(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSourceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Source Database',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sourceType,
              decoration: const InputDecoration(
                labelText: 'Source Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sqlite',
                  child: Text('SQLite Database'),
                ),
                DropdownMenuItem(
                  value: 'supabase',
                  child: Text('Supabase'),
                ),
                DropdownMenuItem(
                  value: 'firebase',
                  child: Text('Firebase'),
                ),
                DropdownMenuItem(
                  value: 'json',
                  child: Text('JSON Files'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _sourceType = value!;
                  // Reset config when type changes
                  if (_sourceType == 'sqlite') {
                    _sourceConfig = {'path': ''};
                  } else if (_sourceType == 'supabase') {
                    _sourceConfig = {'url': '', 'anonKey': ''};
                  } else if (_sourceType == 'firebase') {
                    _sourceConfig = {};
                  } else if (_sourceType == 'json') {
                    _sourceConfig = {'path': ''};
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_sourceType == 'sqlite' || _sourceType == 'json') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _sourceType == 'sqlite' ? 'Database Path' : 'Directory Path',
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _sourceConfig['path']),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectSourcePath,
                    child: const Text('Browse'),
                  ),
                ],
              ),
            ] else if (_sourceType == 'supabase') ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Supabase URL',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _sourceConfig['url'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Supabase Anon Key',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _sourceConfig['anonKey'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _sourceConfig['email'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password (Optional)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _sourceConfig['password'] = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTargetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Database',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _targetType,
              decoration: const InputDecoration(
                labelText: 'Target Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sqlite',
                  child: Text('SQLite Database'),
                ),
                DropdownMenuItem(
                  value: 'supabase',
                  child: Text('Supabase'),
                ),
                DropdownMenuItem(
                  value: 'firebase',
                  child: Text('Firebase'),
                ),
                DropdownMenuItem(
                  value: 'json',
                  child: Text('JSON Files'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _targetType = value!;
                  // Reset config when type changes
                  if (_targetType == 'sqlite') {
                    _targetConfig = {'path': ''};
                  } else if (_targetType == 'supabase') {
                    _targetConfig = {'url': '', 'anonKey': ''};
                  } else if (_targetType == 'firebase') {
                    _targetConfig = {};
                  } else if (_targetType == 'json') {
                    _targetConfig = {'path': ''};
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_targetType == 'sqlite' || _targetType == 'json') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _targetType == 'sqlite' ? 'Database Path' : 'Directory Path',
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _targetConfig['path']),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectTargetPath,
                    child: const Text('Browse'),
                  ),
                ],
              ),
            ] else if (_targetType == 'supabase') ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Supabase URL',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _targetConfig['url'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Supabase Anon Key',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _targetConfig['anonKey'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _targetConfig['email'] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password (Optional)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _targetConfig['password'] = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataTypesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Types to Migrate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildCheckboxTile(
                  title: 'Invoices',
                  value: _migrateInvoices,
                  onChanged: (value) {
                    setState(() {
                      _migrateInvoices = value!;
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'Customers',
                  value: _migrateCustomers,
                  onChanged: (value) {
                    setState(() {
                      _migrateCustomers = value!;
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'GSTR1 Returns',
                  value: _migrateGSTR1,
                  onChanged: (value) {
                    setState(() {
                      _migrateGSTR1 = value!;
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'GSTR3B Returns',
                  value: _migrateGSTR3B,
                  onChanged: (value) {
                    setState(() {
                      _migrateGSTR3B = value!;
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'GSTR9 Returns',
                  value: _migrateGSTR9,
                  onChanged: (value) {
                    setState(() {
                      _migrateGSTR9 = value!;
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'GSTR9C Returns',
                  value: _migrateGSTR9C,
                  onChanged: (value) {
                    setState(() {
                      _migrateGSTR9C = value!;
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'Settings',
                  value: _migrateSettings,
                  onChanged: (value) {
                    setState(() {
                      _migrateSettings = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Migration Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildCheckboxTile(
              title: 'Validate after migration',
              value: _validateAfterMigration,
              onChanged: (value) {
                setState(() {
                  _validateAfterMigration = value!;
                });
              },
            ),
            _buildCheckboxTile(
              title: 'Clean target database before migration',
              value: _cleanTargetBeforeMigration,
              onChanged: (value) {
                setState(() {
                  _cleanTargetBeforeMigration = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMigrationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Migration Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _status.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(_status.type),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _status.statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(_status.type),
                  ),
                ),
                Text('${(_status.progress * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Text(_status.message),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isMigrating ? null : _startMigration,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isMigrating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Migrating...'),
                        ],
                      )
                    : const Text('Start Migration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultSection() {
    return Card(
      color: _result!.success ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _result!.success ? Icons.check_circle : Icons.error,
                  color: _result!.success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Migration Result',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _result!.success ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _result!.message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_result!.details),
            if (_result!.data != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Migration Summary:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._result!.data!.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('${entry.key}: ${entry.value} items'),
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      width: 200,
      child: CheckboxListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
  
  Color _getStatusColor(MigrationStatusType type) {
    switch (type) {
      case MigrationStatusType.notStarted:
        return Colors.grey;
      case MigrationStatusType.starting:
        return Colors.blue;
      case MigrationStatusType.initializing:
        return Colors.blue;
      case MigrationStatusType.inProgress:
        return Colors.blue;
      case MigrationStatusType.validating:
        return Colors.orange;
      case MigrationStatusType.completed:
        return Colors.green;
      case MigrationStatusType.failed:
        return Colors.red;
      case MigrationStatusType.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  @override
  void dispose() {
    _migrationService.dispose();
    super.dispose();
  }
}
