import 'package:flutter_invoice_app/services/migration/targets/migration_target.dart';
import 'package:flutter_invoice_app/services/migration/targets/sqlite_migration_target.dart';
import 'package:flutter_invoice_app/services/migration/targets/supabase_migration_target.dart';
import 'package:flutter_invoice_app/services/migration/targets/json_migration_target.dart';

class MigrationTargetFactory {
  final List<MigrationTarget> _activeTargets = [];

  MigrationTarget createTarget(String type, Map<String, dynamic> config) {
    MigrationTarget target;
    
    switch (type.toLowerCase()) {
      case 'sqlite':
        target = SQLiteMigrationTarget(config);
        break;
      case 'supabase':
        target = SupabaseMigrationTarget(config);
        break;
      case 'json':
        target = JsonMigrationTarget(config);
        break;
      case 'firebase':
        // TODO: Implement Firebase migration target
        throw UnsupportedError('Firebase migration target not yet implemented');
      default:
        throw ArgumentError('Unsupported target type: $type');
    }
    
    _activeTargets.add(target);
    return target;
  }

  Future<void> dispose() async {
    for (final target in _activeTargets) {
      try {
        await target.dispose();
      } catch (e) {
        print('Error disposing target: $e');
      }
    }
    _activeTargets.clear();
  }
}
