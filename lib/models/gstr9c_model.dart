// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:convert';

class GSTR9C {
  GSTR9C({
    required this.gstin,
    required this.financialYear,
    required this.legalName,
    required this.tradeName,
    required this.reconciliation,
    required this.auditorRecommendation,
    required this.taxPayable,
    required this.auditorDetails,
    required this.certificationDetails,
  });

  factory GSTR9C.fromJson(Map<String, dynamic> json) {
    return GSTR9C(
      gstin: json['gstin'],
      financialYear: json['financial_year'],
      legalName: json['legal_name'],
      tradeName: json['trade_name'],
      reconciliation: GSTR9CReconciliation.fromJson(json['reconciliation']),
      auditorRecommendation:
          GSTR9CAuditorRecommendation.fromJson(json['auditor_recommendation']),
      taxPayable: GSTR9CTaxPayable.fromJson(json['tax_payable']),
      auditorDetails: json['auditor_details'],
      certificationDetails: json['certification_details'],
    );
  }
  final String gstin;
  final String financialYear;
  final String legalName;
  final String tradeName;
  final GSTR9CReconciliation reconciliation;
  final GSTR9CAuditorRecommendation auditorRecommendation;
  final GSTR9CTaxPayable taxPayable;
  final String auditorDetails;
  final String certificationDetails;

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'financial_year': financialYear,
      'legal_name': legalName,
      'trade_name': tradeName,
      'reconciliation': reconciliation.toJson(),
      'auditor_recommendation': auditorRecommendation.toJson(),
      'tax_payable': taxPayable.toJson(),
      'auditor_details': auditorDetails,
      'certification_details': certificationDetails,
    };
  }
}

class GSTR9CReconciliation {
  GSTR9CReconciliation({
    required this.turnoverAsPerAuditedFinancialStatements,
    required this.turnoverAsPerAnnualReturn,
    required this.unReconciled,
    required this.reconciliationItems,
  });

  factory GSTR9CReconciliation.fromJson(Map<String, dynamic> json) {
    List<GSTR9CReconciliationItem> items = [];
    if (json['reconciliation_items'] != null) {
      json['reconciliation_items'].forEach((item) {
        items.add(GSTR9CReconciliationItem.fromJson(item));
      });
    }

    return GSTR9CReconciliation(
      turnoverAsPerAuditedFinancialStatements:
          json['turnover_as_per_audited_financial_statements'] ?? 0.0,
      turnoverAsPerAnnualReturn: json['turnover_as_per_annual_return'] ?? 0.0,
      unReconciled: json['un_reconciled'] ?? 0.0,
      reconciliationItems: items,
    );
  }
  final double turnoverAsPerAuditedFinancialStatements;
  final double turnoverAsPerAnnualReturn;
  final double unReconciled;
  final List<GSTR9CReconciliationItem> reconciliationItems;

  Map<String, dynamic> toJson() {
    return {
      'turnover_as_per_audited_financial_statements':
          turnoverAsPerAuditedFinancialStatements,
      'turnover_as_per_annual_return': turnoverAsPerAnnualReturn,
      'un_reconciled': unReconciled,
      'reconciliation_items':
          reconciliationItems.map((item) => item.toJson()).toList(),
    };
  }
}

class GSTR9CReconciliationItem {
  GSTR9CReconciliationItem({
    required this.description,
    required this.amount,
    required this.reason,
  });

  factory GSTR9CReconciliationItem.fromJson(Map<String, dynamic> json) {
    return GSTR9CReconciliationItem(
      description: json['description'],
      amount: json['amount'] ?? 0.0,
      reason: json['reason'],
    );
  }
  final String description;
  final double amount;
  final String reason;

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'reason': reason,
    };
  }
}

class GSTR9CAuditorRecommendation {
  GSTR9CAuditorRecommendation({
    required this.recommendations,
  });

  factory GSTR9CAuditorRecommendation.fromJson(Map<String, dynamic> json) {
    List<GSTR9CAuditorRecommendationItem> items = [];
    if (json['recommendations'] != null) {
      json['recommendations'].forEach((item) {
        items.add(GSTR9CAuditorRecommendationItem.fromJson(item));
      });
    }

    return GSTR9CAuditorRecommendation(
      recommendations: items,
    );
  }
  final List<GSTR9CAuditorRecommendationItem> recommendations;

