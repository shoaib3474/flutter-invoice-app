import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

import '../services/converter/invoice_converter_service.dart';
import '../services/detector/file_format_detector.dart';

class InvoiceConverterScreen extends StatefulWidget {
  const InvoiceConverterScreen({Key? key}) : super(key: key);

  @override
  _InvoiceConverterScreenState createState() => _InvoiceConverterScreenState();
}

class _InvoiceConverterScreenState extends State<InvoiceConverterScreen> {
  final InvoiceConverterService _converterService = InvoiceConverterService();
  
  String? _selectedFilePath;
  String? _selectedFileName;
  InvoiceFormat? _sourceFormat;
  InvoiceFormat? _targetFormat;
  bool _isConverting = false;
  String? _convertedFilePath;
  String? _errorMessage;
  
  final List<DropdownMenuItem<InvoiceFormat>> _formatItems = [
    const DropdownMenuItem(value: InvoiceFormat.billShill, child: Text('Bill-Shill')),
    const DropdownMenuItem(value: InvoiceFormat.tally, child: Text('Tally')),
    const DropdownMenuItem(value: InvoiceFormat.zoho, child: Text('Zoho')),
    const DropdownMenuItem(value: InvoiceFormat.quickbooks, child: Text('QuickBooks')),
    const DropdownMenuItem(value: InvoiceFormat.json, child: Text('JSON')),
    const DropdownMenuItem(value: InvoiceFormat.xml, child: Text('XML')),
    const DropdownMenuItem(value: InvoiceFormat.csv, child: Text('CSV')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Format Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFileSelector(),
            const SizedBox(height: 24),
            _buildFormatSelectors(),
            const SizedBox(height: 24),
            _buildConvertButton(),
            if (_errorMessage != null) _buildErrorMessage(),
            if (_convertedFilePath != null) _buildConversionResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Invoice File',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFileName ?? 'No file selected',
                    style: TextStyle(
                      color: _selectedFileName != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelectors() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Formats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<InvoiceFormat>(
                    decoration: const InputDecoration(
                      labelText: 'Source Format',
                      border: OutlineInputBorder(),
                    ),
                    value: _sourceFormat,
                    items: _formatItems,
                    onChanged: (value) {
                      setState(() {
                        _sourceFormat = value;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<InvoiceFormat>(
                    decoration: const InputDecoration(
                      labelText: 'Target Format',
                      border: OutlineInputBorder(),
                    ),
                    value: _targetFormat,
                    items: _formatItems,
                    onChanged: (value) {
                      setState(() {
                        _targetFormat = value;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canConvert() ? _convertFile : null,
        icon: _isConverting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.swap_horiz),
        label: Text(_isConverting ? 'Converting...' : 'Convert'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionResult() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Conversion Successful',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'File saved to:',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(_convertedFilePath!),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _openConvertedFile,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _shareConvertedFile,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'xml', 'csv'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
          _convertedFilePath = null;
          _errorMessage = null;
        });
      
        // Try to detect the source format
        final detectedFormat = await FileFormatDetector.detectFormat(_selectedFilePath!);
        if (detectedFormat != null) {
          setState(() {
            _sourceFormat = detectedFormat;
          });
        } else {
          // If detection fails, try to determine from extension
          final extension = path.extension(_selectedFileName!).toLowerCase();
          switch (extension) {
            case '.json':
              _sourceFormat = InvoiceFormat.json;
              break;
            case '.xml':
              _sourceFormat = InvoiceFormat.xml;
              break;
            case '.csv':
              _sourceFormat = InvoiceFormat.csv;
              break;
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting file: ${e.toString()}';
      });
    }
  }

  bool _canConvert() {
    return !_isConverting &&
        _selectedFilePath != null &&
        _sourceFormat != null &&
        _targetFormat != null;
  }

  Future<void> _convertFile() async {
    if (!_canConvert()) return;

    setState(() {
      _isConverting = true;
      _convertedFilePath = null;
      _errorMessage = null;
    });

    try {
      final convertedFilePath = await _converterService.convertInvoiceFile(
        sourceFilePath: _selectedFilePath!,
        sourceFormat: _sourceFormat!,
        targetFormat: _targetFormat!,
      );

      setState(() {
        _convertedFilePath = convertedFilePath;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error converting file: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  Future<void> _openConvertedFile() async {
    if (_convertedFilePath == null) return;
    
    try {
      final file = File(_convertedFilePath!);
      if (await file.exists()) {
        // Open the file using platform-specific method
        // This is a simplified example
        // You might want to use a package like open_file
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error opening file: ${e.toString()}';
      });
    }
  }

  Future<void> _shareConvertedFile() async {
    if (_convertedFilePath == null) return;
    
    try {
      await Share.shareXFiles([XFile(_convertedFilePath!)]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sharing file: ${e.toString()}';
      });
    }
  }
}
