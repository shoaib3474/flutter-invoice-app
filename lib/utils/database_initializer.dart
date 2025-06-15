// ignore_for_file: avoid_print

import 'package:flutter_invoice_app/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseInitializer {
  static final SupabaseClient _client = SupabaseConfig.client as SupabaseClient;

  static Future<void> initializeDatabase() async {
    try {
      // Check if tables exist, if not create them
      await _createTables();
      print('Database initialization completed successfully');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<void> _createTables() async {
    // We don't need to create tables manually as they should be created in the Supabase dashboard
    // This method can be used to verify tables exist or perform migrations

    // Verify essential tables exist
    await _verifyTable(SupabaseConfig.invoicesTable);
    await _verifyTable(SupabaseConfig.invoiceItemsTable);
    await _verifyTable(SupabaseConfig.customersTable);
    await _verifyTable(SupabaseConfig.gstr1Table);
    await _verifyTable(SupabaseConfig.gstr3bTable);
    await _verifyTable(SupabaseConfig.gstr4Table);
    await _verifyTable(SupabaseConfig.gstr9Table);
    await _verifyTable(SupabaseConfig.gstr9cTable);
  }

  static Future<void> _verifyTable(String tableName) async {
    try {
      // Try to select a single row to verify table exists
      await _client.from(tableName).select().limit(1);
      print('Table $tableName exists');
    } catch (e) {
      print('Error verifying table $tableName: $e');
      // Table might not exist, but we don't create it here as it should be managed in Supabase dashboard
    }
  }
}