  Map<String, dynamic> toJson() {
    return {
      'recommendations': recommendations.map((item) => item.toJson()).toList(),
    };
  }
}

class GSTR9CAuditorRecommendationItem {
  GSTR9CAuditorRecommendationItem({
    required this.description,
    required this.amount,
    required this.reason,
  });

  factory GSTR9CAuditorRecommendationItem.fromJson(Map<String, dynamic> json) {
    return GSTR9CAuditorRecommendationItem(
      description: json['description'],
      amount: json['amount'] ?? 0.0,
      reason: json['reason'],
    );
  }
  final String description;
  final double amount;
  final String reason;

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'reason': reason,
    };
  }
}

class GSTR9CTaxPayable {
  GSTR9CTaxPayable({
    required this.taxPayableAsPerReconciliation,
    required this.taxPaidAsPerAnnualReturn,
    required this.differentialTaxPayable,
    required this.interestPayable,
  });

  factory GSTR9CTaxPayable.fromJson(Map<String, dynamic> json) {
    return GSTR9CTaxPayable(
      taxPayableAsPerReconciliation:
          json['tax_payable_as_per_reconciliation'] ?? 0.0,
      taxPaidAsPerAnnualReturn: json['tax_paid_as_per_annual_return'] ?? 0.0,
      differentialTaxPayable: json['differential_tax_payable'] ?? 0.0,
      interestPayable: json['interest_payable'] ?? 0.0,
    );
  }
  final double taxPayableAsPerReconciliation;
  final double taxPaidAsPerAnnualReturn;
  final double differentialTaxPayable;
  final double interestPayable;

  Map<String, dynamic> toJson() {
    return {
      'tax_payable_as_per_reconciliation': taxPayableAsPerReconciliation,
      'tax_paid_as_per_annual_return': taxPaidAsPerAnnualReturn,
      'differential_tax_payable': differentialTaxPayable,
      'interest_payable': interestPayable,
    };
  }
}

/// Model class for GSTR9C Reconciliation Statement
class GSTR9CModel {
  GSTR9CModel({
    required this.gstin,
    required this.financialYear,
    required this.part5,
    required this.part7,
    required this.part8,
    required this.part9,
    required this.part10,
    required this.part11,
    required this.part12,
    required this.part13,
    required this.part14,
  });

  factory GSTR9CModel.fromMap(Map<String, dynamic> map) {
    return GSTR9CModel(
      gstin: map['gstin'] ?? '',
      financialYear: map['financialYear'] ?? '',
      part5: GSTR9CPart5.fromMap(map['part5']),
      part7: GSTR9CPart7.fromMap(map['part7']),
      part8: GSTR9CPart8.fromMap(map['part8']),
      part9: GSTR9CPart9.fromMap(map['part9']),
      part10: GSTR9CPart10.fromMap(map['part10']),
      part11: GSTR9CPart11.fromMap(map['part11']),
      part12: GSTR9CPart12.fromMap(map['part12']),
      part13: GSTR9CPart13.fromMap(map['part13']),
      part14: GSTR9CPart14.fromMap(map['part14']),
    );
  }

  factory GSTR9CModel.fromJson(String source) =>
      GSTR9CModel.fromMap(json.decode(source));
  final String gstin;
  final String financialYear;
  final GSTR9CPart5 part5;
  final GSTR9CPart7 part7;
  final GSTR9CPart8 part8;
  final GSTR9CPart9 part9;
  final GSTR9CPart10 part10;
  final GSTR9CPart11 part11;
  final GSTR9CPart12 part12;
  final GSTR9CPart13 part13;
  final GSTR9CPart14 part14;

