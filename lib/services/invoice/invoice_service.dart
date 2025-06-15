import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/services/auth/auth_service.dart';
import 'package:flutter_invoice_app/services/pdf/invoice_pdf_service.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final InvoicePdfService _pdfService = InvoicePdfService();

  // Get all invoices for the current user
  Stream<List<Invoice>> getInvoices() {
    final userId = _authService.getUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('invoices')
        .where('created_by', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList());
  }

  // Get a single invoice by ID
  Future<Invoice?> getInvoice(String id) async {
    final doc = await _firestore.collection('invoices').doc(id).get();
    if (doc.exists) {
      return Invoice.fromFirestore(doc);
    }
    return null;
  }

  // Create a new invoice
  Future<void> createInvoice(Invoice invoice) async {
    await _firestore
        .collection('invoices')
        .doc(invoice.id)
        .set(invoice.toMap());
  }

  // Update an existing invoice
  Future<void> updateInvoice(Invoice invoice) async {
    await _firestore
        .collection('invoices')
        .doc(invoice.id)
        .update(invoice.toMap());
  }

  // Delete an invoice
  Future<void> deleteInvoice(String id) async {
    await _firestore.collection('invoices').doc(id).delete();
  }

  // Get the next invoice number (usually implemented with a counter in Firestore)
  Future<String> getNextInvoiceNumber() async {
    // In a real app, this would use a transaction to get a unique, sequential number
    // For simplicity, we'll use the current date and a random number
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final randomNum = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'INV-$dateStr-$randomNum';
  }

  // Generate PDF from invoice
  Future<void> generateAndShareInvoicePdf(Invoice invoice) async {
    try {
      await _pdfService.shareInvoicePdf(invoice);
    } catch (e) {
      rethrow;
    }
  }

  // Print invoice
  Future<void> printInvoice(Invoice invoice) async {
    try {
      await _pdfService.printInvoicePdf(invoice);
    } catch (e) {
      rethrow;
    }
  }

  // Save invoice PDF
  Future<String> saveInvoicePdf(Invoice invoice) async {
    try {
      return await _pdfService.saveInvoicePdf(invoice);
    } catch (e) {
      rethrow;
    }
  }

  // View invoice PDF
  Future<void> viewInvoicePdf(Invoice invoice) async {
    try {
      await _pdfService.viewInvoicePdf(invoice);
    } catch (e) {
      rethrow;
    }
  }

  // Get statistics for dashboard
  Future<Map<String, dynamic>> getInvoiceStatistics() async {
    final userId = _authService.getUserId();
    if (userId == null) {
      return {
        'total_invoices': 0,
        'total_amount': 0.0,
        'paid_amount': 0.0,
        'unpaid_amount': 0.0,
        'overdue_amount': 0.0,
      };
    }

    final querySnapshot = await _firestore
        .collection('invoices')
        .where('created_by', isEqualTo: userId)
        .get();

    int totalInvoices = querySnapshot.docs.length;
    double totalAmount = 0.0;
    double paidAmount = 0.0;
    double unpaidAmount = 0.0;
    double overdueAmount = 0.0;

    for (var doc in querySnapshot.docs) {
      final invoice = Invoice.fromFirestore(doc);
      totalAmount += invoice.grandTotal;

      switch (invoice.status) {
        case InvoiceStatus.paid:
          paidAmount += invoice.grandTotal;
          break;
        case InvoiceStatus.issued:
        case InvoiceStatus.partiallyPaid:
          unpaidAmount += invoice.grandTotal;
          break;
        case InvoiceStatus.overdue:
          overdueAmount += invoice.grandTotal;
          break;
        default:
          // Don't count drafts, canceled or void invoices
          break;
      }
    }

    return {
      'total_invoices': totalInvoices,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'unpaid_amount': unpaidAmount,
      'overdue_amount': overdueAmount,
    };
  }

  Future getInvoiceById(String s) async {}
}
