import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice/invoice_model.dart';

class InvoiceRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'invoices';
  
  InvoiceRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  // Create a new invoice
  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      await _firestore.collection(_collection).doc(invoice.id).set(invoice.toFirestore());
      return invoice;
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }
  
  // Get an invoice by ID
  Future<Invoice?> getInvoice(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Invoice.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get invoice: $e');
    }
  }
  
  // Update an invoice
  Future<void> updateInvoice(Invoice invoice) async {
    try {
      await _firestore.collection(_collection).doc(invoice.id).update(invoice.toFirestore());
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }
  
  // Delete an invoice
  Future<void> deleteInvoice(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }
  
  // Get all invoices
  Future<List<Invoice>> getAllInvoices() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get invoices: $e');
    }
  }
  
  // Get invoices by customer
  Future<List<Invoice>> getInvoicesByCustomer(String customerName) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('customer_name', isEqualTo: customerName)
          .get();
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get invoices by customer: $e');
    }
  }
  
  // Get invoices by date range
  Future<List<Invoice>> getInvoicesByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('invoice_date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('invoice_date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get invoices by date range: $e');
    }
  }
  
  // Get invoices by status
  Future<List<Invoice>> getInvoicesByStatus(InvoiceStatus status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.index)
          .get();
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get invoices by status: $e');
    }
  }
  
  // Get invoices by type
  Future<List<Invoice>> getInvoicesByType(InvoiceType type) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('invoice_type', isEqualTo: type.index)
          .get();
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get invoices by type: $e');
    }
  }
  
  // Get invoices for GST returns
  Future<List<Invoice>> getInvoicesForGSTReturns(String returnPeriod) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('gst_return_period', isEqualTo: returnPeriod)
          .get();
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get invoices for GST returns: $e');
    }
  }
  
  // Mark invoice as reported in GST returns
  Future<void> markInvoiceAsReported(String id, String returnPeriod, String returnType) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'is_gst_reported': true,
        'gst_return_period': returnPeriod,
        'gst_return_type': returnType,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark invoice as reported: $e');
    }
  }
}
