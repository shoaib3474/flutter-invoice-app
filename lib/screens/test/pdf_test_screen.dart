// import 'package:flutter/material.dart';
// import 'package:flutter_invoice_app/models/invoice/invoice_item_model.dart';
// import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
// import 'package:flutter_invoice_app/services/pdf/invoice_pdf_service.dart';
// import 'package:flutter_invoice_app/widgets/common/custom_button.dart';
// import 'package:flutter_invoice_app/widgets/invoice/invoice_pdf_preview_widget.dart';
// import 'package:uuid/uuid.dart';

// class PdfTestScreen extends StatefulWidget {
//   const PdfTestScreen({super.key});

//   @override
//   State<PdfTestScreen> createState() => _PdfTestScreenState();
// }

// class _PdfTestScreenState extends State<PdfTestScreen> {
//   final InvoicePdfService _pdfService = InvoicePdfService();
//   bool _isLoading = false;
//   String _resultMessage = '';
//   bool _showPreview = false;
//   late InvoiceModel _sampleInvoice;

//   @override
//   void initState() {
//     super.initState();
//     _createSampleInvoice();
//   }

//   void _createSampleInvoice() {
//     const uuid = Uuid();

//     // Create sample invoice items
//     final items = [
//       InvoiceItem(
//         id: uuid.v4(),
//         name: 'Web Development Services',
//         description: 'Frontend development with React.js',
//         hsnSacCode: '998314',
//         quantity: 1,
//         unit: 'Service',
//         rate: 25000,
//         discount: 1000,
//         cgstRate: 9,
//         sgstRate: 9,
//       ),
//       InvoiceItem(
//         id: uuid.v4(),
//         name: 'Mobile App Development',
//         description: 'Flutter app development for Android and iOS',
//         hsnSacCode: '998314',
//         quantity: 1,
//         unit: 'Service',
//         rate: 35000,
//         cgstRate: 9,
//         sgstRate: 9,
//       ),
//       InvoiceItem(
//         id: uuid.v4(),
//         name: 'UI/UX Design',
//         description: 'Design of user interface and experience',
//         hsnSacCode: '998391',
//         quantity: 1,
//         unit: 'Service',
//         rate: 15000,
//         discount: 500,
//         cgstRate: 9,
//         sgstRate: 9,
//       ),
//     ];

//     // Calculate totals for each item
//     for (final item in items) {
//       item.calculateTotals();
//     }

//     // Create sample invoice
//     _sampleInvoice = InvoiceModel(
//       id: uuid.v4(),
//       invoiceNumber: 'INV-TEST-001',
//       invoiceDate: DateTime.now(),
//       dueDate: DateTime.now().add(const Duration(days: 30)),
//       customerName: 'ABC Technologies Pvt. Ltd.',
//       customerGstin: '27AABCU9603R1ZX',
//       customerAddress: '123 Tech Park, Sector 15, Gurugram',
//       customerState: 'Haryana',
//       customerStateCode: '06',
//       placeOfSupply: 'Haryana',
//       placeOfSupplyCode: '06',
//       items: items,
//       notes: 'Thank you for your business!',
//       termsAndConditions:
//           '1. Payment due within 30 days\n2. Late payment subject to 18% interest per annum',
//       status: InvoiceStatus.issued,
//       invoiceType: InvoiceType.sales,
//       isReverseCharge: false,
//       isB2B: true,
//       isInterState: false,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );

//     // Calculate invoice totals
//     _sampleInvoice.calculateTotals();
//   }

//   Future<void> _generateAndViewPdf() async {
//     setState(() {
//       _isLoading = true;
//       _resultMessage = '';
//     });

//     try {
//       await _pdfService.viewInvoicePdf(_sampleInvoice);
//       setState(() {
//         _resultMessage = 'PDF generated and opened successfully!';
//       });
//     } catch (e) {
//       setState(() {
//         _resultMessage = 'Error: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _generateAndSharePdf() async {
//     setState(() {
//       _isLoading = true;
//       _resultMessage = '';
//     });