  GSTR9CModel copyWith({
    String? gstin,
    String? financialYear,
    GSTR9CPart5? part5,
    GSTR9CPart7? part7,
    GSTR9CPart8? part8,
    GSTR9CPart9? part9,
    GSTR9CPart10? part10,
    GSTR9CPart11? part11,
    GSTR9CPart12? part12,
    GSTR9CPart13? part13,
    GSTR9CPart14? part14,
  }) {
    return GSTR9CModel(
      gstin: gstin ?? this.gstin,
      financialYear: financialYear ?? this.financialYear,
      part5: part5 ?? this.part5,
      part7: part7 ?? this.part7,
      part8: part8 ?? this.part8,
      part9: part9 ?? this.part9,
      part10: part10 ?? this.part10,
      part11: part11 ?? this.part11,
      part12: part12 ?? this.part12,
      part13: part13 ?? this.part13,
      part14: part14 ?? this.part14,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gstin': gstin,
      'financialYear': financialYear,
      'part5': part5.toMap(),
      'part7': part7.toMap(),
      'part8': part8.toMap(),
      'part9': part9.toMap(),
      'part10': part10.toMap(),
      'part11': part11.toMap(),
      'part12': part12.toMap(),
      'part13': part13.toMap(),
      'part14': part14.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'GSTR9CModel(gstin: $gstin, financialYear: $financialYear, part5: $part5, part7: $part7, part8: $part8, part9: $part9, part10: $part10, part11: $part11, part12: $part12, part13: $part13, part14: $part14)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CModel &&
        other.gstin == gstin &&
        other.financialYear == financialYear &&
        other.part5 == part5 &&
        other.part7 == part7 &&
        other.part8 == part8 &&
        other.part9 == part9 &&
        other.part10 == part10 &&
        other.part11 == part11 &&
        other.part12 == part12 &&
        other.part13 == part13 &&
        other.part14 == part14;
  }

  @override
  int get hashCode {
    return gstin.hashCode ^
        financialYear.hashCode ^
        part5.hashCode ^
        part7.hashCode ^
        part8.hashCode ^
        part9.hashCode ^
        part10.hashCode ^
        part11.hashCode ^
        part12.hashCode ^
        part13.hashCode ^
        part14.hashCode;
  }
}

/// Part 5 of GSTR9C - Reconciliation of turnover declared in audited Annual Financial Statement with turnover declared in Annual Return (GSTR9)
class GSTR9CPart5 {
  GSTR9CPart5({
    required this.turnoverAsPerAuditedFinancialStatements,
    required this.turnoverAsPerAnnualReturn,
    required this.unReconciled,
  });

  factory GSTR9CPart5.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart5(
      turnoverAsPerAuditedFinancialStatements:
          map['turnoverAsPerAuditedFinancialStatements']?.toDouble() ?? 0.0,
      turnoverAsPerAnnualReturn:
          map['turnoverAsPerAnnualReturn']?.toDouble() ?? 0.0,
      unReconciled: map['unReconciled']?.toDouble() ?? 0.0,
    );
  }

  factory GSTR9CPart5.fromJson(String source) =>
      GSTR9CPart5.fromMap(json.decode(source));
  final double turnoverAsPerAuditedFinancialStatements;
  final double turnoverAsPerAnnualReturn;
  final double unReconciled;

  GSTR9CPart5 copyWith({
    double? turnoverAsPerAuditedFinancialStatements,
    double? turnoverAsPerAnnualReturn,
    double? unReconciled,
  }) {
    return GSTR9CPart5(
      turnoverAsPerAuditedFinancialStatements:
          turnoverAsPerAuditedFinancialStatements ??
              this.turnoverAsPerAuditedFinancialStatements,
      turnoverAsPerAnnualReturn:
          turnoverAsPerAnnualReturn ?? this.turnoverAsPerAnnualReturn,
      unReconciled: unReconciled ?? this.unReconciled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'turnoverAsPerAuditedFinancialStatements':
          turnoverAsPerAuditedFinancialStatements,
      'turnoverAsPerAnnualReturn': turnoverAsPerAnnualReturn,
      'unReconciled': unReconciled,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'GSTR9CPart5(turnoverAsPerAuditedFinancialStatements: $turnoverAsPerAuditedFinancialStatements, turnoverAsPerAnnualReturn: $turnoverAsPerAnnualReturn, unReconciled: $unReconciled)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart5 &&
        other.turnoverAsPerAuditedFinancialStatements ==
            turnoverAsPerAuditedFinancialStatements &&
        other.turnoverAsPerAnnualReturn == turnoverAsPerAnnualReturn &&
        other.unReconciled == unReconciled;
  }

  @override
  int get hashCode =>
      turnoverAsPerAuditedFinancialStatements.hashCode ^
      turnoverAsPerAnnualReturn.hashCode ^
      unReconciled.hashCode;
}

/// Part 7 of GSTR9C - Reconciliation of tax paid
class GSTR9CPart7 {
  GSTR9CPart7({
    required this.taxPayableAsPerBooks,
    required this.taxPayableAsPerGSTR9,
    required this.difference,
  });

