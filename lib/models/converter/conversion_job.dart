import '../../services/converter/invoice_converter_service.dart';

class ConversionJob {
  final String sourceFilePath;
  final InvoiceFormat sourceFormat;

  ConversionJob({
    required this.sourceFilePath,
    required this.sourceFormat,
  });
}
