import 'package:flutter_invoice_app/services/migration/sources/migration_source.dart';
import 'package:flutter_invoice_app/services/migration/sources/sqlite_migration_source.dart';
import 'package:flutter_invoice_app/services/migration/sources/supabase_migration_source.dart';
import 'package:flutter_invoice_app/services/migration/sources/json_migration_source.dart';

class MigrationSourceFactory {
  final List<MigrationSource> _activeSources = [];

  MigrationSource createSource(String type, Map<String, dynamic> config) {
    MigrationSource source;
    
    switch (type.toLowerCase()) {
      case 'sqlite':
        source = SQLiteMigrationSource(config);
        break;
      case 'supabase':
        source = SupabaseMigrationSource(config);
        break;
      case 'json':
        source = JsonMigrationSource(config);
        break;
      case 'firebase':
        // TODO: Implement Firebase migration source
        throw UnsupportedError('Firebase migration source not yet implemented');
      default:
        throw ArgumentError('Unsupported source type: $type');
    }
    
    _activeSources.add(source);
    return source;
  }

  Future<void> dispose() async {
    for (final source in _activeSources) {
      try {
        await source.dispose();
      } catch (e) {
        print('Error disposing source: $e');
      }
    }
    _activeSources.clear();
  }
}
