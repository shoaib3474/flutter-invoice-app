import 'dart:convert';
import 'package:flutter/foundation.dart';

class GSTR9 {
  final String gstin;
  final String financialYear;
  final String legalName;
  final String tradeName;
  final GSTR9Part4 part4;
  final GSTR9Part5 part5;
  final GSTR9Part6 part6;
  
  // Parts 1-3 are auto-populated from GSTR1 and GSTR3B
  final GSTR9Part1 part1;
  final GSTR9Part2 part2;
  final GSTR9Part3 part3;

  GSTR9({
    required this.gstin,
    required this.financialYear,
    required this.legalName,
    required this.tradeName,
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
    required this.part5,
    required this.part6,
  });

  factory GSTR9.fromJson(Map<String, dynamic> json) {
    return GSTR9(
      gstin: json['gstin'],
      financialYear: json['financial_year'],
      legalName: json['legal_name'],
      tradeName: json['trade_name'],
      part1: GSTR9Part1.fromJson(json['part1']),
      part2: GSTR9Part2.fromJson(json['part2']),
      part3: GSTR9Part3.fromJson(json['part3']),
      part4: GSTR9Part4.fromJson(json['part4']),
      part5: GSTR9Part5.fromJson(json['part5']),
      part6: GSTR9Part6.fromJson(json['part6']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'financial_year': financialYear,
      'legal_name': legalName,
      'trade_name': tradeName,
      'part1': part1.toJson(),
      'part2': part2.toJson(),
      'part3': part3.toJson(),
      'part4': part4.toJson(),
      'part5': part5.toJson(),
      'part6': part6.toJson(),
    };
  }
}

class GSTR9Part1 {
  final double totalOutwardSupplies;
  final double zeroRatedSupplies;
  final double nilRatedSupplies;
  final double exemptedSupplies;
  final double nonGSTSupplies;

  GSTR9Part1({
    required this.totalOutwardSupplies,
    required this.zeroRatedSupplies,
    required this.nilRatedSupplies,
    required this.exemptedSupplies,
    required this.nonGSTSupplies,
  });

  factory GSTR9Part1.fromJson(Map<String, dynamic> json) {
    return GSTR9Part1(
      totalOutwardSupplies: json['total_outward_supplies'] ?? 0.0,
      zeroRatedSupplies: json['zero_rated_supplies'] ?? 0.0,
      nilRatedSupplies: json['nil_rated_supplies'] ?? 0.0,
      exemptedSupplies: json['exempted_supplies'] ?? 0.0,
      nonGSTSupplies: json['non_gst_supplies'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_outward_supplies': totalOutwardSupplies,
      'zero_rated_supplies': zeroRatedSupplies,
      'nil_rated_supplies': nilRatedSupplies,
      'exempted_supplies': exemptedSupplies,
      'non_gst_supplies': nonGSTSupplies,
    };
  }
}

class GSTR9Part2 {
  final double inwardSuppliesAttractingReverseCharge;
  final double importsOfGoodsAndServices;
  final double inwardSuppliesLiableToReverseCharge;

  GSTR9Part2({
    required this.inwardSuppliesAttractingReverseCharge,
    required this.importsOfGoodsAndServices,
    required this.inwardSuppliesLiableToReverseCharge,
  });

  factory GSTR9Part2.fromJson(Map<String, dynamic> json) {
    return GSTR9Part2(
      inwardSuppliesAttractingReverseCharge: json['inward_supplies_attracting_reverse_charge'] ?? 0.0,
      importsOfGoodsAndServices: json['imports_of_goods_and_services'] ?? 0.0,
      inwardSuppliesLiableToReverseCharge: json['inward_supplies_liable_to_reverse_charge'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inward_supplies_attracting_reverse_charge': inwardSuppliesAttractingReverseCharge,
      'imports_of_goods_and_services': importsOfGoodsAndServices,
      'inward_supplies_liable_to_reverse_charge': inwardSuppliesLiableToReverseCharge,
    };
  }
}

class GSTR9Part3 {
  final double taxPayableOnOutwardSupplies;
  final double taxPayableOnReverseCharge;
  final double interestPayable;
  final double lateFeePayable;
  final double penaltyPayable;

