import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gstr1_model.dart';
import '../services/gstr1_service.dart';
import '../widgets/gstr1/gstr1_form_widget.dart';
import '../widgets/gstr1/gstr1_summary_widget.dart';
import '../widgets/gstr1/gstr1_import_export_widget.dart';
import '../utils/error_handler.dart';

class GSTR1Screen extends StatefulWidget {
  const GSTR1Screen({Key? key}) : super(key: key);

  @override
  _GSTR1ScreenState createState() => _GSTR1ScreenState();
}

class _GSTR1ScreenState extends State<GSTR1Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GSTR1Service _gstr1Service = GSTR1Service();
  GSTR1Model? _gstr1Data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGSTR1Data();
  }

  Future<void> _loadGSTR1Data() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _gstr1Service.getLatestGSTR1Data();

      setState(() {
        _gstr1Data = data;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to load GSTR-1 data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGSTR1Data(GSTR1Model data) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _gstr1Service.saveGSTR1Data(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-1 data saved successfully')),
      );

      await _loadGSTR1Data();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to save GSTR-1 data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _importGSTR1Data(String jsonData) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _gstr1Service.importFromJson(jsonData);

      setState(() {
        _gstr1Data = data;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-1 data imported successfully')),
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to import GSTR-1 data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportGSTR1Data() async {
    if (_gstr1Data == null) return;

    try {
      final jsonData = await _gstr1Service.exportToJson(_gstr1Data!);
      // Handle the exported JSON data (e.g., share, save to file, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-1 data exported successfully')),
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to export GSTR-1 data: ${e.toString()}')),
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
        title: const Text('GSTR-1 Return'),
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
            onPressed: _loadGSTR1Data,
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
                        onPressed: _loadGSTR1Data,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Form Tab
                    // _gstr1Data != null
                    //     ? GSTR1FormWidget(
                    //         gstr1Data: _gstr1Data!,
                    //         onSave: _saveGSTR1Data,
                    //       )
                    //     : const Center(child: Text('No GSTR-1 data available')),

                    // // Summary Tab
                    // _gstr1Data != null
                    //     ? GSTR1SummaryWidget(gstr1Data: _gstr1Data!)
                    //     : const Center(child: Text('No GSTR-1 data available')),

                    // // Import/Export Tab
                    // GSTR1ImportExportWidget(
                    //   onImport: _importGSTR1Data,
                    //   onExport: _gstr1Data != null ? _exportGSTR1Data : null,
                    // ),
                  ],
                ),
    );
  }
}
