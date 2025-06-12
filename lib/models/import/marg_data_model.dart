import 'dart:convert';

class MargDataModel {
  final String customerName;
  final String? customerGstin;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String placeOfSupply;
  final bool isReverseCharge;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final List<MargItemModel> items;

  const MargDataModel({
    required this.customerName,
    this.customerGstin,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.placeOfSupply,
    required this.isReverseCharge,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'customer_gstin': customerGstin,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'place_of_supply': placeOfSupply,
      'is_reverse_charge': isReverseCharge,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory MargDataModel.fromMap(Map<String, dynamic> map) {
    return MargDataModel(
      customerName: map['customer_name'] ?? '',
      customerGstin: map['customer_gstin'],
      invoiceNumber: map['invoice_number'] ?? '',
      invoiceDate: DateTime.parse(map['invoice_date']),
      placeOfSupply: map['place_of_supply'] ?? '',
      isReverseCharge: map['is_reverse_charge'] ?? false,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
      items: List<MargItemModel>.from(
        map['items']?.map((x) => MargItemModel.fromMap(x)) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory MargDataModel.fromJson(String source) =>
      MargDataModel.fromMap(json.decode(source));
}

class MargItemModel {
  final String itemName;
  final String? hsnCode;
  final double quantity;
  final double rate;
  final double amount;
  final double taxableValue;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cessRate;

  const MargItemModel({
    required this.itemName,
    this.hsnCode,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.taxableValue,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cessRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'item_name': itemName,
      'hsn_code': hsnCode,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'taxable_value': taxableValue,
      'cgst_rate': cgstRate,
      'sgst_rate': sgstRate,
      'igst_rate': igstRate,
      'cess_rate': cessRate,
    };
  }

  factory MargItemModel.fromMap(Map<String, dynamic> map) {
    return MargItemModel(
      itemName: map['item_name'] ?? '',
      hsnCode: map['hsn_code'],
      quantity: map['quantity']?.toDouble() ?? 0.0,
      rate: map['rate']?.toDouble() ?? 0.0,
      amount: map['amount']?.toDouble() ?? 0.0,
      taxableValue: map['taxable_value']?.toDouble() ?? 0.0,
      cgstRate: map['cgst_rate']?.toDouble() ?? 0.0,
      sgstRate: map['sgst_rate']?.toDouble() ?? 0.0,
      igstRate: map['igst_rate']?.toDouble() ?? 0.0,
      cessRate: map['cess_rate']?.toDouble() ?? 0.0,
    );
  }
}