  factory GSTR9CPart7.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart7(
      taxPayableAsPerBooks: map['taxPayableAsPerBooks']?.toDouble() ?? 0.0,
      taxPayableAsPerGSTR9: map['taxPayableAsPerGSTR9']?.toDouble() ?? 0.0,
      difference: map['difference']?.toDouble() ?? 0.0,
    );
  }

  factory GSTR9CPart7.fromJson(String source) =>
      GSTR9CPart7.fromMap(json.decode(source));
  final double taxPayableAsPerBooks;
  final double taxPayableAsPerGSTR9;
  final double difference;

  GSTR9CPart7 copyWith({
    double? taxPayableAsPerBooks,
    double? taxPayableAsPerGSTR9,
    double? difference,
  }) {
    return GSTR9CPart7(
      taxPayableAsPerBooks: taxPayableAsPerBooks ?? this.taxPayableAsPerBooks,
      taxPayableAsPerGSTR9: taxPayableAsPerGSTR9 ?? this.taxPayableAsPerGSTR9,
      difference: difference ?? this.difference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taxPayableAsPerBooks': taxPayableAsPerBooks,
      'taxPayableAsPerGSTR9': taxPayableAsPerGSTR9,
      'difference': difference,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'GSTR9CPart7(taxPayableAsPerBooks: $taxPayableAsPerBooks, taxPayableAsPerGSTR9: $taxPayableAsPerGSTR9, difference: $difference)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart7 &&
        other.taxPayableAsPerBooks == taxPayableAsPerBooks &&
        other.taxPayableAsPerGSTR9 == taxPayableAsPerGSTR9 &&
        other.difference == difference;
  }

  @override
  int get hashCode =>
      taxPayableAsPerBooks.hashCode ^
      taxPayableAsPerGSTR9.hashCode ^
      difference.hashCode;
}

/// Part 8 of GSTR9C - Reasons for un-reconciled payment of amount
class GSTR9CPart8 {
  GSTR9CPart8({
    required this.reasons,
  });

  factory GSTR9CPart8.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart8(
      reasons: map['reasons'] ?? '',
    );
  }

  factory GSTR9CPart8.fromJson(String source) =>
      GSTR9CPart8.fromMap(json.decode(source));
  final String reasons;

  GSTR9CPart8 copyWith({
    String? reasons,
  }) {
    return GSTR9CPart8(
      reasons: reasons ?? this.reasons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reasons': reasons,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'GSTR9CPart8(reasons: $reasons)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart8 && other.reasons == reasons;
  }

  @override
  int get hashCode => reasons.hashCode;
}

/// Part 9 of GSTR9C - Auditor's recommendation on additional liability due to non-reconciliation
class GSTR9CPart9 {
  GSTR9CPart9({
    required this.additionalLiabilityIGST,
    required this.additionalLiabilityCGST,
    required this.additionalLiabilitySGST,
    required this.additionalLiabilityCess,
  });

  factory GSTR9CPart9.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart9(
      additionalLiabilityIGST:
          map['additionalLiabilityIGST']?.toDouble() ?? 0.0,
      additionalLiabilityCGST:
          map['additionalLiabilityCGST']?.toDouble() ?? 0.0,
      additionalLiabilitySGST:
          map['additionalLiabilitySGST']?.toDouble() ?? 0.0,
      additionalLiabilityCess:
          map['additionalLiabilityCess']?.toDouble() ?? 0.0,
    );
  }

  factory GSTR9CPart9.fromJson(String source) =>
      GSTR9CPart9.fromMap(json.decode(source));
  final double additionalLiabilityIGST;
  final double additionalLiabilityCGST;
  final double additionalLiabilitySGST;
  final double additionalLiabilityCess;

