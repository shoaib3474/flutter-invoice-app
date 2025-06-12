import 'package:json_annotation/json_annotation.dart';

part 'reconciliation_result_model.g.dart';

@JsonSerializable()
class ReconciliationResult {
  final String comparisonType;
  final DateTime generatedAt;
  final List<ComparisonItem> items;
  final ComparisonSummary summary;

  const ReconciliationResult({
    required this.comparisonType,
    required this.generatedAt,
    required this.items,
    required this.summary,
  });

  factory ReconciliationResult.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationResultFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReconciliationResultToJson(this);
}

@JsonSerializable()
class ComparisonResult {
  final String comparisonType;
  final DateTime generatedAt;
  final List<ComparisonItem> items;
  final ComparisonSummary summary;

  const ComparisonResult({
    required this.comparisonType,
    required this.generatedAt,
    required this.items,
    required this.summary,
  });

  factory ComparisonResult.fromJson(Map<String, dynamic> json) =>
      _$ComparisonResultFromJson(json);
  
  Map<String, dynamic> toJson() => _$ComparisonResultToJson(this);
}

@JsonSerializable()
class ComparisonItem {
  final String invoiceNumber;
  final String invoiceDate;
  final String counterpartyGstin;
  final String counterpartyName;
  final double taxableValueInSource1;
  final double taxableValueInSource2;
  final double? taxableValueInSource3;
  final double igstInSource1;
  final double igstInSource2;
  final double? igstInSource3;
  final double cgstInSource1;
  final double cgstInSource2;
  final double? cgstInSource3;
  final double sgstInSource1;
  final double sgstInSource2;
  final double? sgstInSource3;
  final String matchStatus;
  final String remarks;

  const ComparisonItem({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.counterpartyGstin,
    required this.counterpartyName,
    required this.taxableValueInSource1,
    required this.taxableValueInSource2,
    this.taxableValueInSource3,
    required this.igstInSource1,
    required this.igstInSource2,
    this.igstInSource3,
    required this.cgstInSource1,
    required this.cgstInSource2,
    this.cgstInSource3,
    required this.sgstInSource1,
    required this.sgstInSource2,
    this.sgstInSource3,
    required this.matchStatus,
    required this.remarks,
  });

  factory ComparisonItem.fromJson(Map<String, dynamic> json) =>
      _$ComparisonItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$ComparisonItemToJson(this);
}

@JsonSerializable()
class ComparisonSummary {
  final int totalInvoices;
  final int matchedInvoices;
  final int partiallyMatchedInvoices;
  final int unmatchedInvoices;
  final int onlyInSource1Invoices;
  final int onlyInSource2Invoices;
  final int? onlyInSource3Invoices;
  final double totalTaxableValueInSource1;
  final double totalTaxableValueInSource2;
  final double? totalTaxableValueInSource3;
  final double totalTaxInSource1;
  final double totalTaxInSource2;
  final double? totalTaxInSource3;
  final double taxDifference;

  const ComparisonSummary({
    required this.totalInvoices,
    required this.matchedInvoices,
    required this.partiallyMatchedInvoices,
    required this.unmatchedInvoices,
    required this.onlyInSource1Invoices,
    required this.onlyInSource2Invoices,
    this.onlyInSource3Invoices,
    required this.totalTaxableValueInSource1,
    required this.totalTaxableValueInSource2,
    this.totalTaxableValueInSource3,
    required this.totalTaxInSource1,
    required this.totalTaxInSource2,
    this.totalTaxInSource3,
    required this.taxDifference,
  });

  factory ComparisonSummary.fromJson(Map<String, dynamic> json) =>
      _$ComparisonSummaryFromJson(json);
  
  Map<String, dynamic> toJson() => _$ComparisonSummaryToJson(this);
}
