import 'package:json_annotation/json_annotation.dart';

part 'gstr9c_model.g.dart';

@JsonSerializable()
class GSTR9C {
  final String gstin;
  final String financialYear;
  final String legalName;
  final String tradeName;
  final GSTR9CReconciliation reconciliation;
  final GSTR9CAuditorRecommendation auditorRecommendation;
  final GSTR9CTaxPayable taxPayable;
  final String auditorDetails;
  final String certificationDetails;

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

  factory GSTR9C.fromJson(Map<String, dynamic> json) => _$GSTR9CFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9CToJson(this);
}

@JsonSerializable()
class GSTR9CReconciliation {
  final double turnoverAsPerAuditedFinancialStatements;
  final double turnoverAsPerAnnualReturn;
  final double unReconciled;
  final List<GSTR9CReconciliationItem> reconciliationItems;

  GSTR9CReconciliation({
    required this.turnoverAsPerAuditedFinancialStatements,
    required this.turnoverAsPerAnnualReturn,
    required this.unReconciled,
    required this.reconciliationItems,
  });

  factory GSTR9CReconciliation.fromJson(Map<String, dynamic> json) => _$GSTR9CReconciliationFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9CReconciliationToJson(this);
}

@JsonSerializable()
class GSTR9CReconciliationItem {
  final String description;
  final double amount;
  final String reason;

  GSTR9CReconciliationItem({
    required this.description,
    required this.amount,
    required this.reason,
  });

  factory GSTR9CReconciliationItem.fromJson(Map<String, dynamic> json) => _$GSTR9CReconciliationItemFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9CReconciliationItemToJson(this);
}

@JsonSerializable()
class GSTR9CAuditorRecommendation {
  final List<GSTR9CAuditorRecommendationItem> recommendations;

  GSTR9CAuditorRecommendation({
    required this.recommendations,
  });

  factory GSTR9CAuditorRecommendation.fromJson(Map<String, dynamic> json) => _$GSTR9CAuditorRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9CAuditorRecommendationToJson(this);
}

@JsonSerializable()
class GSTR9CAuditorRecommendationItem {
  final String description;
  final double amount;
  final String reason;

  GSTR9CAuditorRecommendationItem({
    required this.description,
    required this.amount,
    required this.reason,
  });

  factory GSTR9CAuditorRecommendationItem.fromJson(Map<String, dynamic> json) => _$GSTR9CAuditorRecommendationItemFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9CAuditorRecommendationItemToJson(this);
}

@JsonSerializable()
class GSTR9CTaxPayable {
  final double taxPayableAsPerReconciliation;
  final double taxPaidAsPerAnnualReturn;
  final double differentialTaxPayable;
  final double interestPayable;

  GSTR9CTaxPayable({
    required this.taxPayableAsPerReconciliation,
    required this.taxPaidAsPerAnnualReturn,
    required this.differentialTaxPayable,
    required this.interestPayable,
  });

  factory GSTR9CTaxPayable.fromJson(Map<String, dynamic> json) => _$GSTR9CTaxPayableFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9CTaxPayableToJson(this);
}