  GSTR9CPart9 copyWith({
    double? additionalLiabilityIGST,
    double? additionalLiabilityCGST,
    double? additionalLiabilitySGST,
    double? additionalLiabilityCess,
  }) {
    return GSTR9CPart9(
      additionalLiabilityIGST:
          additionalLiabilityIGST ?? this.additionalLiabilityIGST,
      additionalLiabilityCGST:
          additionalLiabilityCGST ?? this.additionalLiabilityCGST,
      additionalLiabilitySGST:
          additionalLiabilitySGST ?? this.additionalLiabilitySGST,
      additionalLiabilityCess:
          additionalLiabilityCess ?? this.additionalLiabilityCess,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'additionalLiabilityIGST': additionalLiabilityIGST,
      'additionalLiabilityCGST': additionalLiabilityCGST,
      'additionalLiabilitySGST': additionalLiabilitySGST,
      'additionalLiabilityCess': additionalLiabilityCess,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'GSTR9CPart9(additionalLiabilityIGST: $additionalLiabilityIGST, additionalLiabilityCGST: $additionalLiabilityCGST, additionalLiabilitySGST: $additionalLiabilitySGST, additionalLiabilityCess: $additionalLiabilityCess)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart9 &&
        other.additionalLiabilityIGST == additionalLiabilityIGST &&
        other.additionalLiabilityCGST == additionalLiabilityCGST &&
        other.additionalLiabilitySGST == additionalLiabilitySGST &&
        other.additionalLiabilityCess == additionalLiabilityCess;
  }

  @override
  int get hashCode {
    return additionalLiabilityIGST.hashCode ^
        additionalLiabilityCGST.hashCode ^
        additionalLiabilitySGST.hashCode ^
        additionalLiabilityCess.hashCode;
  }
}

/// Part 10 of GSTR9C - Reconciliation of Input Tax Credit (ITC)
class GSTR9CPart10 {
  GSTR9CPart10({
    required this.itcAvailedAsPerAuditedFinancialStatements,
    required this.itcAvailedAsPerAnnualReturn,
    required this.difference,
  });

  factory GSTR9CPart10.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart10(
      itcAvailedAsPerAuditedFinancialStatements:
          map['itcAvailedAsPerAuditedFinancialStatements']?.toDouble() ?? 0.0,
      itcAvailedAsPerAnnualReturn:
          map['itcAvailedAsPerAnnualReturn']?.toDouble() ?? 0.0,
      difference: map['difference']?.toDouble() ?? 0.0,
    );
  }

  factory GSTR9CPart10.fromJson(String source) =>
      GSTR9CPart10.fromMap(json.decode(source));
  final double itcAvailedAsPerAuditedFinancialStatements;
  final double itcAvailedAsPerAnnualReturn;
  final double difference;

  GSTR9CPart10 copyWith({
    double? itcAvailedAsPerAuditedFinancialStatements,
    double? itcAvailedAsPerAnnualReturn,
    double? difference,
  }) {
    return GSTR9CPart10(
      itcAvailedAsPerAuditedFinancialStatements:
          itcAvailedAsPerAuditedFinancialStatements ??
              this.itcAvailedAsPerAuditedFinancialStatements,
      itcAvailedAsPerAnnualReturn:
          itcAvailedAsPerAnnualReturn ?? this.itcAvailedAsPerAnnualReturn,
      difference: difference ?? this.difference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itcAvailedAsPerAuditedFinancialStatements':
          itcAvailedAsPerAuditedFinancialStatements,
      'itcAvailedAsPerAnnualReturn': itcAvailedAsPerAnnualReturn,
      'difference': difference,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'GSTR9CPart10(itcAvailedAsPerAuditedFinancialStatements: $itcAvailedAsPerAuditedFinancialStatements, itcAvailedAsPerAnnualReturn: $itcAvailedAsPerAnnualReturn, difference: $difference)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart10 &&
        other.itcAvailedAsPerAuditedFinancialStatements ==
            itcAvailedAsPerAuditedFinancialStatements &&
        other.itcAvailedAsPerAnnualReturn == itcAvailedAsPerAnnualReturn &&
        other.difference == difference;
  }

  @override
  int get hashCode =>
      itcAvailedAsPerAuditedFinancialStatements.hashCode ^
      itcAvailedAsPerAnnualReturn.hashCode ^
      difference.hashCode;
}

/// Part 11 of GSTR9C - Reasons for un-reconciled difference in ITC
class GSTR9CPart11 {
  GSTR9CPart11({
    required this.reasons,
  });

  factory GSTR9CPart11.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart11(
      reasons: map['reasons'] ?? '',
    );
  }

