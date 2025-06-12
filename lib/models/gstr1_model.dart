import 'package:flutter/foundation.dart';

class GSTR1Model {
  final int? id;
  final String gstin;
  final String returnPeriod;
  final DateTime filingDate;
  final List<B2BInvoice> b2bInvoices;
  final List<B2CLInvoice> b2clInvoices;
  final List<B2CSInvoice> b2csInvoices;
  final List<HSNSummary> hsnSummary;
  final List<DocIssued> docsIssued;
  final DateTime createdAt;
  final DateTime updatedAt;

  GSTR1Model({
    this.id,
    required this.gstin,
    required this.returnPeriod,
    required this.filingDate,
    required this.b2bInvoices,
    required this.b2clInvoices,
    required this.b2csInvoices,
    required this.hsnSummary,
    required this.docsIssued,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory GSTR1Model.fromJson(Map<String, dynamic> json) {
    return GSTR1Model(
      id: json['id'],
      gstin: json['gstin'],
      returnPeriod: json['return_period'],
      filingDate: DateTime.parse(json['filing_date']),
      b2bInvoices: (json['b2b_invoices'] as List)
          .map((invoice) => B2BInvoice.fromJson(invoice))
          .toList(),
      b2clInvoices: (json['b2cl_invoices'] as List)
          .map((invoice) => B2CLInvoice.fromJson(invoice))
          .toList(),
      b2csInvoices: (json['b2cs_invoices'] as List)
          .map((invoice) => B2CSInvoice.fromJson(invoice))
          .toList(),
      hsnSummary: (json['hsn_summary'] as List)
          .map((summary) => HSNSummary.fromJson(summary))
          .toList(),
      docsIssued: (json['docs_issued'] as List)
          .map((doc) => DocIssued.fromJson(doc))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gstin': gstin,
      'return_period': returnPeriod,
      'filing_date': filingDate.toIso8601String(),
      'b2b_invoices': b2bInvoices.map((invoice) => invoice.toJson()).toList(),
      'b2cl_invoices': b2clInvoices.map((invoice) => invoice.toJson()).toList(),
      'b2cs_invoices': b2csInvoices.map((invoice) => invoice.toJson()).toList(),
      'hsn_summary': hsnSummary.map((summary) => summary.toJson()).toList(),
      'docs_issued': docsIssued.map((doc) => doc.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GSTR1Model copyWith({
    int? id,
    String? gstin,
    String? returnPeriod,
    DateTime? filingDate,
    List<B2BInvoice>? b2bInvoices,
    List<B2CLInvoice>? b2clInvoices,
    List<B2CSInvoice>? b2csInvoices,
    List<HSNSummary>? hsnSummary,
    List<DocIssued>? docsIssued,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GSTR1Model(
      id: id ?? this.id,
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      filingDate: filingDate ?? this.filingDate,
      b2bInvoices: b2bInvoices ?? this.b2bInvoices,
      b2clInvoices: b2clInvoices ?? this.b2clInvoices,
      b2csInvoices: b2csInvoices ?? this.b2csInvoices,
      hsnSummary: hsnSummary ?? this.hsnSummary,
      docsIssued: docsIssued ?? this.docsIssued,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class B2BInvoice {
  final String? id;
  final String customerGstin;
  final String customerName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final String placeOfSupply;
  final bool reverseCharge;
  final String invoiceType;
  final String eCommerceGstin;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  B2BInvoice({
    this.id,
    required this.customerGstin,
    required this.customerName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.placeOfSupply,
    required this.reverseCharge,
    required this.invoiceType,
    required this.eCommerceGstin,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory B2BInvoice.fromJson(Map<String, dynamic> json) {
    return B2BInvoice(
      id: json['id'],
      customerGstin: json['customer_gstin'],
      customerName: json['customer_name'],
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      invoiceValue: json['invoice_value'],
      placeOfSupply: json['place_of_supply'],
      reverseCharge: json['reverse_charge'],
      invoiceType: json['invoice_type'],
      eCommerceGstin: json['ecommerce_gstin'],
      taxableValue: json['taxable_value'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      cessAmount: json['cess_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_gstin': customerGstin,
      'customer_name': customerName,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'invoice_value': invoiceValue,
      'place_of_supply': placeOfSupply,
      'reverse_charge': reverseCharge,
      'invoice_type': invoiceType,
      'ecommerce_gstin': eCommerceGstin,
      'taxable_value': taxableValue,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }
}

class B2CLInvoice {
  final String? id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final String placeOfSupply;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final String eCommerceGstin;

  B2CLInvoice({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.eCommerceGstin,
  });

  factory B2CLInvoice.fromJson(Map<String, dynamic> json) {
    return B2CLInvoice(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      invoiceValue: json['invoice_value'],
      placeOfSupply: json['place_of_supply'],
      taxableValue: json['taxable_value'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      cessAmount: json['cess_amount'],
      eCommerceGstin: json['ecommerce_gstin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'invoice_value': invoiceValue,
      'place_of_supply': placeOfSupply,
      'taxable_value': taxableValue,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
      'ecommerce_gstin': eCommerceGstin,
    };
  }
}

class B2CSInvoice {
  final String? id;
  final String type;
  final String placeOfSupply;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final String eCommerceGstin;

  B2CSInvoice({
    this.id,
    required this.type,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.eCommerceGstin,
  });

  factory B2CSInvoice.fromJson(Map<String, dynamic> json) {
    return B2CSInvoice(
      id: json['id'],
      type: json['type'],
      placeOfSupply: json['place_of_supply'],
      taxableValue: json['taxable_value'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      cessAmount: json['cess_amount'],
      eCommerceGstin: json['ecommerce_gstin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'place_of_supply': placeOfSupply,
      'taxable_value': taxableValue,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
      'ecommerce_gstin': eCommerceGstin,
    };
  }
}

class HSNSummary {
  final String? id;
  final String hsnCode;
  final String description;
  final String uqc;
  final double totalQuantity;
  final double totalValue;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  HSNSummary({
    this.id,
    required this.hsnCode,
    required this.description,
    required this.uqc,
    required this.totalQuantity,
    required this.totalValue,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory HSNSummary.fromJson(Map<String, dynamic> json) {
    return HSNSummary(
      id: json['id'],
      hsnCode: json['hsn_code'],
      description: json['description'],
      uqc: json['uqc'],
      totalQuantity: json['total_quantity'],
      totalValue: json['total_value'],
      taxableValue: json['taxable_value'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      cessAmount: json['cess_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hsn_code': hsnCode,
      'description': description,
      'uqc': uqc,
      'total_quantity': totalQuantity,
      'total_value': totalValue,
      'taxable_value': taxableValue,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }
}

class DocIssued {
  final String? id;
  final String docType;
  final int docFromNumber;
  final int docToNumber;
  final int totalDocsIssued;
  final int cancelledDocuments;
  final int netDocumentsIssued;

  DocIssued({
    this.id,
    required this.docType,
    required this.docFromNumber,
    required this.docToNumber,
    required this.totalDocsIssued,
    required this.cancelledDocuments,
    required this.netDocumentsIssued,
  });

  factory DocIssued.fromJson(Map<String, dynamic> json) {
    return DocIssued(
      id: json['id'],
      docType: json['doc_type'],
      docFromNumber: json['doc_from_number'],
      docToNumber: json['doc_to_number'],
      totalDocsIssued: json['total_docs_issued'],
      cancelledDocuments: json['cancelled_documents'],
      netDocumentsIssued: json['net_documents_issued'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doc_type': docType,
      'doc_from_number': docFromNumber,
      'doc_to_number': docToNumber,
      'total_docs_issued': totalDocsIssued,
      'cancelled_documents': cancelledDocuments,
      'net_documents_issued': netDocumentsIssued,
    };
  }
}
