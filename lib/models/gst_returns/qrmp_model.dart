import 'package:json_annotation/json_annotation.dart';

part 'qrmp_model.g.dart';

/// Model for Quarterly Return Monthly Payment (QRMP) scheme
@JsonSerializable()
class QRMPScheme {
  final String gstin;
  final String financialYear;
  final String quarter;
  final List<QRMPMonthlyPayment> monthlyPayments;
  final QRMPQuarterlyReturn quarterlyReturn;
  final String status;
  final DateTime? filingDate;

  QRMPScheme({
    required this.gstin,
    required this.financialYear,
    required this.quarter,
    required this.monthlyPayments,
    required this.quarterlyReturn,
    required this.status,
    this.filingDate,
  });

  factory QRMPScheme.fromJson(Map<String, dynamic> json) => _$QRMPSchemeFromJson(json);
  Map<String, dynamic> toJson() => _$QRMPSchemeToJson(this);
}

/// Model for monthly payments under QRMP scheme
@JsonSerializable()
class QRMPMonthlyPayment {
  final String month;
  final String paymentMethod; // Fixed Sum / Self-Assessment
  final double? fixedSumAmount;
  final QRMPSelfAssessment? selfAssessment;
  final String challanNumber;
  final DateTime? paymentDate;
  final String status;

  QRMPMonthlyPayment({
    required this.month,
    required this.paymentMethod,
    this.fixedSumAmount,
    this.selfAssessment,
    required this.challanNumber,
    this.paymentDate,
    required this.status,
  });

  factory QRMPMonthlyPayment.fromJson(Map<String, dynamic> json) => _$QRMPMonthlyPaymentFromJson(json);
  Map<String, dynamic> toJson() => _$QRMPMonthlyPaymentToJson(this);
}

/// Model for self-assessment method under QRMP
@JsonSerializable()
class QRMPSelfAssessment {
  final double outwardSupplies;
  final double inwardSupplies;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final double totalTaxPayable;

  QRMPSelfAssessment({
    required this.outwardSupplies,
    required this.inwardSupplies,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    required this.totalTaxPayable,
  });

  factory QRMPSelfAssessment.fromJson(Map<String, dynamic> json) => _$QRMPSelfAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$QRMPSelfAssessmentToJson(this);
}

/// Model for quarterly return under QRMP scheme
@JsonSerializable()
class QRMPQuarterlyReturn {
  final double totalOutwardSupplies;
  final double totalInwardSupplies;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final double totalCess;
  final double totalTaxPaid;
  final double balanceTaxPayable;
  final String status;
  final DateTime? filingDate;

  QRMPQuarterlyReturn({
    required this.totalOutwardSupplies,
    required this.totalInwardSupplies,
    required this.totalIgst,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalCess,
    required this.totalTaxPaid,
    required this.balanceTaxPayable,
    required this.status,
    this.filingDate,
  });

  factory QRMPQuarterlyReturn.fromJson(Map<String, dynamic> json) => _$QRMPQuarterlyReturnFromJson(json);
  Map<String, dynamic> toJson() => _$QRMPQuarterlyReturnToJson(this);
}
