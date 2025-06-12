import 'package:flutter/material.dart';
import '../widgets/gstr9c/gstr9c_form_widget.dart';
import '../widgets/gstr9c/gstr9c_summary_widget.dart';
import '../widgets/gstr9c/gstr9c_import_export_widget.dart';
import '../models/gstr9c_model.dart';
import '../services/gstr9c_service.dart';
import '../services/gstr9_service.dart';
import '../models/gstr9_model.dart';

class GSTR9CScreen extends StatefulWidget {
  final String? gstin;
  final String? financialYear;
  final GSTR9? gstr9Data;

  const GSTR9CScreen({
    Key? key, 
    this.gstin, 
    this.financialYear,
    this.gstr9Data,
  }) : super(key: key);

  @override
  _GSTR9CScreenState createState() => _GSTR9CScreenState();
}

class _GSTR9CScreenState extends State<GSTR9CScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GSTR9CService _gstr9cService = GSTR9CService();
  final GSTR9Service _gstr9Service = GSTR9Service();
  
  GSTR9C? _gstr9cData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.gstr9Data != null) {
        // Generate GSTR9C from GSTR9 data
        _gstr9cData = await _gstr9cService.generateBlankGSTR9C(widget.gstr9Data!);
      } else if (widget.gstin != null && widget.financialYear != null) {
        // Try to load GSTR9 data first
        try {
          // This is a placeholder - in a real app, you would load GSTR9 data from storage
          // For now, we'll create a blank GSTR9C
          _gstr9cData = GSTR9C(
            gstin: widget.gstin!,
            financialYear: widget.financialYear!,
            legalName: '',
            tradeName: '',
            reconciliation: GSTR9CReconciliation(
              turnoverAsPerAuditedFinancialStatements: 0.0,
              turnoverAsPerAnnualReturn: 0.0,
              unReconciled: 0.0,
              reconciliationItems: [],
            ),
            auditorRecommendation: GSTR9CAuditorRecommendation(
              recommendations: [],
            ),
            taxPayable: GSTR9CTaxPayable(
              taxPayableAsPerReconciliation: 0.0,
              taxPaidAsPerAnnualReturn: 0.0,
              differentialTaxPayable: 0.0,
              interestPayable: 0.0,
            ),
            auditorDetails: '',
            certificationDetails: '',
          );
        } catch (e) {
          // If GSTR9 data loading fails, create a blank GSTR9C
          _gstr9cData = GSTR9C(
            gstin: widget.gstin!,
            financialYear: widget.financialYear!,
            legalName: '',
            tradeName: '',
            reconciliation: GSTR9CReconciliation(
              turnoverAsPerAuditedFinancialStatements: 0.0,
              turnoverAsPerAnnualReturn: 0.0,
              unReconciled: 0.0,
              reconciliationItems: [],
            ),
            auditorRecommendation: GSTR9CAuditorRecommendation(
              recommendations: [],
            ),
            taxPayable: GSTR9CTaxPayable(
              taxPayableAsPerReconciliation: 0.0,
              taxPaidAsPerAnnualReturn: 0.0,
              differentialTaxPayable: 0.0,
              interestPayable: 0.0,
            ),
            auditorDetails: '',
            certificationDetails: '',
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGSTR9C(GSTR9C gstr9c) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save the GSTR9C data
      await _gstr9cService.saveGSTR9CToJson(gstr9c);
      
      // Update the current data
      setState(() {
        _gstr9cData = gstr9c;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GSTR-9C data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Switch to summary tab
      _tabController.animateTo(1);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save data: ${e.toString()}';
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleImportSuccess(GSTR9C importedData) {
    setState(() {
      _gstr9cData = importedData;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GSTR-9C data imported successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Switch to summary tab
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GSTR-9C Reconciliation Statement'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Form', icon: Icon(Icons.edit_document)),
            Tab(text: 'Summary', icon: Icon(Icons.summarize)),
            Tab(text: 'Import/Export', icon: Icon(Icons.import_export)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Form Tab
                    GSTR9CFormWidget(
                      initialData: _gstr9cData,
                      onSave: _saveGSTR9C,
                      gstin: widget.gstin,
                      financialYear: widget.financialYear,
                    ),
                    
                    // Summary Tab
                    _gstr9cData != null
                        ? GSTR9CSummaryWidget(
                            gstr9cData: _gstr9cData!,
                            onEdit: () => _tabController.animateTo(0),
                            onExport: () => _tabController.animateTo(2),
                          )
                        : const Center(
                            child: Text('No GSTR-9C data available. Please fill the form first.'),
                          ),
                    
                    // Import/Export Tab
                    GSTR9CImportExportWidget(
                      currentData: _gstr9cData,
                      onImportSuccess: _handleImportSuccess,
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
