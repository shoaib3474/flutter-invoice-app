import 'package:flutter/foundation.dart';
import '../storage/local_storage_service.dart';
import '../customer/local_customer_service.dart';
import '../../models/invoice/invoice_model.dart';
import '../../utils/tax_calculator.dart';
import '../../utils/number_formatter.dart';

class LocalInvoiceService {
  // Generate next invoice number
  static String generateInvoiceNumber() {
    final settings = LocalStorageService.getSettings();
    final prefix = settings['invoicePrefix'] as String? ?? 'INV';
    final currentNumber = settings['lastInvoiceNumber'] as int? ?? 0;
    final nextNumber = currentNumber + 1;
    
    // Update last invoice number
    settings['lastInvoiceNumber'] = nextNumber;
    LocalStorageService.saveSettings(settings);
    
    return '$prefix${nextNumber.toString().padLeft(4, '0')}';
  }

  // Create invoice with automatic calculations
  static InvoiceModel createInvoice({
    required String customerId,
    required List<Map<String, dynamic>> items,
    required String paymentMode,
    String? notes,
  }) {
    final customer = LocalCustomerService.getCustomerByMobile(customerId);
    if (customer == null) {
      throw Exception('Customer not found');
    }

    final invoiceNumber = generateInvoiceNumber();
    final now = DateTime.now();
    
    // Calculate totals
    double subtotal = 0.0;
    double totalTax = 0.0;
    final processedItems = <InvoiceItem>[];
    
    for (final itemData in items) {
      final quantity = (itemData['quantity'] as num?)?.toDouble() ?? 1.0;
      final rate = (itemData['rate'] as num?)?.toDouble() ?? 0.0;
      final gstRate = (itemData['gstRate'] as num?)?.toDouble() ?? 0.0;
      
      final itemTotal = quantity * rate;
      final itemTax = TaxCalculator.calculateGST(itemTotal, gstRate);
      
      subtotal += itemTotal;
      totalTax += itemTax;
      
      processedItems.add(InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: itemData['description'] as String? ?? '',
        hsnCode: itemData['hsnCode'] as String? ?? '',
        quantity: quantity,
        unit: itemData['unit'] as String? ?? 'Nos',
        rate: rate,
        amount: itemTotal,
        gstRate: gstRate,
        gstAmount: itemTax,
      ));
    }
    
    final grandTotal = subtotal + totalTax;
    
    // Determine invoice type based on customer
    final isB2B = customer.gstin?.isNotEmpty == true;
    
