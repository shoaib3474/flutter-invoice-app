import 'dart:convert';

enum MatchStatus { matched, unmatched, partialMatch, discrepancy }

class GSTComparisonModel {
  final String id;
  final String description;
  final String period;
  final double amount;
  final String status;

  const GSTComparisonModel({
    required this.id,
    required this.description,
    required this.period,
    required this.amount,
    required this.status,
  });
}

class GSTComparisonItem {
  final String? invoiceNumber;
  final String? counterpartyGstin;
  final MatchStatus matchStatus;
  final double? taxableValueInSource1;
  final double? taxableValueInSource2;
  final double? igstInSource1;
  final double? igstInSource2;
  final double? cgstInSource1;
  final double? cgstInSource2;
  final double? sgstInSource1;
  final double? sgstInSource2;
  final String? remarks;

  const GSTComparisonItem({
    this.invoiceNumber,
    this.counterpartyGstin,
    required this.matchStatus,
    this.taxableValueInSource1,
    this.taxableValueInSource2,
    this.igstInSource1,
    this.igstInSource2,
    this.cgstInSource1,
    this.cgstInSource2,
    this.sgstInSource1,
    this.sgstInSource2,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoice_number': invoiceNumber,
      'counterparty_gstin': counterpartyGstin,
      'match_status': matchStatus.toString(),
      'taxable_value_source1': taxableValueInSource1,
      'taxable_value_source2': taxableValueInSource2,
      'igst_source1': igstInSource1,
      'igst_source2': igstInSource2,
      'cgst_source1': cgstInSource1,
      'cgst_source2': cgstInSource2,
      'sgst_source1': sgstInSource1,
      'sgst_source2': sgstInSource2,
      'remarks': remarks,
    };
  }

  factory GSTComparisonItem.fromMap(Map<String, dynamic> map) {
    return GSTComparisonItem(
      invoiceNumber: map['invoice_number'],
      counterpartyGstin: map['counterparty_gstin'],
      matchStatus: MatchStatus.values.firstWhere(
        (e) => e.toString() == map['match_status'],
        orElse: () => MatchStatus.unmatched,
      ),
      taxableValueInSource1: map['taxable_value_source1']?.toDouble(),
      taxableValueInSource2: map['taxable_value_source2']?.toDouble(),
      igstInSource1: map['igst_source1']?.toDouble(),
      igstInSource2: map['igst_source2']?.toDouble(),
      cgstInSource1: map['cgst_source1']?.toDouble(),
      cgstInSource2: map['cgst_source2']?.toDouble(),
      sgstInSource1: map['sgst_source1']?.toDouble(),
      sgstInSource2: map['sgst_source2']?.toDouble(),
      remarks: map['remarks'],
    );
  }
}

class GSTComparisonSummary {
  final int totalRecords;
  final int matchedRecords;
  final int unmatchedRecords;
  final int discrepancyRecords;
  final double totalTaxableValueInSource1;
  final double totalTaxableValueInSource2;
  final double totalTaxInSource1;
  final double totalTaxInSource2;
  final double taxDifference;

  const GSTComparisonSummary({
    required this.totalRecords,
    required this.matchedRecords,
    required this.unmatchedRecords,
    required this.discrepancyRecords,
    required this.totalTaxableValueInSource1,
    required this.totalTaxableValueInSource2,
    required this.totalTaxInSource1,
    required this.totalTaxInSource2,
    required this.taxDifference,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_records': totalRecords,
      'matched_records': matchedRecords,
      'unmatched_records': unmatchedRecords,
      'discrepancy_records': discrepancyRecords,
      'total_taxable_value_source1': totalTaxableValueInSource1,
      'total_taxable_value_source2': totalTaxableValueInSource2,
      'total_tax_source1': totalTaxInSource1,
      'total_tax_source2': totalTaxInSource2,
      'tax_difference': taxDifference,
    };
  }

  factory GSTComparisonSummary.fromMap(Map<String, dynamic> map) {
    return GSTComparisonSummary(
      totalRecords: map['total_records']?.toInt() ?? 0,
      matchedRecords: map['matched_records']?.toInt() ?? 0,
      unmatchedRecords: map['unmatched_records']?.toInt() ?? 0,
      discrepancyRecords: map['discrepancy_records']?.toInt() ?? 0,
      totalTaxableValueInSource1: map['total_taxable_value_source1']?.toDouble() ?? 0.0,
      totalTaxableValueInSource2: map['total_taxable_value_source2']?.toDouble() ?? 0.0,
      totalTaxInSource1: map['total_tax_source1']?.toDouble() ?? 0.0,
      totalTaxInSource2: map['total_tax_source2']?.toDouble() ?? 0.0,
      taxDifference: map['tax_difference']?.toDouble() ?? 0.0,
    );
  }
}
