import 'package:flutter/foundation.dart';

class TallyInvoice {
  final String voucherType;
  final String voucherNumber;
  final DateTime voucherDate;
  final String partyName;
  final String partyGstin;
  final String partyAddress;
  final List<TallyInvoiceItem> items;
  final double totalAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmountWithTax;
  final String narration;
  final String ledgerName;
  final String costCenter;

  TallyInvoice({
    required this.voucherType,
    required this.voucherNumber,
    required this.voucherDate,
    required this.partyName,
    required this.partyGstin,
    required this.partyAddress,
    required this.items,
    required this.totalAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmountWithTax,
    this.narration = '',
    required this.ledgerName,
    this.costCenter = '',
  });

  factory TallyInvoice.fromJson(Map<String, dynamic> json) {
    return TallyInvoice(
      voucherType: json['voucher_type'],
      voucherNumber: json['voucher_number'],
      voucherDate: DateTime.parse(json['voucher_date']),
      partyName: json['party_name'],
      partyGstin: json['party_gstin'],
      partyAddress: json['party_address'],
      items: (json['items'] as List)
          .map((item) => TallyInvoiceItem.fromJson(item))
          .toList(),
      totalAmount: json['total_amount'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      totalAmountWithTax: json['total_amount_with_tax'],
      narration: json['narration'] ?? '',
      ledgerName: json['ledger_name'],
      costCenter: json['cost_center'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucher_type': voucherType,
      'voucher_number': voucherNumber,
      'voucher_date': voucherDate.toIso8601String(),
      'party_name': partyName,
      'party_gstin': partyGstin,
      'party_address': partyAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount_with_tax': totalAmountWithTax,
      'narration': narration,
      'ledger_name': ledgerName,
      'cost_center': costCenter,
    };
  }
}

class TallyInvoiceItem {
  final String stockItemName;
  final String stockItemDescription;
  final String hsnCode;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;

  TallyInvoiceItem({
    required this.stockItemName,
    required this.stockItemDescription,
    required this.hsnCode,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
  });

  factory TallyInvoiceItem.fromJson(Map<String, dynamic> json) {
    return TallyInvoiceItem(
      stockItemName: json['stock_item_name'],
      stockItemDescription: json['stock_item_description'],
      hsnCode: json['hsn_code'],
      quantity: json['quantity'],
      unit: json['unit'],
      rate: json['rate'],
      amount: json['amount'],
      cgstRate: json['cgst_rate'],
      sgstRate: json['sgst_rate'],
      igstRate: json['igst_rate'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      totalAmount: json['total_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_item_name': stockItemName,
      'stock_item_description': stockItemDescription,
      'hsn_code': hsnCode,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'amount': amount,
      'cgst_rate': cgstRate,
      'sgst_rate': sgstRate,
      'igst_rate': igstRate,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
    };
  }
}
