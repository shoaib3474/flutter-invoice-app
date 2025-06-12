import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/ocr/firebase_ocr_service.dart';
import '../../models/ocr/ocr_result_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/ocr/ocr_result_widget.dart';
import '../../widgets/ocr/invoice_preview_widget.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({Key? key}) : super(key: key);

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  final FirebaseOCRService _ocrService = FirebaseOCRService();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  OCRResult? _ocrResult;
  Invoice? _extractedInvoice;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(),
            SizedBox(height: 16),
            Text(
              'Processing document...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_selectedImage == null) ...[
            _buildWelcomeCard(),
          ] else ...[
            _buildImagePreview(),
            const SizedBox(height: 16),
          ],

          if (_ocrResult != null) ...[
            OCRResultWidget(
              result: _ocrResult!,
              onExtractInvoice: () => _extractInvoiceData(),
            ),
            const SizedBox(height: 16),
          ],

          if (_extractedInvoice != null) ...[
            InvoicePreviewWidget(
              invoice: _extractedInvoice!,
              onSave: () => _saveExtractedInvoice(),
              onEdit: () => _editExtractedInvoice(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.document_scanner,
              size: 64,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 16),
            const Text(
              'Document Scanner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan invoices, receipts, and other documents to extract data automatically using AI-powered OCR.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Supported Features:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('📄 Invoice data extraction'),
            _buildFeatureItem('🔍 Text recognition (OCR)'),
            _buildFeatureItem('💰 Amount and tax detection'),
            _buildFeatureItem('📅 Date parsing'),
            _buildFeatureItem('🏢 Customer information'),
            _buildFeatureItem('📊 Item details extraction'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.image, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Selected Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _clearImage(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processImage(),
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Extract Text'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _selectImage(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => _selectImage(ImageSource.camera),
          heroTag: 'camera',
          backgroundColor: Colors.green,
          child: const Icon(Icons.camera_alt),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () => _selectImage(ImageSource.gallery),
          heroTag: 'gallery',
          backgroundColor: Colors.blue,
          child: const Icon(Icons.photo_library),
        ),
      ],
    );
  }

  Future<void> _selectImage([ImageSource? source]) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _showErrorMessage('Camera permission is required to take photos');
          return;
        }
      }

      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        _showErrorMessage('Storage permission is required to access photos');
        return;
      }

      // Show source selection if not specified
      if (source == null) {
        source = await _showImageSourceDialog();
        if (source == null) return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _ocrResult = null;
          _extractedInvoice = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to select image: $e');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await _ocrService.extractTextFromImage(_selectedImage!.path);
      setState(() {
        _ocrResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorMessage('Failed to process image: $e');
    }
  }

  Future<void> _extractInvoiceData() async {
    if (_ocrResult == null) return;

    setState(() => _isProcessing = true);

    try {
      final invoice = await _ocrService.parseInvoiceFromOCR(_ocrResult!);
      setState(() {
        _extractedInvoice = invoice;
        _isProcessing = false;
      });

      if (invoice == null) {
        _showErrorMessage('Could not extract invoice data from the document');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorMessage('Failed to extract invoice data: $e');
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _ocrResult = null;
      _extractedInvoice = null;
      _errorMessage = null;
    });
  }

  void _saveExtractedInvoice() {
    if (_extractedInvoice == null) return;
    
    // Navigate to invoice form with pre-filled data
    Navigator.pushNamed(
      context,
      '/invoice/form',
      arguments: _extractedInvoice,
    );
  }

  void _editExtractedInvoice() {
    if (_extractedInvoice == null) return;
    
    // Navigate to invoice form for editing
    Navigator.pushNamed(
      context,
      '/invoice/form',
      arguments: _extractedInvoice,
    );
  }

  void _showErrorMessage(String message) {
    setState(() => _errorMessage = message);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Scanner Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use the Document Scanner:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Take a photo or select from gallery'),
              Text('2. Ensure the document is clear and well-lit'),
              Text('3. Click "Extract Text" to process'),
              Text('4. Review extracted data'),
              Text('5. Save or edit the invoice'),
              SizedBox(height: 16),
              Text(
                'Tips for better results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Use good lighting'),
              Text('• Keep the document flat'),
              Text('• Avoid shadows and glare'),
              Text('• Ensure text is clearly visible'),
              Text('• Use high resolution images'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