  factory GSTR9CPart11.fromJson(String source) =>
      GSTR9CPart11.fromMap(json.decode(source));
  final String reasons;

  GSTR9CPart11 copyWith({
    String? reasons,
  }) {
    return GSTR9CPart11(
      reasons: reasons ?? this.reasons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reasons': reasons,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'GSTR9CPart11(reasons: $reasons)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart11 && other.reasons == reasons;
  }

  @override
  int get hashCode => reasons.hashCode;
}

/// Part 12 of GSTR9C - Additional amount payable but not paid
class GSTR9CPart12 {
  GSTR9CPart12({
    required this.additionalAmountPayableIGST,
    required this.additionalAmountPayableCGST,
    required this.additionalAmountPayableSGST,
    required this.additionalAmountPayableCess,
  });

  factory GSTR9CPart12.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart12(
      additionalAmountPayableIGST:
          map['additionalAmountPayableIGST']?.toDouble() ?? 0.0,
      additionalAmountPayableCGST:
          map['additionalAmountPayableCGST']?.toDouble() ?? 0.0,
      additionalAmountPayableSGST:
          map['additionalAmountPayableSGST']?.toDouble() ?? 0.0,
      additionalAmountPayableCess:
          map['additionalAmountPayableCess']?.toDouble() ?? 0.0,
    );
  }

  factory GSTR9CPart12.fromJson(String source) =>
      GSTR9CPart12.fromMap(json.decode(source));
  final double additionalAmountPayableIGST;
  final double additionalAmountPayableCGST;
  final double additionalAmountPayableSGST;
  final double additionalAmountPayableCess;

  GSTR9CPart12 copyWith({
    double? additionalAmountPayableIGST,
    double? additionalAmountPayableCGST,
    double? additionalAmountPayableSGST,
    double? additionalAmountPayableCess,
  }) {
    return GSTR9CPart12(
      additionalAmountPayableIGST:
          additionalAmountPayableIGST ?? this.additionalAmountPayableIGST,
      additionalAmountPayableCGST:
          additionalAmountPayableCGST ?? this.additionalAmountPayableCGST,
      additionalAmountPayableSGST:
          additionalAmountPayableSGST ?? this.additionalAmountPayableSGST,
      additionalAmountPayableCess:
          additionalAmountPayableCess ?? this.additionalAmountPayableCess,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'additionalAmountPayableIGST': additionalAmountPayableIGST,
      'additionalAmountPayableCGST': additionalAmountPayableCGST,
      'additionalAmountPayableSGST': additionalAmountPayableSGST,
      'additionalAmountPayableCess': additionalAmountPayableCess,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'GSTR9CPart12(additionalAmountPayableIGST: $additionalAmountPayableIGST, additionalAmountPayableCGST: $additionalAmountPayableCGST, additionalAmountPayableSGST: $additionalAmountPayableSGST, additionalAmountPayableCess: $additionalAmountPayableCess)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart12 &&
        other.additionalAmountPayableIGST == additionalAmountPayableIGST &&
        other.additionalAmountPayableCGST == additionalAmountPayableCGST &&
        other.additionalAmountPayableSGST == additionalAmountPayableSGST &&
        other.additionalAmountPayableCess == additionalAmountPayableCess;
  }

  @override
  int get hashCode {
    return additionalAmountPayableIGST.hashCode ^
        additionalAmountPayableCGST.hashCode ^
        additionalAmountPayableSGST.hashCode ^
        additionalAmountPayableCess.hashCode;
  }
}

/// Part 13 of GSTR9C - Verification
class GSTR9CPart13 {
  GSTR9CPart13({
    required this.verificationText,
    required this.place,
    required this.date,
    required this.nameOfAuthorizedPerson,
    required this.designation,
  });

  factory GSTR9CPart13.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart13(
      verificationText: map['verificationText'] ?? '',
      place: map['place'] ?? '',
      date: map['date'] ?? '',
      nameOfAuthorizedPerson: map['nameOfAuthorizedPerson'] ?? '',
      designation: map['designation'] ?? '',
    );
  }

  factory GSTR9CPart13.fromJson(String source) =>
      GSTR9CPart13.fromMap(json.decode(source));
  final String verificationText;
  final String place;
  final String date;
  final String nameOfAuthorizedPerson;
  final String designation;