  GSTR9Part3({
    required this.taxPayableOnOutwardSupplies,
    required this.taxPayableOnReverseCharge,
    required this.interestPayable,
    required this.lateFeePayable,
    required this.penaltyPayable,
  });

  factory GSTR9Part3.fromJson(Map<String, dynamic> json) {
    return GSTR9Part3(
      taxPayableOnOutwardSupplies: json['tax_payable_on_outward_supplies'] ?? 0.0,
      taxPayableOnReverseCharge: json['tax_payable_on_reverse_charge'] ?? 0.0,
      interestPayable: json['interest_payable'] ?? 0.0,
      lateFeePayable: json['late_fee_payable'] ?? 0.0,
      penaltyPayable: json['penalty_payable'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tax_payable_on_outward_supplies': taxPayableOnOutwardSupplies,
      'tax_payable_on_reverse_charge': taxPayableOnReverseCharge,
      'interest_payable': interestPayable,
      'late_fee_payable': lateFeePayable,
      'penalty_payable': penaltyPayable,
    };
  }
}

/// Part 4 of GSTR9 - Details of advances, inward and outward supplies made during the financial year on which tax is payable
class GSTR9Part4 {
  final double itcAvailedOnInvoices;
  final double itcReversedAndReclaimed;
  final double itcAvailedButIneligible;
  
  GSTR9Part4({
    required this.itcAvailedOnInvoices,
    required this.itcReversedAndReclaimed,
    required this.itcAvailedButIneligible,
  });

  factory GSTR9Part4.fromJson(Map<String, dynamic> json) {
    return GSTR9Part4(
      itcAvailedOnInvoices: json['itc_availed_on_invoices'] ?? 0.0,
      itcReversedAndReclaimed: json['itc_reversed_and_reclaimed'] ?? 0.0,
      itcAvailedButIneligible: json['itc_availed_but_ineligible'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itc_availed_on_invoices': itcAvailedOnInvoices,
      'itc_reversed_and_reclaimed': itcReversedAndReclaimed,
      'itc_availed_but_ineligible': itcAvailedButIneligible,
    };
  }

  GSTR9Part4 copyWith({
    double? itcAvailedOnInvoices,
    double? itcReversedAndReclaimed,
    double? itcAvailedButIneligible,
  }) {
    return GSTR9Part4(
      itcAvailedOnInvoices: itcAvailedOnInvoices ?? this.itcAvailedOnInvoices,
      itcReversedAndReclaimed: itcReversedAndReclaimed ?? this.itcReversedAndReclaimed,
      itcAvailedButIneligible: itcAvailedButIneligible ?? this.itcAvailedButIneligible,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itcAvailedOnInvoices': itcAvailedOnInvoices,
      'itcReversedAndReclaimed': itcReversedAndReclaimed,
      'itcAvailedButIneligible': itcAvailedButIneligible,
    };
  }

  factory GSTR9Part4.fromMap(Map<String, dynamic> map) {
    return GSTR9Part4(
      itcAvailedOnInvoices: map['itcAvailedOnInvoices']?.toDouble() ?? 0.0,
      itcReversedAndReclaimed: map['itcReversedAndReclaimed']?.toDouble() ?? 0.0,
      itcAvailedButIneligible: map['itcAvailedButIneligible']?.toDouble() ?? 0.0,
    );
  }

  String toJson2() => json.encode(toMap());

  factory GSTR9Part4.fromJson2(String source) => GSTR9Part4.fromMap(json.decode(source));

  @override
  String toString() {
    return 'GSTR9Part4(itcAvailedOnInvoices: $itcAvailedOnInvoices, itcReversedAndReclaimed: $itcReversedAndReclaimed, itcAvailedButIneligible: $itcAvailedButIneligible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GSTR9Part4 &&
      other.itcAvailedOnInvoices == itcAvailedOnInvoices &&
      other.itcReversedAndReclaimed == itcReversedAndReclaimed &&
      other.itcAvailedButIneligible == itcAvailedButIneligible;
  }

  @override
  int get hashCode {
    return itcAvailedOnInvoices.hashCode ^
      itcReversedAndReclaimed.hashCode ^
      itcAvailedButIneligible.hashCode;
  }
}

/// Part 5 of GSTR9 - Details of ITC availed during the financial year
class GSTR9Part5 {
  final double refundClaimed;
  final double refundSanctioned;
  final double refundRejected;
  final double refundPending;

