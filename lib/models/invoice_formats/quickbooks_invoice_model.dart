import 'package:flutter/foundation.dart';

class QuickbooksInvoice {
  final String docNumber;
  final DateTime txnDate;
  final String customerRef;
  final String customerName;
  final String customerEmail;
  final String billingAddress;
  final String shippingAddress;
  final String customerGstin;
  final List<QuickbooksInvoiceItem> line;
  final double subtotal;
  final List<QuickbooksTaxDetail> taxDetail;
  final double totalTax;
  final double totalAmount;
  final String privateNote;
  final String customerMemo;
  final DateTime dueDate;
  final String currencyRef;
  final String txnStatus;

  QuickbooksInvoice({
    required this.docNumber,
    required this.txnDate,
    required this.customerRef,
    required this.customerName,
    required this.customerEmail,
    required this.billingAddress,
    required this.shippingAddress,
    required this.customerGstin,
    required this.line,
    required this.subtotal,
    required this.taxDetail,
    required this.totalTax,
    required this.totalAmount,
    this.privateNote = '',
    this.customerMemo = '',
    required this.dueDate,
    this.currencyRef = 'INR',
    this.txnStatus = 'Pending',
  });

  factory QuickbooksInvoice.fromJson(Map<String, dynamic> json) {
    return QuickbooksInvoice(
      docNumber: json['doc_number'],
      txnDate: DateTime.parse(json['txn_date']),
      customerRef: json['customer_ref'],
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      billingAddress: json['billing_address'],
      shippingAddress: json['shipping_address'],
      customerGstin: json['customer_gstin'],
      line: (json['line'] as List)
          .map((item) => QuickbooksInvoiceItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'],
      taxDetail: (json['tax_detail'] as List)
          .map((tax) => QuickbooksTaxDetail.fromJson(tax))
          .toList(),
      totalTax: json['total_tax'],
      totalAmount: json['total_amount'],
      privateNote: json['private_note'] ?? '',
      customerMemo: json['customer_memo'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
      currencyRef: json['currency_ref'] ?? 'INR',
      txnStatus: json['txn_status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doc_number': docNumber,
      'txn_date': txnDate.toIso8601String(),
      'customer_ref': customerRef,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'billing_address': billingAddress,
      'shipping_address': shippingAddress,
      'customer_gstin': customerGstin,
      'line': line.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax_detail': taxDetail.map((tax) => tax.toJson()).toList(),
      'total_tax': totalTax,
      'total_amount': totalAmount,
      'private_note': privateNote,
      'customer_memo': customerMemo,
      'due_date': dueDate.toIso8601String(),
      'currency_ref': currencyRef,
      'txn_status': txnStatus,
    };
  }
}

class QuickbooksInvoiceItem {
  final String itemRef;
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double amount;
  final String taxCodeRef;
  final String hsnCode;

  QuickbooksInvoiceItem({
    required this.itemRef,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.amount,
    required this.taxCodeRef,
    required this.hsnCode,
  });

  factory QuickbooksInvoiceItem.fromJson(Map<String, dynamic> json) {
    return QuickbooksInvoiceItem(
      itemRef: json['item_ref'],
      description: json['description'],
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: json['unit_price'],
      amount: json['amount'],
      taxCodeRef: json['tax_code_ref'],
      hsnCode: json['hsn_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_ref': itemRef,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'amount': amount,
      'tax_code_ref': taxCodeRef,
      'hsn_code': hsnCode,
    };
  }
}

class QuickbooksTaxDetail {
  final String taxRateRef;
  final String taxRateName;
  final double taxRate;
  final double taxableAmount;
  final double taxAmount;

  QuickbooksTaxDetail({
    required this.taxRateRef,
    required this.taxRateName,
    required this.taxRate,
    required this.taxableAmount,
    required this.taxAmount,
  });

  factory QuickbooksTaxDetail.fromJson(Map<String, dynamic> json) {
    return QuickbooksTaxDetail(
      taxRateRef: json['tax_rate_ref'],
      taxRateName: json['tax_rate_name'],
      taxRate: json['tax_rate'],
      taxableAmount: json['taxable_amount'],
      taxAmount: json['tax_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tax_rate_ref': taxRateRef,
      'tax_rate_name': taxRateName,
      'tax_rate': taxRate,
      'taxable_amount': taxableAmount,
      'tax_amount': taxAmount,
    };
  }
}
