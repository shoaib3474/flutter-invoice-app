// ignore_for_file: avoid_redundant_argument_values, avoid_unused_constructor_parameters

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode = 200,
    this.errors,
  });

  factory ApiResponse.success({
    required T data,
    String message = 'Success',
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    int statusCode = 500,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      data: null,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 500,
      errors: json['errors'],
    );
  }
  final bool success;
  final T? data;
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'statusCode': statusCode,
      'errors': errors,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}

// Specialized response types
class GSTReturnResponse extends ApiResponse<Map<String, dynamic>> {
  GSTReturnResponse({
    required super.success,
    required super.message,
    required super.statusCode,
    super.data,
    super.errors,
  });

  factory GSTReturnResponse.success({
    required Map<String, dynamic> data,
    String message = 'GST return processed successfully',
    int statusCode = 200,
  }) {
    return GSTReturnResponse(
      success: true,
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }

  factory GSTReturnResponse.error({
    required String message,
    required int statusCode,
    String? error,
  }) {
    return GSTReturnResponse(
      success: false,
      statusCode: statusCode,
      message: message,
      errors: error != null ? {'error': error} : null,
    );
  }
}

class ComparisonResult<T> {
  ComparisonResult({
    required this.items,
    required this.summary,
    required this.comparisonType,
    required this.generatedAt,
  });

  factory ComparisonResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ComparisonResult<T>(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => ComparisonItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: ComparisonSummary.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {}),
      comparisonType: json['comparison_type'] ?? 'unknown',
      generatedAt: DateTime.parse(
          json['generated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  final List<ComparisonItem> items;
  final ComparisonSummary summary;
  final String comparisonType;
  final DateTime generatedAt;

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'summary': summary.toJson(),
      'comparison_type': comparisonType,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

class ComparisonItem {
  ComparisonItem({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.counterpartyGstin,
    required this.counterpartyName,
    required this.taxableValueInSource1,
    required this.taxableValueInSource2,
    required this.igstInSource1,
    required this.igstInSource2,
    required this.cgstInSource1,
    required this.cgstInSource2,
    required this.sgstInSource1,
    required this.sgstInSource2,
    required this.matchStatus,
    required this.remarks,
    this.taxableValueInSource3,
    this.igstInSource3,
    this.cgstInSource3,
    this.sgstInSource3,
  });

  factory ComparisonItem.fromJson(Map<String, dynamic> json) {
    return ComparisonItem(
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceDate: json['invoice_date'] ?? '',
      counterpartyGstin: json['counterparty_gstin'] ?? '',
      counterpartyName: json['counterparty_name'] ?? '',
      taxableValueInSource1:
          (json['taxable_value_in_source1'] ?? 0.0).toDouble(),
      taxableValueInSource2:
          (json['taxable_value_in_source2'] ?? 0.0).toDouble(),
      taxableValueInSource3: json['taxable_value_in_source3']?.toDouble(),
      igstInSource1: (json['igst_in_source1'] ?? 0.0).toDouble(),
      igstInSource2: (json['igst_in_source2'] ?? 0.0).toDouble(),
      igstInSource3: json['igst_in_source3']?.toDouble(),
      cgstInSource1: (json['cgst_in_source1'] ?? 0.0).toDouble(),
      cgstInSource2: (json['cgst_in_source2'] ?? 0.0).toDouble(),
      cgstInSource3: json['cgst_in_source3']?.toDouble(),
      sgstInSource1: (json['sgst_in_source1'] ?? 0.0).toDouble(),
      sgstInSource2: (json['sgst_in_source2'] ?? 0.0).toDouble(),
      sgstInSource3: json['sgst_in_source3']?.toDouble(),
      matchStatus: json['match_status'] ?? 'unknown',
      remarks: json['remarks'] ?? '',
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'counterparty_gstin': counterpartyGstin,
      'counterparty_name': counterpartyName,
      'taxable_value_in_source1': taxableValueInSource1,
      'taxable_value_in_source2': taxableValueInSource2,
      'taxable_value_in_source3': taxableValueInSource3,
      'igst_in_source1': igstInSource1,
      'igst_in_source2': igstInSource2,
      'igst_in_source3': igstInSource3,
      'cgst_in_source1': cgstInSource1,
      'cgst_in_source2': cgstInSource2,
      'cgst_in_source3': cgstInSource3,
      'sgst_in_source1': sgstInSource1,
      'sgst_in_source2': sgstInSource2,
      'sgst_in_source3': sgstInSource3,
      'match_status': matchStatus,
      'remarks': remarks,
    };
  }
}

class ComparisonSummary {
  ComparisonSummary({
    required this.totalInvoices,
    required this.matchedInvoices,
    required this.partiallyMatchedInvoices,
    required this.unmatchedInvoices,
    required this.onlyInSource1Invoices,
    required this.onlyInSource2Invoices,
    required this.totalTaxableValueInSource1,
    required this.totalTaxableValueInSource2,
    required this.totalTaxInSource1,
    required this.totalTaxInSource2,
    required this.taxDifference,
    this.onlyInSource3Invoices,
    this.totalTaxableValueInSource3,
    this.totalTaxInSource3,
  });

  factory ComparisonSummary.fromJson(Map<String, dynamic> json) {
    return ComparisonSummary(
      totalInvoices: json['total_invoices'] ?? 0,
      matchedInvoices: json['matched_invoices'] ?? 0,
      partiallyMatchedInvoices: json['partially_matched_invoices'] ?? 0,
      unmatchedInvoices: json['unmatched_invoices'] ?? 0,
      onlyInSource1Invoices: json['only_in_source1_invoices'] ?? 0,
      onlyInSource2Invoices: json['only_in_source2_invoices'] ?? 0,
      onlyInSource3Invoices: json['only_in_source3_invoices'],
      totalTaxableValueInSource1:
          (json['total_taxable_value_in_source1'] ?? 0.0).toDouble(),
      totalTaxableValueInSource2:
          (json['total_taxable_value_in_source2'] ?? 0.0).toDouble(),
      totalTaxableValueInSource3:
          json['total_taxable_value_in_source3']?.toDouble(),
      totalTaxInSource1: (json['total_tax_in_source1'] ?? 0.0).toDouble(),
      totalTaxInSource2: (json['total_tax_in_source2'] ?? 0.0).toDouble(),
      totalTaxInSource3: json['total_tax_in_source3']?.toDouble(),
      taxDifference: (json['tax_difference'] ?? 0.0).toDouble(),
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'total_invoices': totalInvoices,
      'matched_invoices': matchedInvoices,
      'partially_matched_invoices': partiallyMatchedInvoices,
      'unmatched_invoices': unmatchedInvoices,
      'only_in_source1_invoices': onlyInSource1Invoices,
      'only_in_source2_invoices': onlyInSource2Invoices,
      'only_in_source3_invoices': onlyInSource3Invoices,
      'total_taxable_value_in_source1': totalTaxableValueInSource1,
      'total_taxable_value_in_source2': totalTaxableValueInSource2,
      'total_taxable_value_in_source3': totalTaxableValueInSource3,
      'total_tax_in_source1': totalTaxInSource1,
      'total_tax_in_source2': totalTaxInSource2,
      'total_tax_in_source3': totalTaxInSource3,
      'tax_difference': taxDifference,
    };
  }
}
