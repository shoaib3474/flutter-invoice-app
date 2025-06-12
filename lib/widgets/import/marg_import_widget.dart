import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/gstr1_model.dart';
import '../../services/import/marg_import_service.dart';
import '../../utils/error_handler.dart';

class MargImportWidget extends StatefulWidget {
  final Function(GSTR1Model) onImportSuccess;
  final String gstin;
  final String returnPeriod;

  const MargImportWidget({
    Key? key,
    required this.onImportSuccess,
    required this.gstin,
    required this.returnPeriod,
  }) : super(key: key);

  @override
  _MargImportWidgetState createState() => _MargImportWidgetState();
}

class _MargImportWidgetState extends State<MargImportWidget> {
  final MargImportService _margImportService = MargImportService();
  bool _isImporting = false;
  String? _importFilePath;
  String? _importError;

  Future<void> _importMargData() async {
    setState(() {
      _isImporting = true;
      _importError = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        _importFilePath = result.files.single.path;
        if (_importFilePath != null) {
          final file = File(_importFilePath!);
          
          // Import Marg data
          final gstr1Data = await _margImportService.importFromFile(
            file,
            widget.gstin,
            widget.returnPeriod,
          );
          
          // Call the callback with the imported data
          widget.onImportSuccess(gstr1Data);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marg data imported successfully')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _importError = 'Failed to import Marg data: ${e.toString()}';
      });
      ErrorHandler.logError('Marg Import Error', e);
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Marg Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import Marg data from a JSON file. The file should be exported from Marg in JSON format.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isImporting ? null : _importMargData,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_isImporting ? 'Importing...' : 'Import Marg JSON'),
                ),
                if (_importFilePath != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File: ${_importFilePath!.split('/').last}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            
            // Error message
            if (_importError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _importError!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