  GSTR9Part5({
    required this.refundClaimed,
    required this.refundSanctioned,
    required this.refundRejected,
    required this.refundPending,
  });

  factory GSTR9Part5.fromJson(Map<String, dynamic> json) {
    return GSTR9Part5(
      refundClaimed: json['refund_claimed'] ?? 0.0,
      refundSanctioned: json['refund_sanctioned'] ?? 0.0,
      refundRejected: json['refund_rejected'] ?? 0.0,
      refundPending: json['refund_pending'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refund_claimed': refundClaimed,
      'refund_sanctioned': refundSanctioned,
      'refund_rejected': refundRejected,
      'refund_pending': refundPending,
    };
  }

  GSTR9Part5 copyWith({
    double? refundClaimed,
    double? refundSanctioned,
    double? refundRejected,
    double? refundPending,
  }) {
    return GSTR9Part5(
      refundClaimed: refundClaimed ?? this.refundClaimed,
      refundSanctioned: refundSanctioned ?? this.refundSanctioned,
      refundRejected: refundRejected ?? this.refundRejected,
      refundPending: refundPending ?? this.refundPending,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'refundClaimed': refundClaimed,
      'refundSanctioned': refundSanctioned,
      'refundRejected': refundRejected,
      'refundPending': refundPending,
    };
  }

  factory GSTR9Part5.fromMap(Map<String, dynamic> map) {
    return GSTR9Part5(
      refundClaimed: map['refundClaimed']?.toDouble() ?? 0.0,
      refundSanctioned: map['refundSanctioned']?.toDouble() ?? 0.0,
      refundRejected: map['refundRejected']?.toDouble() ?? 0.0,
      refundPending: map['refundPending']?.toDouble() ?? 0.0,
    );
  }

  String toJson2() => json.encode(toMap());

  factory GSTR9Part5.fromJson2(String source) => GSTR9Part5.fromMap(json.decode(source));

  @override
  String toString() {
    return 'GSTR9Part5(refundClaimed: $refundClaimed, refundSanctioned: $refundSanctioned, refundRejected: $refundRejected, refundPending: $refundPending)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GSTR9Part5 &&
      other.refundClaimed == refundClaimed &&
      other.refundSanctioned == refundSanctioned &&
      other.refundRejected == refundRejected &&
      other.refundPending == refundPending;
  }

  @override
  int get hashCode {
    return refundClaimed.hashCode ^
      refundSanctioned.hashCode ^
      refundRejected.hashCode ^
      refundPending.hashCode;
  }
}

/// Part 6 of GSTR9 - Details of ITC reversed and ineligible ITC as declared in returns filed during the financial year
class GSTR9Part6 {
  final double taxPayableAsPerSection73Or74;
  final double taxPaidAsPerSection73Or74;
  final double interestPayableAsPerSection73Or74;
  final double interestPaidAsPerSection73Or74;

  GSTR9Part6({
    required this.taxPayableAsPerSection73Or74,
    required this.taxPaidAsPerSection73Or74,
    required this.interestPayableAsPerSection73Or74,
    required this.interestPaidAsPerSection73Or74,
  });

