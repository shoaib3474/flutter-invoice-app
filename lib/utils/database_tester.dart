import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_invoice_app/config/supabase_config.dart';

class DatabaseTester {
  final SupabaseClient _client = SupabaseConfig.client;
  
  /// Test database connection
  Future<bool> testConnection() async {
    try {
      // Simple query to test connection
      final response = await _client
          .from('health_check')
          .select()
          .limit(1)
          .execute();
      
      return response.status == 200;
    } catch (e) {
      debugPrint('Database connection test failed: $e');
      return false;
    }
  }
  
  /// Test table existence
  Future<Map<String, bool>> testTables() async {
    final tables = [
      SupabaseConfig.invoicesTable,
      SupabaseConfig.invoiceItemsTable,
      SupabaseConfig.customersTable,
      SupabaseConfig.productsTable,
      SupabaseConfig.gstr1Table,
      SupabaseConfig.gstr3bTable,
      SupabaseConfig.gstr9Table,
      SupabaseConfig.gstr9cTable,
    ];
    
    final results = <String, bool>{};
    
    for (final table in tables) {
      try {
        final response = await _client
            .from(table)
            .select('count')
            .limit(1)
            .execute();
        
        results[table] = response.status == 200;
      } catch (e) {
        debugPrint('Table test failed for $table: $e');
        results[table] = false;
      }
    }
    
    return results;
  }
  
  /// Test write operation
  Future<bool> testWrite() async {
    try {
      final testId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Insert test record
      final response = await _client
          .from('test_writes')
          .insert({
            'id': testId,
            'test_value': 'Test write at ${DateTime.now().toIso8601String()}',
            'user_id': _client.auth.currentUser?.id ?? 'anonymous'
          })
          .execute();
      
      // Clean up test record
      await _client
          .from('test_writes')
          .delete()
          .eq('id', testId)
          .execute();
      
      return response.status == 201;
    } catch (e) {
      debugPrint('Write test failed: $e');
      return false;
    }
  }
  
  /// Test read operation
  Future<bool> testRead() async {
    try {
      // Read from a table
      final response = await _client
          .from(SupabaseConfig.invoicesTable)
          .select()
          .limit(1)
          .execute();
      
      return response.status == 200;
    } catch (e) {
      debugPrint('Read test failed: $e');
      return false;
    }
  }
  
  /// Run all tests
  Future<Map<String, dynamic>> runAllTests() async {
    final results = <String, dynamic>{};
    
    results['connection'] = await testConnection();
    results['tables'] = await testTables();
    results['write'] = await testWrite();
    results['read'] = await testRead();
    
    return results;
  }
}
