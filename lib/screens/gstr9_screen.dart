import 'package:flutter/material.dart';
import '../widgets/gstr9/gstr9_form_widget.dart';
import '../widgets/gstr9/gstr9_summary_widget.dart';
import '../widgets/gstr9/gstr9_import_export_widget.dart';
import '../models/gstr9_model.dart';
import '../services/gstr9_service.dart';
import '../services/gstr1_service.dart';
import '../services/gstr3b_service.dart';
import '../models/gstr1_model.dart';
import '../models/gstr3b_model.dart';

class GSTR9Screen extends StatefulWidget {
  final String? gstin;
  final String? financialYear;

  const GSTR9Screen({Key? key, this.gstin, this.financialYear}) : super(key: key);

  @override
  _GSTR9ScreenState createState() => _GSTR9ScreenState();
}

class _GSTR9ScreenState extends State<GSTR9Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GSTR9Service _gstr9Service = GSTR9Service();
  final GSTR1Service _gstr1Service = GSTR1Service();
  final GSTR3BService _gstr3bService = GSTR3BService();
  
  GSTR9? _gstr9Data;
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
      if (widget.gstin != null && widget.financialYear != null) {
        // Check if we have existing GSTR1 and GSTR3B data for this GSTIN and financial year
        List<GSTR1> gstr1Data = await _gstr1Service.getGSTR1ByFinancialYear(
          widget.gstin!,
          widget.financialYear!,
        );

        List<GSTR3B> gstr3bData = await _gstr3bService.getGSTR3BByFinancialYear(
          widget.gstin!,
          widget.financialYear!,
        );

        if (gstr1Data.isNotEmpty && gstr3bData.isNotEmpty) {
          // Generate GSTR9 from existing returns
          _gstr9Data = await _gstr9Service.generateGSTR9FromReturns(
            gstr1Data,
            gstr3bData,
            widget.financialYear!,
          );
        } else {
          // Create a blank GSTR9
          _gstr9Data = GSTR9(
            gstin: widget.gstin!,
            financialYear: widget.financialYear!,
            legalName: '',
            tradeName: '',
            part1: GSTR9Part1(
              totalOutwardSupplies: 0.0,
              zeroRatedSupplies: 0.0,
              nilRatedSupplies: 0.0,
              exemptedSupplies: 0.0,
              nonGSTSupplies: 0.0,
            ),
            part2: GSTR9Part2(
              inwardSuppliesAttractingReverseCharge: 0.0,
              importsOfGoodsAndServices: 0.0,
              inwardSuppliesLiableToReverseCharge: 0.0,
            ),
            part3: GSTR9Part3(
              taxPayableOnOutwardSupplies: 0.0,
              taxPayableOnReverseCharge: 0.0,
              interestPayable: 0.0,
              lateFeePayable: 0.0,
              penaltyPayable: 0.0,
            ),
            part4: GSTR9Part4(
              itcAvailedOnInvoices: 0.0,
              itcReversedAndReclaimed: 0.0,
              itcAvailedButIneligible: 0.0,
            ),
            part5: GSTR9Part5(
              refundClaimed: 0.0,
              refundSanctioned: 0.0,
              refundRejected: 0.0,
              refundPending: 0.0,
            ),
            part6: GSTR9Part6(
              taxPayableAsPerSection73Or74: 0.0,
              taxPaidAsPerSection73Or74: 0.0,
              interestPayableAsPerSection73Or74: 0.0,
              interestPaidAsPerSection73Or74: 0.0,
            ),
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

  Future<void> _saveGSTR9(GSTR9 gstr9) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save the GSTR9 data
      await _gstr9Service.saveGSTR9ToJson(gstr9);
      
      // Update the current data
      setState(() {
        _gstr9Data = gstr9;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GSTR-9 data saved successfully!'),
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleImportSuccess(GSTR9 importedData) {
    setState(() {
      _gstr9Data = importedData;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GSTR-9 data imported successfully!'),
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
        title: const Text('GSTR-9 Annual Return'),
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
                    GSTR9FormWidget(
                      initialData: _gstr9Data,
                      onSave: _saveGSTR9,
                      gstin: widget.gstin,
                      financialYear: widget.financialYear,
                    ),
                    
                    // Summary Tab
                    _gstr9Data != null
                        ? GSTR9SummaryWidget(
                            gstr9Data: _gstr9Data!,
                            onEdit: () => _tabController.animateTo(0),
                            onExport: () => _tabController.animateTo(2),
                          )
                        : const Center(
                            child: Text('No GSTR-9 data available. Please fill the form first.'),
                          ),
                    
                    // Import/Export Tab
                    GSTR9ImportExportWidget(
                      currentData: _gstr9Data,
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
