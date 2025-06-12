import 'dart:convert';

class TallyDataModel {
  final String partyName;
  final String? partyGstin;
  final String voucherNumber;
  final DateTime voucherDate;
  final String placeOfSupply;
  final bool isReverseCharge;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final List<TallyItemModel> items;

  const TallyDataModel({
    required this.partyName,
    this.partyGstin,
    required this.voucherNumber,
    required this.voucherDate,
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
      'party_name': partyName,
      'party_gstin': partyGstin,
      'voucher_number': voucherNumber,
      'voucher_date': voucherDate.toIso8601String(),
      'place_of_supply': placeOfSupply,
      'is_reverse_charge': isReverseCharge,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory TallyDataModel.fromMap(Map<String, dynamic> map) {
    return TallyDataModel(
      partyName: map['party_name'] ?? '',
      partyGstin: map['party_gstin'],
      voucherNumber: map['voucher_number'] ?? '',
      voucherDate: DateTime.parse(map['voucher_date']),
      placeOfSupply: map['place_of_supply'] ?? '',
      isReverseCharge: map['is_reverse_charge'] ?? false,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
      items: List<TallyItemModel>.from(
        map['items']?.map((x) => TallyItemModel.fromMap(x)) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TallyDataModel.fromJson(String source) =>
      TallyDataModel.fromMap(json.decode(source));
}

class TallyItemModel {
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

  const TallyItemModel({
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

  factory TallyItemModel.fromMap(Map<String, dynamic> map) {
    return TallyItemModel(
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