    final invoice = InvoiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: invoiceNumber,
      invoiceDate: now,
      dueDate: now.add(const Duration(days: 30)),
      customerName: customer.name,
      customerEmail: customer.email ?? '',
      customerPhone: customer.mobile,
      customerAddress: customer.address ?? '',
      customerGstin: customer.gstin ?? '',
      items: processedItems,
      subtotal: subtotal,
      totalTax: totalTax,
      grandTotal: grandTotal,
      status: InvoiceStatus.issued,
      notes: notes,
      termsAndConditions: _getDefaultTerms(isB2B),
      paymentTerms: _getPaymentTerms(paymentMode),
    );
    
    // Save invoice locally
    saveInvoice(invoice);
    
    // Update customer ledger
    _updateCustomerLedger(customerId, invoice, 'sale');
    
    // Record payment if cash
    if (paymentMode.toLowerCase() == 'cash') {
      _recordPayment(invoice, grandTotal, paymentMode);
    }
    
    return invoice;
  }

  // Save invoice to local storage
  static void saveInvoice(InvoiceModel invoice) {
    final invoiceData = invoice.toJson();
    invoiceData['createdAt'] = DateTime.now().toIso8601String();
    invoiceData['privacyCompliant'] = true;
    invoiceData['storageType'] = 'local_only';
    
    LocalStorageService.saveInvoice(invoiceData);
    
    debugPrint('Invoice saved locally: ${invoice.invoiceNumber}');
  }

  // Get invoice by ID
  static InvoiceModel? getInvoice(String invoiceId) {
    final invoiceData = LocalStorageService.getInvoice(invoiceId);
    if (invoiceData != null) {
      return InvoiceModel.fromJson(invoiceData);
    }
    return null;
  }

  // Get all invoices
  static List<InvoiceModel> getAllInvoices() {
    final invoicesData = LocalStorageService.getAllInvoices();
    final invoices = <InvoiceModel>[];
    
    for (final data in invoicesData) {
      try {
        invoices.add(InvoiceModel.fromJson(data));
      } catch (e) {
        debugPrint('Error parsing invoice data: $e');
      }
    }
    
    // Sort by date (newest first)
    invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    
    return invoices;
  }

  // Get invoices by date range
  static List<InvoiceModel> getInvoicesByDateRange(DateTime start, DateTime end) {
    final allInvoices = getAllInvoices();
    return allInvoices.where((invoice) {
      return invoice.invoiceDate.isAfter(start.subtract(const Duration(days: 1))) &&
             invoice.invoiceDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get today's sales
  static List<InvoiceModel> getTodaysSales() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getInvoicesByDateRange(startOfDay, endOfDay);
  }

  // Get sales summary
  static Map<String, dynamic> getSalesSummary({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final dayInvoices = getInvoicesByDateRange(startOfDay, endOfDay);
    
    double totalSales = 0.0;
    double totalTax = 0.0;
    int totalInvoices = dayInvoices.length;
    int cashSales = 0;
    int creditSales = 0;
    
    for (final invoice in dayInvoices) {
      totalSales += invoice.grandTotal;
      totalTax += invoice.totalTax;
      
      // Check payment mode from payment records
      final payments = LocalStorageService.getAllPayments()
          .where((p) => p['invoiceId'] == invoice.id)
          .toList();
      
      if (payments.isNotEmpty && payments.first['mode'] == 'cash') {
        cashSales++;
      } else {
        creditSales++;
      }
    }
    
    return {
      'date': targetDate.toIso8601String(),
      'totalSales': totalSales,
      'totalTax': totalTax,
      'totalInvoices': totalInvoices,
      'cashSales': cashSales,
      'creditSales': creditSales,
      'averageInvoiceValue': totalInvoices > 0 ? totalSales / totalInvoices : 0.0,
    };
  }

  // Update customer ledger
  static void _updateCustomerLedger(String customerId, InvoiceModel invoice, String type) {
    final ledgerEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': invoice.invoiceDate.toIso8601String(),
      'type': 'debit', // Sale increases customer's debt
      'amount': invoice.grandTotal,
      'description': 'Sale - ${invoice.invoiceNumber}',
      'invoiceId': invoice.id,
      'invoiceNumber': invoice.invoiceNumber,
      'transactionType': type,
    };
    
    LocalStorageService.updateCustomerLedger(customerId, ledgerEntry);
  }

  // Record payment
  static void _recordPayment(InvoiceModel invoice, double amount, String mode) {
    final payment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'invoiceId': invoice.id,
      'invoiceNumber': invoice.invoiceNumber,
      'customerId': invoice.customerPhone, // Using mobile as customer ID
      'customerName': invoice.customerName,
      'amount': amount,
      'mode': mode,
      'date': DateTime.now().toIso8601String(),
      'status': 'completed',
      'notes': 'Payment for ${invoice.invoiceNumber}',
    };
    
    LocalStorageService.savePayment(payment);
    
    // Update customer ledger for payment
    final ledgerEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'type': 'credit', // Payment reduces customer's debt
      'amount': amount,
      'description': 'Payment - $mode',
      'paymentId': payment['id'],
      'invoiceId': invoice.id,
      'transactionType': 'payment',
    };
    
    LocalStorageService.updateCustomerLedger(invoice.customerPhone, ledgerEntry);
  }

  // Get default terms based on customer type
  static String _getDefaultTerms(bool isB2B) {
    if (isB2B) {
      return '''Terms & Conditions:
1. Payment due within 30 days of invoice date
2. GST as applicable
3. Subject to local jurisdiction
4. Goods once sold will not be taken back
5. Interest @ 18% p.a. will be charged on delayed payments''';
    } else {
      return '''Terms & Conditions:
1. Goods once sold will not be taken back
2. Subject to local jurisdiction
3. Thank you for your business''';
    }
  }

  // Get payment terms
  static String _getPaymentTerms(String paymentMode) {
    switch (paymentMode.toLowerCase()) {
      case 'cash':
        return 'Payment Mode: Cash - Paid in full';
      case 'upi':
        return 'Payment Mode: UPI - Digital payment';
      case 'card':
        return 'Payment Mode: Card - Electronic payment';
      case 'credit':
        return 'Payment Mode: Credit - Payment due in 30 days';
      default:
        return 'Payment Mode: $paymentMode';
    }
  }

  // Delete invoice
  static void deleteInvoice(String invoiceId) {
    LocalStorageService.deleteInvoice(invoiceId);
    debugPrint('Invoice deleted locally: $invoiceId');
  }

  // Export invoices for backup
  static Map<String, dynamic> exportInvoices() {
    final invoices = getAllInvoices();
    return {
      'invoices': invoices.map((i) => i.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'totalCount': invoices.length,
      'privacyCompliant': true,
      'dataSource': 'local_storage_only',
    };
  }

  // Get invoice statistics
  static Map<String, dynamic> getInvoiceStats() {
    final invoices = getAllInvoices();
    final today = DateTime.now();
    final thisMonth = invoices.where((i) => 
        i.invoiceDate.year == today.year && 
        i.invoiceDate.month == today.month).toList();
    
    return {
      'total': invoices.length,
      'thisMonth': thisMonth.length,
      'totalValue': invoices.fold<double>(0.0, (sum, i) => sum + i.grandTotal),
      'thisMonthValue': thisMonth.fold<double>(0.0, (sum, i) => sum + i.grandTotal),
      'averageValue': invoices.isNotEmpty ? 
          invoices.fold<double>(0.0, (sum, i) => sum + i.grandTotal) / invoices.length : 0.0,
    };
  }
}
