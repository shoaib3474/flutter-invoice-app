import '../models/ledger_models.dart';

class LedgerService {
  // Demo data for liabilities ledger
  static const List<Map<String, dynamic>> _demoLiabilitiesData = [
    {
      'id': '1',
      'description': 'CGST Liability',
      'amount': 15000.0,
      'date': '2024-01-15T00:00:00.000Z',
      'taxType': 'CGST',
      'status': 'Pending',
      'category': 'Tax Liability',
      'metadata': {},
    },
    {
      'id': '2',
      'description': 'SGST Liability',
      'amount': 15000.0,
      'date': '2024-01-15T00:00:00.000Z',
      'taxType': 'SGST',
      'status': 'Pending',
      'category': 'Tax Liability',
      'metadata': {},
    },
    {
      'id': '3',
      'description': 'IGST Liability',
      'amount': 30000.0,
      'date': '2024-01-20T00:00:00.000Z',
      'taxType': 'IGST',
      'status': 'Paid',
      'category': 'Tax Liability',
      'metadata': {},
    },
  ];

  static const List<Map<String, dynamic>> _demoRCMData = [
    {
      'id': '1',
      'description': 'RCM on Legal Services',
      'amount': 5000.0,
      'date': '2024-01-10T00:00:00.000Z',
      'taxType': 'RCM',
      'status': 'Pending',
      'category': 'Reverse Charge',
      'supplierGstin': '27AABCU9603R1ZX',
      'supplierName': 'Legal Associates Pvt Ltd',
      'invoiceNumber': 'INV-2024-001',
      'invoiceDate': '2024-01-08T00:00:00.000Z',
      'taxableValue': 25000.0,
      'igstAmount': 4500.0,
      'cgstAmount': 0.0,
      'sgstAmount': 0.0,
      'cessAmount': 0.0,
      'paymentStatus': 'Pending',
      'metadata': {},
    },
    {
      'id': '2',
      'description': 'RCM on Consulting Services',
      'amount': 8000.0,
      'date': '2024-01-12T00:00:00.000Z',
      'taxType': 'RCM',
      'status': 'Paid',
      'category': 'Reverse Charge',
      'supplierGstin': '29AABCU9603R1ZY',
      'supplierName': 'Tech Consultants Ltd',
      'invoiceNumber': 'INV-2024-002',
      'invoiceDate': '2024-01-10T00:00:00.000Z',
      'taxableValue': 40000.0,
      'igstAmount': 7200.0,
      'cgstAmount': 0.0,
      'sgstAmount': 0.0,
      'cessAmount': 0.0,
      'paymentStatus': 'Paid',
      'metadata': {},
    },
    {
      'id': '3',
      'description': 'RCM on Import Services',
      'amount': 12000.0,
      'date': '2024-01-15T00:00:00.000Z',
      'taxType': 'RCM',
      'status': 'Unpaid',
      'category': 'Import Services',
      'supplierGstin': '07AABCU9603R1ZZ',
      'supplierName': 'Global Import Services',
      'invoiceNumber': 'INV-2024-003',
      'invoiceDate': '2024-01-13T00:00:00.000Z',
      'taxableValue': 60000.0,
      'igstAmount': 10800.0,
      'cgstAmount': 0.0,
      'sgstAmount': 0.0,
      'cessAmount': 1200.0,
      'paymentStatus': 'Unpaid',
      'metadata': {},
    },
  ];

  Future<List<LiabilitiesLedgerEntry>> getLiabilitiesLedgerEntries({
    String? taxType,
    String? status,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    var data = _demoLiabilitiesData;
    
    if (taxType != null) {
      data = data.where((entry) => entry['taxType'] == taxType).toList();
    }
    
    if (status != null) {
      data = data.where((entry) => entry['status'] == status).toList();
    }
    
    return data.map((json) => LiabilitiesLedgerEntry.fromJson(json)).toList();
  }

  Future<List<RCMLedgerEntry>> getRCMLedgerEntries({
    String? taxType,
    String? status,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    var data = _demoRCMData;
    
    if (taxType != null) {
      data = data.where((entry) => entry['taxType'] == taxType).toList();
    }
    
    if (status != null) {
      data = data.where((entry) => entry['status'] == status).toList();
    }
    
    return data.map((json) => RCMLedgerEntry.fromJson(json)).toList();
  }

  Future<double> getTotalLiabilities() async {
    final entries = await getLiabilitiesLedgerEntries();
    return entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  Future<double> getTotalRCM() async {
    final entries = await getRCMLedgerEntries();
    return entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  Future<List<CashLedgerEntry>> getCashLedgerEntries({
    required String gstin,
    required String taxType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Mock implementation
    return [];
  }

  Future<List<ElectronicLedgerEntry>> getElectronicLedgerEntries({
    required String gstin,
    required String taxType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Mock implementation
    return [];
  }
}
