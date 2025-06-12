import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../logger_service.dart';
import '../../models/ocr/ocr_result_model.dart';
import '../../models/invoice/invoice_model.dart';

class FirebaseOCRService {
  final LoggerService _logger = LoggerService();
  late final TextRecognizer _textRecognizer;
  
  FirebaseOCRService() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  // Extract text from image file
  Future<OCRResult> extractTextFromImage(String imagePath) async {
    try {
      _logger.info('Starting OCR extraction from: $imagePath');
      
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final result = OCRResult(
        extractedText: recognizedText.text,
        confidence: _calculateConfidence(recognizedText),
        blocks: recognizedText.blocks.map((block) => OCRTextBlock(
          text: block.text,
          boundingBox: OCRBoundingBox(
            left: block.boundingBox.left.toDouble(),
            top: block.boundingBox.top.toDouble(),
            right: block.boundingBox.right.toDouble(),
            bottom: block.boundingBox.bottom.toDouble(),
          ),
          confidence: block.confidence ?? 0.0,
        )).toList(),
        processingTime: DateTime.now(),
      );
      
      _logger.info('OCR extraction completed successfully');
      return result;
    } catch (e) {
      _logger.error('OCR extraction failed: $e');
      throw Exception('Failed to extract text from image: $e');
    }
  }

  // Extract text from image bytes
  Future<OCRResult> extractTextFromBytes(Uint8List imageBytes) async {
    try {
      _logger.info('Starting OCR extraction from image bytes');
      
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(800, 600), // Default size, adjust as needed
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 800,
        ),
      );
      
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final result = OCRResult(
        extractedText: recognizedText.text,
        confidence: _calculateConfidence(recognizedText),
        blocks: recognizedText.blocks.map((block) => OCRTextBlock(
          text: block.text,
          boundingBox: OCRBoundingBox(
            left: block.boundingBox.left.toDouble(),
            top: block.boundingBox.top.toDouble(),
            right: block.boundingBox.right.toDouble(),
            bottom: block.boundingBox.bottom.toDouble(),
          ),
          confidence: block.confidence ?? 0.0,
        )).toList(),
        processingTime: DateTime.now(),
      );
      
