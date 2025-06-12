import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/utils/database_tester.dart';
import 'package:flutter_invoice_app/services/gst_json_import_service.dart';
import 'package:flutter_invoice_app/repositories/supabase/supabase_gst_returns_repository.dart';
import 'package:flutter_invoice_app/repositories/supabase/supabase_invoice_repository.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_item_model.dart';
import 'package:flutter_invoice_app/widgets/common/custom_button.dart';
import 'package:flutter_invoice_app/widgets/common/loading_indicator.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({Key? key}) : super(key: key);

  @override
  _DatabaseTestScreenState createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final DatabaseTester _databaseTester = DatabaseTester();
  final GstJsonImportService _gstJsonImportService = GstJsonImportService();
  final SupabaseGstReturnsRepository _gstRepository = SupabaseGstReturnsRepository();
  final SupabaseInvoiceRepository _invoiceRepository = SupabaseInvoiceRepository();
  
  bool _isLoading = false;
  Map<String, dynamic> _testResults = {};
  String _statusMessage = '';
  bool _isError = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Integration Test'),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTestSection(),
                  const SizedBox(height: 24),
                  _buildImportExportSection(),
                  const SizedBox(height: 24),
                  _buildRealWorldTestSection(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildTestSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Database Connection Tests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Run All Tests',
              onPressed: _runAllTests,
              icon: Icons.play_arrow,
            ),
            const SizedBox(height: 16),
            if (_testResults.isNotEmpty) _buildTestResults(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImportExportSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GST JSON Import/Export',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Import GSTR1',
                    onPressed: () => _importGstReturn(GstReturnType.gstr1),
                    icon: Icons.upload_file,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Import GSTR3B',
                    onPressed: () => _importGstReturn(GstReturnType.gstr3b),
                    icon: Icons.upload_file,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Import GSTR9',
                    onPressed: () => _importGstReturn(GstReturnType.gstr9),
                    icon: Icons.upload_file,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Import GSTR9C',
                    onPressed: () => _importGstReturn(GstReturnType.gstr9c),
                    icon: Icons.upload_file,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_statusMessage.isNotEmpty) _buildStatusMessage(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRealWorldTestSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-World Database Tests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Create Test Invoice',
                    onPressed: _createTestInvoice,
                    icon: Icons.receipt_long,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Create Test GSTR1',
                    onPressed: _createTestGSTR1,
                    icon: Icons.description,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Create Test GSTR3B',
                    onPressed: _createTestGSTR3B,
                    icon: Icons.description,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Fetch All Invoices',
                    onPressed: _fetchAllInvoices,
                    icon: Icons.list,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_statusMessage.isNotEmpty) _buildStatusMessage(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          'Test Results:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildTestResultItem('Connection', _testResults['connection'] ?? false),
        const SizedBox(height: 8),
        Text(
          'Tables:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (_testResults['tables'] != null)
          ..._buildTableResults(_testResults['tables']),
        const SizedBox(height: 8),
        _buildTestResultItem('Write Operation', _testResults['write'] ?? false),
        _buildTestResultItem('Read Operation', _testResults['read'] ?? false),
      ],
    );
  }
  
  List<Widget> _buildTableResults(Map<String, bool> tableResults) {
    return tableResults.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
        child: _buildTestResultItem(entry.key, entry.value),
      );
    }).toList();
  }
  
  Widget _buildTestResultItem(String name, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.error,
          color: passed ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(name),
        ),
        Text(
          passed ? 'Passed' : 'Failed',
          style: TextStyle(
            color: passed ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isError ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isError ? Icons.error : Icons.check_circle,
            color: _isError ? Colors.red.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isError ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });
    
    try {
      final results = await _databaseTester.runAllTests();
      
      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error running tests: ${e.toString()}';
        _isError = true;
      });
    }
  }
  
  Future<void> _importGstReturn(GstReturnType returnType) async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });
    
    try {
      final data = await _gstJsonImportService.importFromJsonFile(returnType);
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Successfully imported ${returnType.toString().split('.').last.toUpperCase()} data';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error importing data: ${e.toString()}';
        _isError = true;
      });
    }
  }
  
  Future<void> _createTestInvoice() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });
    
    try {
      // Create a test invoice
      final invoice = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        invoiceNumber: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        customerName: 'Test Customer',
        customerGstin: '27AAPFU0939F1ZV',
        customerEmail: 'test@example.com',
        customerAddress: '123 Test Street, Test City',
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [
          InvoiceItem(
            id: '1',
            description: 'Test Product 1',
            quantity: 2,
            unitPrice: 100.0,
            taxRate: 18.0,
            taxAmount: 36.0,
            totalAmount: 236.0,
            hsnCode: '1234',
          ),
          InvoiceItem(
            id: '2',
            description: 'Test Product 2',
            quantity: 1,
            unitPrice: 200.0,
            taxRate: 12.0,
            taxAmount: 24.0,
            totalAmount: 224.0,
            hsnCode: '5678',
          ),
        ],
        subtotal: 400.0,
        taxTotal: 60.0,
        total: 460.0,
        notes: 'This is a test invoice',
        terms: 'Net 30',
        status: InvoiceStatus.draft,
      );
      
      await _invoiceRepository.createInvoice(invoice);
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Successfully created test invoice with ID: ${invoice.id}';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error creating test invoice: ${e.toString()}';
        _isError = true;
      });
    }
  }
  
  Future<void> _createTestGSTR1() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });
    
    try {
      // Create a test GSTR1
      final gstr1 = GSTR1(
        gstin: '27AAPFU0939F1ZV',
        returnPeriod: '042023',
        b2bInvoices: [
          B2BInvoice(
            id: '1',
            invoiceNumber: 'INV-001',
            invoiceDate: DateTime.now(),
            counterpartyGstin: '29AAPFU0939F1ZV',
            counterpartyName: 'Test Customer',
            taxableValue: 1000.0,
            igstAmount: 180.0,
            cgstAmount: 0.0,
            sgstAmount: 0.0,
            cessAmount: 0.0,
            placeOfSupply: '29',
            reverseCharge: false,
            invoiceType: 'Regular',
          ),
        ],
        b2clInvoices: [],
        b2csInvoices: [],
        exportInvoices: [],
        totalTaxableValue: 1000.0,
        totalIgst: 180.0,
        totalCgst: 0.0,
        totalSgst: 0.0,
        status: 'Not Filed',
        filingDate: DateTime.now(),
      );
      
      await _gstRepository.saveGSTR1(gstr1);
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Successfully created test GSTR1 for period: ${gstr1.returnPeriod}';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error creating test GSTR1: ${e.toString()}';
        _isError = true;
      });
    }
  }
  
  Future<void> _createTestGSTR3B() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });
    
    try {
      // Create a test GSTR3B
      final gstr3b = GSTR3B(
        gstin: '27AAPFU0939F1ZV',
        returnPeriod: '042023',
        outwardSupplies: OutwardSupplies(
          taxableOutwardSupplies: 1000.0,
          taxableOutwardSuppliesZeroRated: 500.0,
          taxableOutwardSuppliesNilRated: 200.0,
          nonGstOutwardSupplies: 100.0,
          intraStateSupplies: 0.0,
          interStateSupplies: 1000.0,
          igstAmount: 180.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          cessAmount: 0.0,
        ),
        inwardSupplies: InwardSupplies(
          reverseChargeSupplies: 0.0,
          importOfGoods: 0.0,
          importOfServices: 0.0,
          ineligibleITC: 0.0,
          eligibleITC: 0.0,
          igstAmount: 0.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          cessAmount: 0.0,
        ),
        itcDetails: ITCDetails(
          itcAvailed: 0.0,
          itcReversed: 0.0,
          itcNet: 0.0,
          ineligibleITC: 0.0,
        ),
        taxPayment: TaxPayment(
          igstAmount: 180.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          cessAmount: 0.0,
          interestAmount: 0.0,
          lateFeesAmount: 0.0,
          penaltyAmount: 0.0,
          totalAmount: 180.0,
        ),
        status: 'Not Filed',
        filingDate: DateTime.now(),
      );
      
      await _gstRepository.saveGSTR3B(gstr3b);
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Successfully created test GSTR3B for period: ${gstr3b.returnPeriod}';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error creating test GSTR3B: ${e.toString()}';
        _isError = true;
      });
    }
  }
  
  Future<void> _fetchAllInvoices() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });
    
    try {
      final invoices = await _invoiceRepository.getAllInvoices();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Successfully fetched ${invoices.length} invoices';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error fetching invoices: ${e.toString()}';
        _isError = true;
      });
    }
  }
}
