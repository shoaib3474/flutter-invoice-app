// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../models/gst_returns/gstr1_model.dart';
import '../../services/logger_service.dart';
import '../../utils/api_exception.dart';

class DataImportService {
  Future<GSTR1Model> importTallyData(File file) async {
    // Implement your logic here
    throw UnimplementedError('importTallyData not implemented');
  }

  Future<GSTR1Model> importMargData(File file) async {
    // Implement your logic here
    throw UnimplementedError('importMargData not implemented');
  }
}

class DataImportWidget extends StatefulWidget {
  const DataImportWidget({
    required this.onImportComplete,
    Key? key,
  }) : super(key: key);
  final Function(GSTR1Model) onImportComplete;

  @override
  _DataImportWidgetState createState() => _DataImportWidgetState();
}

class _DataImportWidgetState extends State<DataImportWidget> {
  final DataImportService _importService = DataImportService();
  final LoggerService _logger = LoggerService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _importTallyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );

      if (result == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get file path
      final String filePath = result.files.single.path!;
      final File file = File(filePath);

      // Import data
      final GSTR1Model gstr1Model = await _importService.importTallyData(file);

      // Notify parent
      widget.onImportComplete(gstr1Model);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tally data imported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _logger.error('Error importing Tally data: $e');
      setState(() {
        _errorMessage =
            e is ApiException ? e.message : 'Failed to import Tally data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importMargData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get file path
      final String filePath = result.files.single.path!;
      final File file = File(filePath);

      // Import data
      final GSTR1Model gstr1Model = await _importService.importMargData(file);

      // Notify parent
      widget.onImportComplete(gstr1Model);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marg data imported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _logger.error('Error importing Marg data: $e');
      setState(() {
        _errorMessage =
            e is ApiException ? e.message : 'Failed to import Marg data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _importTallyData,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import from Tally'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _importMargData,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import from Marg'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Note: Import will replace existing data in the form.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