  GSTR9CPart13 copyWith({
    String? verificationText,
    String? place,
    String? date,
    String? nameOfAuthorizedPerson,
    String? designation,
  }) {
    return GSTR9CPart13(
      verificationText: verificationText ?? this.verificationText,
      place: place ?? this.place,
      date: date ?? this.date,
      nameOfAuthorizedPerson:
          nameOfAuthorizedPerson ?? this.nameOfAuthorizedPerson,
      designation: designation ?? this.designation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'verificationText': verificationText,
      'place': place,
      'date': date,
      'nameOfAuthorizedPerson': nameOfAuthorizedPerson,
      'designation': designation,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'GSTR9CPart13(verificationText: $verificationText, place: $place, date: $date, nameOfAuthorizedPerson: $nameOfAuthorizedPerson, designation: $designation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart13 &&
        other.verificationText == verificationText &&
        other.place == place &&
        other.date == date &&
        other.nameOfAuthorizedPerson == nameOfAuthorizedPerson &&
        other.designation == designation;
  }

  @override
  int get hashCode {
    return verificationText.hashCode ^
        place.hashCode ^
        date.hashCode ^
        nameOfAuthorizedPerson.hashCode ^
        designation.hashCode;
  }
}

/// Part 14 of GSTR9C - Certification
class GSTR9CPart14 {
  GSTR9CPart14({
    required this.certificationType,
    required this.certificationText,
    required this.nameOfCertifyingPerson,
    required this.membershipNumber,
    required this.firmRegistrationNumber,
    required this.place,
    required this.date,
  });

  factory GSTR9CPart14.fromMap(Map<String, dynamic> map) {
    return GSTR9CPart14(
      certificationType: map['certificationType'] ?? '',
      certificationText: map['certificationText'] ?? '',
      nameOfCertifyingPerson: map['nameOfCertifyingPerson'] ?? '',
      membershipNumber: map['membershipNumber'] ?? '',
      firmRegistrationNumber: map['firmRegistrationNumber'] ?? '',
      place: map['place'] ?? '',
      date: map['date'] ?? '',
    );
  }

  factory GSTR9CPart14.fromJson(String source) =>
      GSTR9CPart14.fromMap(json.decode(source));
  final String certificationType;
  final String certificationText;
  final String nameOfCertifyingPerson;
  final String membershipNumber;
  final String firmRegistrationNumber;
  final String place;
  final String date;

  GSTR9CPart14 copyWith({
    String? certificationType,
    String? certificationText,
    String? nameOfCertifyingPerson,
    String? membershipNumber,
    String? firmRegistrationNumber,
    String? place,
    String? date,
  }) {
    return GSTR9CPart14(
      certificationType: certificationType ?? this.certificationType,
      certificationText: certificationText ?? this.certificationText,
      nameOfCertifyingPerson:
          nameOfCertifyingPerson ?? this.nameOfCertifyingPerson,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      firmRegistrationNumber:
          firmRegistrationNumber ?? this.firmRegistrationNumber,
      place: place ?? this.place,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'certificationType': certificationType,
      'certificationText': certificationText,
      'nameOfCertifyingPerson': nameOfCertifyingPerson,
      'membershipNumber': membershipNumber,
      'firmRegistrationNumber': firmRegistrationNumber,
      'place': place,
      'date': date,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'GSTR9CPart14(certificationType: $certificationType, certificationText: $certificationText, nameOfCertifyingPerson: $nameOfCertifyingPerson, membershipNumber: $membershipNumber, firmRegistrationNumber: $firmRegistrationNumber, place: $place, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSTR9CPart14 &&
        other.certificationType == certificationType &&
        other.certificationText == certificationText &&
        other.nameOfCertifyingPerson == nameOfCertifyingPerson &&
        other.membershipNumber == membershipNumber &&
        other.firmRegistrationNumber == firmRegistrationNumber &&
        other.place == place &&
        other.date == date;
  }

  @override
  int get hashCode {
    return certificationType.hashCode ^
        certificationText.hashCode ^
        nameOfCertifyingPerson.hashCode ^
        membershipNumber.hashCode ^
        firmRegistrationNumber.hashCode ^
        place.hashCode ^
        date.hashCode;
  }
}
