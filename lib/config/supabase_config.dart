class SupabaseConfig {
  static const String supabaseUrl = 'your_supabase_url';
  static const String supabaseAnonKey = 'your_supabase_anon_key';
  
  // Table names
  static const String invoicesTable = 'invoices';
  static const String invoiceItemsTable = 'invoice_items';
  static const String customersTable = 'customers';
  static const String productsTable = 'products';
  static const String gstr1Table = 'gstr1';
  static const String gstr3bTable = 'gstr3b';
  static const String gstr4Table = 'gstr4';
  static const String gstr9Table = 'gstr9';
  static const String gstr9cTable = 'gstr9c';
  
  // Mock client for development
  static final client = MockSupabaseClient();
}

class MockSupabaseClient {
  MockSupabaseAuth get auth => MockSupabaseAuth();
  
  MockSupabaseQueryBuilder from(String table) {
    return MockSupabaseQueryBuilder();
  }
}

class MockSupabaseAuth {
  MockUser? get currentUser => null;
}

class MockUser {
  String get id => 'mock_user_id';
}

class MockSupabaseQueryBuilder {
  MockSupabaseQueryBuilder select([String? columns]) => this;
  MockSupabaseQueryBuilder insert(Map<String, dynamic> data) => this;
  MockSupabaseQueryBuilder update(Map<String, dynamic> data) => this;
  MockSupabaseQueryBuilder delete() => this;
  MockSupabaseQueryBuilder eq(String column, dynamic value) => this;
  MockSupabaseQueryBuilder limit(int count) => this;
  
  Future<MockSupabaseResponse> execute() async {
    return MockSupabaseResponse();
  }
}

class MockSupabaseResponse {
  int get status => 200;
  List<dynamic> get data => [];
}
