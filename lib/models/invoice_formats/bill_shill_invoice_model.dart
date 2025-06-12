import 'package:flutter/foundation.dart';

class BillShillInvoice {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String customerGstin;
  final String customerAddress;
  final List<BillShillInvoiceItem> items;
  final double totalAmount;
  final double totalTaxAmount;
  final double totalAmountWithTax;
  final String notes;
  final String termsAndConditions;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime dueDate;

  BillShillInvoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.customerGstin,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
    required this.totalTaxAmount,
    required this.totalAmountWithTax,
    this.notes = '',
    this.termsAndConditions = '',
    this.paymentMethod = '',
    this.paymentStatus = 'Unpaid',
    required this.dueDate,
  });

  factory BillShillInvoice.fromJson(Map<String, dynamic> json) {
    return BillShillInvoice(
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      customerName: json['customer_name'],
      customerGstin: json['customer_gstin'],
      customerAddress: json['customer_address'],
      items: (json['items'] as List)
          .map((item) => BillShillInvoiceItem.fromJson(item))
          .toList(),
      totalAmount: json['total_amount'],
      totalTaxAmount: json['total_tax_amount'],
      totalAmountWithTax: json['total_amount_with_tax'],
      notes: json['notes'] ?? '',
      termsAndConditions: json['terms_and_conditions'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'Unpaid',
      dueDate: DateTime.parse(json['due_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'customer_name': customerName,
      'customer_gstin': customerGstin,
      'customer_address': customerAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'total_tax_amount': totalTaxAmount,
      'total_amount_with_tax': totalAmountWithTax,
      'notes': notes,
      'terms_and_conditions': termsAndConditions,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'due_date': dueDate.toIso8601String(),
    };
  }
}

class BillShillInvoiceItem {
  final String itemName;
  final String itemDescription;
  final String hsnCode;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double amount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;

  BillShillInvoiceItem({
    required this.itemName,
    required this.itemDescription,
    required this.hsnCode,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.amount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
  });

  factory BillShillInvoiceItem.fromJson(Map<String, dynamic> json) {
    return BillShillInvoiceItem(
      itemName: json['item_name'],
      itemDescription: json['item_description'],
      hsnCode: json['hsn_code'],
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: json['unit_price'],
      amount: json['amount'],
      taxRate: json['tax_rate'],
      taxAmount: json['tax_amount'],
      totalAmount: json['total_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'item_description': itemDescription,
      'hsn_code': hsnCode,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'amount': amount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
    };
  }
}