  factory GSTR9Part6.fromJson(Map<String, dynamic> json) {
    return GSTR9Part6(
      taxPayableAsPerSection73Or74: json['tax_payable_as_per_section_73_or_74'] ?? 0.0,
      taxPaidAsPerSection73Or74: json['tax_paid_as_per_section_73_or_74'] ?? 0.0,
      interestPayableAsPerSection73Or74: json['interest_payable_as_per_section_73_or_74'] ?? 0.0,
      interestPaidAsPerSection73Or74: json['interest_paid_as_per_section_73_or_74'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tax_payable_as_per_section_73_or_74': taxPayableAsPerSection73Or74,
      'tax_paid_as_per_section_73_or_74': taxPaidAsPerSection73Or74,
      'interest_payable_as_per_section_73_or_74': interestPayableAsPerSection73Or74,
      'interest_paid_as_per_section_73_or_74': interestPaidAsPerSection73Or74,
    };
  }

  GSTR9Part6 copyWith({
    double? taxPayableAsPerSection73Or74,
    double? taxPaidAsPerSection73Or74,
    double? interestPayableAsPerSection73Or74,
    double? interestPaidAsPerSection73Or74,
  }) {
    return GSTR9Part6(
      taxPayableAsPerSection73Or74: taxPayableAsPerSection73Or74 ?? this.taxPayableAsPerSection73Or74,
      taxPaidAsPerSection73Or74: taxPaidAsPerSection73Or74 ?? this.taxPaidAsPerSection73Or74,
      interestPayableAsPerSection73Or74: interestPayableAsPerSection73Or74 ?? this.interestPayableAsPerSection73Or74,
      interestPaidAsPerSection73Or74: interestPaidAsPerSection73Or74 ?? this.interestPaidAsPerSection73Or74,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taxPayableAsPerSection73Or74': taxPayableAsPerSection73Or74,
      'taxPaidAsPerSection73Or74': taxPaidAsPerSection73Or74,
      'interestPayableAsPerSection73Or74': interestPayableAsPerSection73Or74,
      'interestPaidAsPerSection73Or74': interestPaidAsPerSection73Or74,
    };
  }

  factory GSTR9Part6.fromMap(Map<String, dynamic> map) {
    return GSTR9Part6(
      taxPayableAsPerSection73Or74: map['taxPayableAsPerSection73Or74']?.toDouble() ?? 0.0,
      taxPaidAsPerSection73Or74: map['taxPaidAsPerSection73Or74']?.toDouble() ?? 0.0,
      interestPayableAsPerSection73Or74: map['interestPayableAsPerSection73Or74']?.toDouble() ?? 0.0,
      interestPaidAsPerSection73Or74: map['interestPaidAsPerSection73Or74']?.toDouble() ?? 0.0,
    );
  }

  String toJson2() => json.encode(toMap());

  factory GSTR9Part6.fromJson2(String source) => GSTR9Part6.fromMap(json.decode(source));

  @override
  String toString() {
    return 'GSTR9Part6(taxPayableAsPerSection73Or74: $taxPayableAsPerSection73Or74, taxPaidAsPerSection73Or74: $taxPaidAsPerSection73Or74, interestPayableAsPerSection73Or74: $interestPayableAsPerSection73Or74, interestPaidAsPerSection73Or74: $interestPaidAsPerSection73Or74)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GSTR9Part6 &&
      other.taxPayableAsPerSection73Or74 == taxPayableAsPerSection73Or74 &&
      other.taxPaidAsPerSection73Or74 == taxPaidAsPerSection73Or74 &&
      other.interestPayableAsPerSection73Or74 == interestPayableAsPerSection73Or74 &&
      other.interestPaidAsPerSection73Or74 == interestPaidAsPerSection73Or74;
  }

  @override
  int get hashCode {
    return taxPayableAsPerSection73Or74.hashCode ^
      taxPaidAsPerSection73Or74.hashCode ^
      interestPayableAsPerSection73Or74.hashCode ^
      interestPaidAsPerSection73Or74.hashCode;
  }
}

/// Part 8 of GSTR9 - Other Information
class GSTR9Part8 {
  final double hsnSummaryTotalValue;
  final double hsnSummaryTotalTaxableValue;
  final double hsnSummaryTotalIGST;
  final double hsnSummaryTotalCGST;
  final double hsnSummaryTotalSGST;
  final double hsnSummaryTotalCess;
  
