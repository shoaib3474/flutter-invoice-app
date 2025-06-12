import 'package:flutter/foundation.dart';

class ZohoInvoice {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerBillingAddress;
  final String customerShippingAddress;
  final String customerGstin;
  final List<ZohoInvoiceItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String notes;
  final String termsAndConditions;
  final String paymentTerms;
  final DateTime dueDate;
  final String currency;
  final String status;

  ZohoInvoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerBillingAddress,
    required this.customerShippingAddress,
    required this.customerGstin,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    this.notes = '',
    this.termsAndConditions = '',
    this.paymentTerms = '',
    required this.dueDate,
    this.currency = 'INR',
    this.status = 'Draft',
  });

  factory ZohoInvoice.fromJson(Map<String, dynamic> json) {
    return ZohoInvoice(
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      customerPhone: json['customer_phone'],
      customerBillingAddress: json['customer_billing_address'],
      customerShippingAddress: json['customer_shipping_address'],
      customerGstin: json['customer_gstin'],
      items: (json['items'] as List)
          .map((item) => ZohoInvoiceItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'],
      discountAmount: json['discount_amount'],
      taxAmount: json['tax_amount'],
      totalAmount: json['total_amount'],
      notes: json['notes'] ?? '',
      termsAndConditions: json['terms_and_conditions'] ?? '',
      paymentTerms: json['payment_terms'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? 'Draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'customer_billing_address': customerBillingAddress,
      'customer_shipping_address': customerShippingAddress,
      'customer_gstin': customerGstin,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'notes': notes,
      'terms_and_conditions': termsAndConditions,
      'payment_terms': paymentTerms,
      'due_date': dueDate.toIso8601String(),
      'currency': currency,
      'status': status,
    };
  }
}

class ZohoInvoiceItem {
  final String itemName;
  final String itemDescription;
  final String hsnSacCode;
  final double quantity;
  final String unit;
  final double rate;
  final double discount;
  final double taxPercentage;
  final double taxAmount;
  final double amount;

  ZohoInvoiceItem({
    required this.itemName,
    required this.itemDescription,
    required this.hsnSacCode,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.discount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.amount,
  });

  factory ZohoInvoiceItem.fromJson(Map<String, dynamic> json) {
    return ZohoInvoiceItem(
      itemName: json['item_name'],
      itemDescription: json['item_description'],
      hsnSacCode: json['hsn_sac_code'],
      quantity: json['quantity'],
      unit: json['unit'],
      rate: json['rate'],
      discount: json['discount'],
      taxPercentage: json['tax_percentage'],
      taxAmount: json['tax_amount'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'item_description': itemDescription,
      'hsn_sac_code': hsnSacCode,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'discount': discount,
      'tax_percentage': taxPercentage,
      'tax_amount': taxAmount,
      'amount': amount,
    };
  }
}
