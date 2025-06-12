import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gstr3b_model.dart';
import '../services/gstr3b_service.dart';
import '../widgets/gstr3b/gstr3b_form_widget.dart';
import '../widgets/gstr3b/gstr3b_summary_widget.dart';
import '../widgets/gstr3b/gstr3b_import_export_widget.dart';
import '../utils/error_handler.dart';

class GSTR3BScreen extends StatefulWidget {
  const GSTR3BScreen({Key? key}) : super(key: key);

  @override
  _GSTR3BScreenState createState() => _GSTR3BScreenState();
}

class _GSTR3BScreenState extends State<GSTR3BScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GSTR3BService _gstr3bService = GSTR3BService();
  GSTR3BModel? _gstr3bData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGSTR3BData();
  }

  Future<void> _loadGSTR3BData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final data = await _gstr3bService.getLatestGSTR3BData();
      
      setState(() {
        _gstr3bData = data;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to load GSTR-3B data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGSTR3BData(GSTR3BModel data) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      await _gstr3bService.saveGSTR3BData(data);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-3B data saved successfully')),
      );
      
      await _loadGSTR3BData();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to save GSTR-3B data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _importGSTR3BData(String jsonData) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final data = await _gstr3bService.importFromJson(jsonData);
      
      setState(() {
        _gstr3bData = data;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-3B data imported successfully')),
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to import GSTR-3B data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportGSTR3BData() async {
    if (_gstr3bData == null) return;
    
    try {
      final jsonData = await _gstr3bService.exportToJson(_gstr3bData!);
      // Handle the exported JSON data (e.g., share, save to file, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-3B data exported successfully')),
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export GSTR-3B data: ${e.toString()}')),
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
        title: const Text('GSTR-3B Return'),
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
            onPressed: _loadGSTR3BData,
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
                        onPressed: _loadGSTR3BData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Form Tab
                    _gstr3bData != null
                        ? GSTR3BFormWidget(
                            gstr3bData: _gstr3bData!,
                            onSave: _saveGSTR3BData,
                          )
                        : const Center(child: Text('No GSTR-3B data available')),
                    
                    // Summary Tab
                    _gstr3bData != null
                        ? GSTR3BSummaryWidget(gstr3bData: _gstr3bData!)
                        : const Center(child: Text('No GSTR-3B data available')),
                    
                    // Import/Export Tab
                    GSTR3BImportExportWidget(
                      onImport: _importGSTR3BData,
                      onExport: _gstr3bData != null ? _exportGSTR3BData : null,
                    ),
                  ],
                ),
    );
  }
}