  GSTR9Part8({
    required this.hsnSummaryTotalValue,
    required this.hsnSummaryTotalTaxableValue,
    required this.hsnSummaryTotalIGST,
    required this.hsnSummaryTotalCGST,
    required this.hsnSummaryTotalSGST,
    required this.hsnSummaryTotalCess,
  });

  GSTR9Part8 copyWith({
    double? hsnSummaryTotalValue,
    double? hsnSummaryTotalTaxableValue,
    double? hsnSummaryTotalIGST,
    double? hsnSummaryTotalCGST,
    double? hsnSummaryTotalSGST,
    double? hsnSummaryTotalCess,
  }) {
    return GSTR9Part8(
      hsnSummaryTotalValue: hsnSummaryTotalValue ?? this.hsnSummaryTotalValue,
      hsnSummaryTotalTaxableValue: hsnSummaryTotalTaxableValue ?? this.hsnSummaryTotalTaxableValue,
      hsnSummaryTotalIGST: hsnSummaryTotalIGST ?? this.hsnSummaryTotalIGST,
      hsnSummaryTotalCGST: hsnSummaryTotalCGST ?? this.hsnSummaryTotalCGST,
      hsnSummaryTotalSGST: hsnSummaryTotalSGST ?? this.hsnSummaryTotalSGST,
      hsnSummaryTotalCess: hsnSummaryTotalCess ?? this.hsnSummaryTotalCess,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hsnSummaryTotalValue': hsnSummaryTotalValue,
      'hsnSummaryTotalTaxableValue': hsnSummaryTotalTaxableValue,
      'hsnSummaryTotalIGST': hsnSummaryTotalIGST,
      'hsnSummaryTotalCGST': hsnSummaryTotalCGST,
      'hsnSummaryTotalSGST': hsnSummaryTotalSGST,
      'hsnSummaryTotalCess': hsnSummaryTotalCess,
    };
  }

  factory GSTR9Part8.fromMap(Map<String, dynamic> map) {
    return GSTR9Part8(
      hsnSummaryTotalValue: map['hsnSummaryTotalValue']?.toDouble() ?? 0.0,
      hsnSummaryTotalTaxableValue: map['hsnSummaryTotalTaxableValue']?.toDouble() ?? 0.0,
      hsnSummaryTotalIGST: map['hsnSummaryTotalIGST']?.toDouble() ?? 0.0,
      hsnSummaryTotalCGST: map['hsnSummaryTotalCGST']?.toDouble() ?? 0.0,
      hsnSummaryTotalSGST: map['hsnSummaryTotalSGST']?.toDouble() ?? 0.0,
      hsnSummaryTotalCess: map['hsnSummaryTotalCess']?.toDouble() ?? 0.0,
    );
  }

  String toJson2() => json.encode(toMap());

  factory GSTR9Part8.fromJson2(String source) => GSTR9Part8.fromMap(json.decode(source));

  @override
  String toString() {
    return 'GSTR9Part8(hsnSummaryTotalValue: $hsnSummaryTotalValue, hsnSummaryTotalTaxableValue: $hsnSummaryTotalTaxableValue, hsnSummaryTotalIGST: $hsnSummaryTotalIGST, hsnSummaryTotalCGST: $hsnSummaryTotalCGST, hsnSummaryTotalSGST: $hsnSummaryTotalSGST, hsnSummaryTotalCess: $hsnSummaryTotalCess)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GSTR9Part8 &&
      other.hsnSummaryTotalValue == hsnSummaryTotalValue &&
      other.hsnSummaryTotalTaxableValue == hsnSummaryTotalTaxableValue &&
      other.hsnSummaryTotalIGST == hsnSummaryTotalIGST &&
      other.hsnSummaryTotalCGST == hsnSummaryTotalCGST &&
      other.hsnSummaryTotalSGST == hsnSummaryTotalSGST &&
      other.hsnSummaryTotalCess == hsnSummaryTotalCess;
  }