//     try {
//       await _pdfService.shareInvoicePdf(_sampleInvoice);
//       setState(() {
//         _resultMessage = 'PDF generated and shared successfully!';
//       });
//     } catch (e) {
//       setState(() {
//         _resultMessage = 'Error: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _generateAndPrintPdf() async {
//     setState(() {
//       _isLoading = true;
//       _resultMessage = '';
//     });

//     try {
//       await _pdfService.printInvoicePdf(_sampleInvoice);
//       setState(() {
//         _resultMessage = 'PDF generated and print dialog opened!';
//       });
//     } catch (e) {
//       setState(() {
//         _resultMessage = 'Error: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _generateAndSavePdf() async {
//     setState(() {
//       _isLoading = true;
//       _resultMessage = '';
//     });

//     try {
//       final filePath = await _pdfService.saveInvoicePdf(_sampleInvoice);
//       setState(() {
//         _resultMessage = 'PDF saved to: $filePath';
//       });
//     } catch (e) {
//       setState(() {
//         _resultMessage = 'Error: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _togglePreview() {
//     setState(() {
//       _showPreview = !_showPreview;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF Generation Test'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Test PDF Invoice Generation',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'This screen allows you to test the PDF generation functionality with a sample invoice.',
//                 style: TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 24),

//               // Invoice details card
//               Card(
//                 elevation: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Sample Invoice Details',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildDetailRow(
//                           'Invoice Number:', _sampleInvoice.invoiceNumber),
//                       _buildDetailRow('Customer:', _sampleInvoice.customerName),
//                       _buildDetailRow('GSTIN:', _sampleInvoice.customerGstin),
//                       _buildDetailRow(
//                           'Items:', '${_sampleInvoice.items.length} items'),
//                       _buildDetailRow('Total Amount:',
//                           '₹${_sampleInvoice.grandTotal.toStringAsFixed(2)}'),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Action buttons with proper async handling
//               Wrap(
//                 spacing: 16,
//                 runSpacing: 16,
//                 children: [
//                   CustomButton(
//                     text: 'View PDF',
//                     icon: Icons.visibility,
//                     color: Colors.blue,
//                     onPressed: _isLoading ? null : () => _generateAndViewPdf(),
//                   ),
//                   CustomButton(
//                     text: 'Share PDF',
//                     icon: Icons.share,
//                     color: Colors.green,
//                     onPressed: _isLoading ? null : () => _generateAndSharePdf(),
//                   ),
//                   CustomButton(
//                     text: 'Print PDF',
//                     icon: Icons.print,
//                     color: Colors.purple,
//                     onPressed: _isLoading ? null : () => _generateAndPrintPdf(),
//                   ),
//                   CustomButton(
//                     text: 'Save PDF',
//                     icon: Icons.save_alt,
//                     color: Colors.orange,
//                     onPressed: _isLoading ? null : () => _generateAndSavePdf(),
//                   ),
//                   CustomButton(
//                     text: _showPreview ? 'Hide Preview' : 'Show Preview',
//                     icon: _showPreview ? Icons.visibility_off : Icons.preview,
//                     color: Colors.teal,
//                     onPressed: _togglePreview,
//                   ),
//                 ],
//               ),

//               // Loading indicator
//               if (_isLoading)
//                 const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),

//               // Result message with proper color handling
//               if (_resultMessage.isNotEmpty)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   margin: const EdgeInsets.only(top: 16),
//                   decoration: BoxDecoration(
//                     color: _resultMessage.startsWith('Error')
//                         ? Colors.red.withOpacity(0.1)
//                         : Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: _resultMessage.startsWith('Error')
//                           ? Colors.red
//                           : Colors.green,
//                     ),
//                   ),
//                   child: Text(
//                     _resultMessage,
//                     style: TextStyle(
//                       color: _resultMessage.startsWith('Error')
//                           ? Colors.red
//                           : Colors.green,
//                     ),
//                   ),
//                 ),

//               // PDF Preview
//               if (_showPreview)
//                 InvoicePdfPreviewWidget(invoice: _sampleInvoice),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
// }