      _logger.info('OCR extraction from bytes completed successfully');
      return result;
    } catch (e) {
      _logger.error('OCR extraction from bytes failed: $e');
      throw Exception('Failed to extract text from image bytes: $e');
    }
  }

  // Parse invoice data from OCR result
  Future<Invoice?> parseInvoiceFromOCR(OCRResult ocrResult) async {
    try {
      _logger.info('Parsing invoice data from OCR result');
      
      final text = ocrResult.extractedText.toLowerCase();
      final lines = text.split('\n');
      
      // Extract invoice details using pattern matching
      String? invoiceNumber = _extractInvoiceNumber(lines);
      DateTime? invoiceDate = _extractInvoiceDate(lines);
      String? customerName = _extractCustomerName(lines);
      String? customerGstin = _extractGSTIN(lines);
      double? totalAmount = _extractTotalAmount(lines);
      
      if (invoiceNumber == null) {
        _logger.warning('Could not extract invoice number from OCR');
        return null;
      }
      
      // Create invoice from extracted data
      final invoice = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate ?? DateTime.now(),
        dueDate: (invoiceDate ?? DateTime.now()).add(const Duration(days: 30)),
        customerName: customerName ?? 'Unknown Customer',
        customerGstin: customerGstin ?? '',
        customerAddress: _extractCustomerAddress(lines) ?? '',
        customerState: _extractCustomerState(lines) ?? '',
        customerStateCode: _extractStateCode(lines) ?? '',
        placeOfSupply: _extractPlaceOfSupply(lines) ?? '',
        placeOfSupplyCode: _extractPlaceOfSupplyCode(lines) ?? '',
        items: _extractInvoiceItems(lines),
        notes: 'Extracted via OCR',
        termsAndConditions: '',
        status: InvoiceStatus.draft,
        invoiceType: InvoiceType.sales,
        isReverseCharge: _detectReverseCharge(lines),
      );
      
      _logger.info('Successfully parsed invoice from OCR');
      return invoice;
    } catch (e) {
      _logger.error('Failed to parse invoice from OCR: $e');
      return null;
    }
  }

  // Extract specific data patterns
  String? _extractInvoiceNumber(List<String> lines) {
    final patterns = [
      RegExp(r'invoice\s*(?:no|number|#)?\s*:?\s*([a-zA-Z0-9\-/]+)', caseSensitive: false),
      RegExp(r'bill\s*(?:no|number|#)?\s*:?\s*([a-zA-Z0-9\-/]+)', caseSensitive: false),
      RegExp(r'inv\s*(?:no|number|#)?\s*:?\s*([a-zA-Z0-9\-/]+)', caseSensitive: false),
    ];
    
    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(1)?.trim();
        }
      }
    }
    return null;
  }

  DateTime? _extractInvoiceDate(List<String> lines) {
    final patterns = [
      RegExp(r'date\s*:?\s*(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})', caseSensitive: false),
      RegExp(r'(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})'),
    ];
    
    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            final dateStr = match.group(1)!;
            // Parse date with multiple formats
            final parts = dateStr.split(RegExp(r'[\/\-\.]'));
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final fullYear = year < 100 ? 2000 + year : year;
              return DateTime(fullYear, month, day);
            }
          } catch (e) {
            continue;
          }
        }
      }
    }
    return null;
  }

  String? _extractCustomerName(List<String> lines) {
    final patterns = [
      RegExp(r'(?:bill\s*to|customer|client)\s*:?\s*(.+)', caseSensitive: false),
      RegExp(r'(?:to|buyer)\s*:?\s*(.+)', caseSensitive: false),
    ];
    
    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(1)?.trim();
        }
      }
    }
    return null;
  }

  String? _extractGSTIN(List<String> lines) {
    final pattern = RegExp(r'gstin?\s*:?\s*([0-9]{2}[a-zA-Z]{5}[0-9]{4}[a-zA-Z]{1}[1-9a-zA-Z]{1}[zZ]{1}[0-9a-zA-Z]{1})', caseSensitive: false);
    
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        return match.group(1)?.toUpperCase();
      }
    }
    return null;
  }

  double? _extractTotalAmount(List<String> lines) {
    final patterns = [
      RegExp(r'total\s*:?\s*₹?\s*([0-9,]+\.?[0-9]*)', caseSensitive: false),
      RegExp(r'amount\s*:?\s*₹?\s*([0-9,]+\.?[0-9]*)', caseSensitive: false),
      RegExp(r'₹\s*([0-9,]+\.?[0-9]*)'),
    ];
    
    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            final amountStr = match.group(1)!.replaceAll(',', '');
            return double.parse(amountStr);
          } catch (e) {
            continue;
          }
        }
      }
    }
    return null;
  }

  String? _extractCustomerAddress(List<String> lines) {
    // Implementation for extracting customer address
    return null;
  }

  String? _extractCustomerState(List<String> lines) {
    // Implementation for extracting customer state
    return null;
  }

  String? _extractStateCode(List<String> lines) {
    // Implementation for extracting state code
    return null;
  }

  String? _extractPlaceOfSupply(List<String> lines) {
    // Implementation for extracting place of supply
    return null;
  }

  String? _extractPlaceOfSupplyCode(List<String> lines) {
    // Implementation for extracting place of supply code
    return null;
  }

  List<InvoiceItem> _extractInvoiceItems(List<String> lines) {
    // Implementation for extracting invoice items
    return [];
  }

  bool _detectReverseCharge(List<String> lines) {
    for (final line in lines) {
      if (line.toLowerCase().contains('reverse charge')) {
        return true;
      }
    }
    return false;
  }

  double _calculateConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;
    
    double totalConfidence = 0.0;
    int blockCount = 0;
    
    for (final block in recognizedText.blocks) {
      if (block.confidence != null) {
        totalConfidence += block.confidence!;
        blockCount++;
      }
    }
    
    return blockCount > 0 ? totalConfidence / blockCount : 0.0;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