  @override
  int get hashCode {
    return hsnSummaryTotalValue.hashCode ^
      hsnSummaryTotalTaxableValue.hashCode ^
      hsnSummaryTotalIGST.hashCode ^
      hsnSummaryTotalCGST.hashCode ^
      hsnSummaryTotalSGST.hashCode ^
      hsnSummaryTotalCess.hashCode;
  }
}

/// Part 9 of GSTR9 - Details of tax paid as declared in returns filed during the financial year
class GSTR9Part9 {
  final double integratedTax;
  final double centralTax;
  final double stateTax;
  final double cess;
  final double interest;
  final double penalty;
  final double lateFee;
  final double other;
  
  GSTR9Part9({
    required this.integratedTax,
    required this.centralTax,
    required this.stateTax,
    required this.cess,
    required this.interest,
    required this.penalty,
    required this.lateFee,
    required this.other,
  });

  GSTR9Part9 copyWith({
    double? integratedTax,
    double? centralTax,
    double? stateTax,
    double? cess,
    double? interest,
    double? penalty,
    double? lateFee,
    double? other,
  }) {
    return GSTR9Part9(
      integratedTax: integratedTax ?? this.integratedTax,
      centralTax: centralTax ?? this.centralTax,
      stateTax: stateTax ?? this.stateTax,
      cess: cess ?? this.cess,
      interest: interest ?? this.interest,
      penalty: penalty ?? this.penalty,
      lateFee: lateFee ?? this.lateFee,
      other: other ?? this.other,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'integratedTax': integratedTax,
      'centralTax': centralTax,
      'stateTax': stateTax,
      'cess': cess,
      'interest': interest,
      'penalty': penalty,
      'lateFee': lateFee,
      'other': other,
    };
  }

  factory GSTR9Part9.fromMap(Map<String, dynamic> map) {
    return GSTR9Part9(
      integratedTax: map['integratedTax']?.toDouble() ?? 0.0,
      centralTax: map['centralTax']?.toDouble() ?? 0.0,
      stateTax: map['stateTax']?.toDouble() ?? 0.0,
      cess: map['cess']?.toDouble() ?? 0.0,
      interest: map['interest']?.toDouble() ?? 0.0,
      penalty: map['penalty']?.toDouble() ?? 0.0,
      lateFee: map['lateFee']?.toDouble() ?? 0.0,
      other: map['other']?.toDouble() ?? 0.0,
    );
  }

  String toJson2() => json.encode(toMap());

  factory GSTR9Part9.fromJson2(String source) => GSTR9Part9.fromMap(json.decode(source));

  @override
  String toString() {
    return 'GSTR9Part9(integratedTax: $integratedTax, centralTax: $centralTax, stateTax: $stateTax, cess: $cess, interest: $interest, penalty: $penalty, lateFee: $lateFee, other: $other)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GSTR9Part9 &&
      other.integratedTax == integratedTax &&
      other.centralTax == centralTax &&
      other.stateTax == stateTax &&
      other.cess == cess &&
      other.interest == interest &&
      other.penalty == penalty &&
      other.lateFee == lateFee &&
      other.other == this.other;
  }

  @override
  int get hashCode {
    return integratedTax.hashCode ^
      centralTax.hashCode ^
      stateTax.hashCode ^
      cess.hashCode ^
      interest.hashCode ^
      penalty.hashCode ^
      lateFee.hashCode ^
      other.hashCode;
  }
}
