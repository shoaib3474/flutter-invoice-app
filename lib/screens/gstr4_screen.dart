import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gstr4_model.dart';
import '../services/gstr4_service.dart';
import '../widgets/gstr4/gstr4_form_widget.dart';
import '../widgets/gstr4/gstr4_summary_widget.dart';
import '../widgets/gstr4/gstr4_import_export_widget.dart';
import '../utils/error_handler.dart';

class GSTR4Screen extends StatefulWidget {
  const GSTR4Screen({Key? key}) : super(key: key);

  @override
  _GSTR4ScreenState createState() => _GSTR4ScreenState();
}

class _GSTR4ScreenState extends State<GSTR4Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GSTR4Service _gstr4Service = GSTR4Service();
  GSTR4Model? _gstr4Data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGSTR4Data();
  }

  Future<void> _loadGSTR4Data() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final data = await _gstr4Service.getLatestGSTR4Data();
      
      setState(() {
        _gstr4Data = data;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to load GSTR-4 data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGSTR4Data(GSTR4Model data) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      await _gstr4Service.saveGSTR4Data(data);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-4 data saved successfully')),
      );
      
      await _loadGSTR4Data();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to save GSTR-4 data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _importGSTR4Data(String jsonData) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final data = await _gstr4Service.importFromJson(jsonData);
      
      setState(() {
        _gstr4Data = data;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-4 data imported successfully')),
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to import GSTR-4 data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportGSTR4Data() async {
    if (_gstr4Data == null) return;
    
    try {
      final jsonData = await _gstr4Service.exportToJson(_gstr4Data!);
      // Handle the exported JSON data (e.g., share, save to file, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-4 data exported successfully')),
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export GSTR-4 data: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GSTR-4 Return'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Form'),
            Tab(text: 'Summary'),
            Tab(text: 'Import/Export'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGSTR4Data,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGSTR4Data,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Form Tab
                    _gstr4Data != null
                        ? GSTR4FormWidget(
                            gstr4Data: _gstr4Data!,
                            onSave: _saveGSTR4Data,
                          )
                        : const Center(child: Text('No GSTR-4 data available')),
                    
                    // Summary Tab
                    _gstr4Data != null
                        ? GSTR4SummaryWidget(gstr4Data: _gstr4Data!)
                        : const Center(child: Text('No GSTR-4 data available')),
                    
                    // Import/Export Tab
                    GSTR4ImportExportWidget(
                      onImport: _importGSTR4Data,
                      onExport: _gstr4Data != null ? _exportGSTR4Data : null,
                    ),
                  ],
                ),
    );
  }
}
