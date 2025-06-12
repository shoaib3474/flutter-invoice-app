import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/firestore_model.dart';

enum GSTR1Status {
  notFiled,
  filed,
  error,
}

class FirestoreGSTR1 extends FirestoreModel {
  final String gstin;
  final String returnPeriod;
  final List<B2BInvoice> b2bInvoices;
  final List<B2CLInvoice> b2clInvoices;
  final List<B2CSInvoice> b2csInvoices;
  final List<ExportInvoice> exportInvoices;
  final double totalTaxableValue;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final GSTR1Status status;
  final DateTime? filingDate;
  final String? acknowledgementNumber;
  final String? errorMessage;
  final bool isAmendment;
  final String? originalReturnPeriod;
  
  FirestoreGSTR1({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
    required this.gstin,
    required this.returnPeriod,
    required this.b2bInvoices,
    required this.b2clInvoices,
    required this.b2csInvoices,
    required this.exportInvoices,
    required this.totalTaxableValue,
    required this.totalIgst,
    required this.totalCgst,
    required this.totalSgst,
    required this.status,
    this.filingDate,
    this.acknowledgementNumber,
    this.errorMessage,
    this.isAmendment = false,
    this.originalReturnPeriod,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
  );
  
  factory FirestoreGSTR1.create({
    required String gstin,
    required String returnPeriod,
    required List<B2BInvoice> b2bInvoices,
    required List<B2CLInvoice> b2clInvoices,
    required List<B2CSInvoice> b2csInvoices,
    required List<ExportInvoice> exportInvoices,
    bool isAmendment = false,
    String? originalReturnPeriod,
    String createdBy = '',
  }) {
    // Calculate totals
    double totalTaxableValue = 0;
    double totalIgst = 0;
    double totalCgst = 0;
    double totalSgst = 0;
    
    for (var invoice in b2bInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
      totalCgst += invoice.cgstAmount;
      totalSgst += invoice.sgstAmount;
    }
    
    for (var invoice in b2clInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
      totalCgst += invoice.cgstAmount;
      totalSgst += invoice.sgstAmount;
    }
    
    for (var invoice in b2csInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
      totalCgst += invoice.cgstAmount;
      totalSgst += invoice.sgstAmount;
    }
    
    for (var invoice in exportInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
    }
    
    final now = DateTime.now();
    final id = FirebaseFirestore.instance.collection('gstr1').doc().id;
    
    return FirestoreGSTR1(
      id: id,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      gstin: gstin,
      returnPeriod: returnPeriod,
      b2bInvoices: b2bInvoices,
      b2clInvoices: b2clInvoices,
      b2csInvoices: b2csInvoices,
      exportInvoices: exportInvoices,
      totalTaxableValue: totalTaxableValue,
      totalIgst: totalIgst,
      totalCgst: totalCgst,
      totalSgst: totalSgst,
      status: GSTR1Status.notFiled,
      isAmendment: isAmendment,
      originalReturnPeriod: originalReturnPeriod,
    );
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gstin': gstin,
      'return_period': returnPeriod,
      'b2b_invoices': b2bInvoices.map((invoice) => invoice.toMap()).toList(),
      'b2cl_invoices': b2clInvoices.map((invoice) => invoice.toMap()).toList(),
      'b2cs_invoices': b2csInvoices.map((invoice) => invoice.toMap()).toList(),
      'export_invoices': exportInvoices.map((invoice) => invoice.toMap()).toList(),
      'total_taxable_value': totalTaxableValue,
      'total_igst': totalIgst,
      'total_cgst': totalCgst,
      'total_sgst': totalSgst,
      'status': status.index,
      'filing_date': filingDate != null ? Timestamp.fromDate(filingDate!) : null,
      'acknowledgement_number': acknowledgementNumber,
      'error_message': errorMessage,
      'is_amendment': isAmendment,
      'original_return_period': originalReturnPeriod,
    };
  }
  
  factory FirestoreGSTR1.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FirestoreGSTR1(
      id: doc.id,
      createdAt: FirestoreModel.timestampToDateTime(data['created_at']),
      updatedAt: FirestoreModel.timestampToDateTime(data['updated_at']),
      createdBy: data['created_by'] ?? '',
      gstin: data['gstin'] ?? '',
      returnPeriod: data['return_period'] ?? '',
      b2bInvoices: (data['b2b_invoices'] as List<dynamic>?)
          ?.map((invoice) => B2BInvoice.fromMap(invoice))
          .toList() ?? [],
      b2clInvoices: (data['b2cl_invoices'] as List<dynamic>?)
          ?.map((invoice) => B2CLInvoice.fromMap(invoice))
          .toList() ?? [],
      b2csInvoices: (data['b2cs_invoices'] as List<dynamic>?)
          ?.map((invoice) => B2CSInvoice.fromMap(invoice))
          .toList() ?? [],
      exportInvoices: (data['export_invoices'] as List<dynamic>?)
          ?.map((invoice) => ExportInvoice.fromMap(invoice))
          .toList() ?? [],
      totalTaxableValue: data['total_taxable_value']?.toDouble() ?? 0.0,
      totalIgst: data['total_igst']?.toDouble() ?? 0.0,
      totalCgst: data['total_cgst']?.toDouble() ?? 0.0,
      totalSgst: data['total_sgst']?.toDouble() ?? 0.0,
      status: GSTR1Status.values[data['status'] ?? 0],
      filingDate: data['filing_date'] != null 
          ? FirestoreModel.timestampToDateTime(data['filing_date']) 
          : null,
      acknowledgementNumber: data['acknowledgement_number'],
      errorMessage: data['error_message'],
      isAmendment: data['is_amendment'] ?? false,
      originalReturnPeriod: data['original_return_period'],
    );
  }
  
  FirestoreGSTR1 copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? gstin,
    String? returnPeriod,
    List<B2BInvoice>? b2bInvoices,
    List<B2CLInvoice>? b2clInvoices,
    List<B2CSInvoice>? b2csInvoices,
    List<ExportInvoice>? exportInvoices,
    double? totalTaxableValue,
    double? totalIgst,
    double? totalCgst,
    double? totalSgst,
    GSTR1Status? status,
    DateTime? filingDate,
    String? acknowledgementNumber,
    String? errorMessage,
    bool? isAmendment,
    String? originalReturnPeriod,
  }) {
    return FirestoreGSTR1(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      b2bInvoices: b2bInvoices ?? this.b2bInvoices,
      b2clInvoices: b2clInvoices ?? this.b2clInvoices,
      b2csInvoices: b2csInvoices ?? this.b2csInvoices,
      exportInvoices: exportInvoices ?? this.exportInvoices,
      totalTaxableValue: totalTaxableValue ?? this.totalTaxableValue,
      totalIgst: totalIgst ?? this.totalIgst,
      totalCgst: totalCgst ?? this.totalCgst,
      totalSgst: totalSgst ?? this.totalSgst,
      status: status ?? this.status,
      filingDate: filingDate ?? this.filingDate,
      acknowledgementNumber: acknowledgementNumber ?? this.acknowledgementNumber,
      errorMessage: errorMessage ?? this.errorMessage,
      isAmendment: isAmendment ?? this.isAmendment,
      originalReturnPeriod: originalReturnPeriod ?? this.originalReturnPeriod,
    );
  }
}

class B2BInvoice {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String counterpartyGstin;
  final String counterpartyName;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final String placeOfSupply;
  final bool reverseCharge;
  final String invoiceType;
  final String? eCommerceGstin;
  final String? originalInvoiceNumber;
  final DateTime? originalInvoiceDate;
  
  B2BInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.counterpartyGstin,
    required this.counterpartyName,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    required this.placeOfSupply,
    required this.reverseCharge,
    required this.invoiceType,
    this.eCommerceGstin,
    this.originalInvoiceNumber,
    this.originalInvoiceDate,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': Timestamp.fromDate(invoiceDate),
      'counterparty_gstin': counterpartyGstin,
      'counterparty_name': counterpartyName,
      'taxable_value': taxableValue,
      'igst_amount': igstAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'cess_amount': cessAmount,
      'place_of_supply': placeOfSupply,
      'reverse_charge': reverseCharge,
      'invoice_type': invoiceType,
      'e_commerce_gstin': eCommerceGstin,
      'original_invoice_number': originalInvoiceNumber,
      'original_invoice_date': originalInvoiceDate != null 
          ? Timestamp.fromDate(originalInvoiceDate!) 
          : null,
    };
  }
  
  factory B2BInvoice.fromMap(Map<String, dynamic> map) {
    return B2BInvoice(
      id: map['id'] ?? '',
      invoiceNumber: map['invoice_number'] ?? '',
      invoiceDate: map['invoice_date'] is Timestamp 
          ? (map['invoice_date'] as Timestamp).toDate() 
          : DateTime.parse(map['invoice_date'] ?? DateTime.now().toIso8601String()),
      counterpartyGstin: map['counterparty_gstin'] ?? '',
      counterpartyName: map['counterparty_name'] ?? '',
      taxableValue: map['taxable_value']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
      placeOfSupply: map['place_of_supply'] ?? '',
      reverseCharge: map['reverse_charge'] ?? false,
      invoiceType: map['invoice_type'] ?? 'Regular',
      eCommerceGstin: map['e_commerce_gstin'],
      originalInvoiceNumber: map['original_invoice_number'],
      originalInvoiceDate: map['original_invoice_date'] is Timestamp 
          ? (map['original_invoice_date'] as Timestamp).toDate() 
          : map['original_invoice_date'] != null 
              ? DateTime.parse(map['original_invoice_date']) 
              : null,
    );
  }
}

class B2CLInvoice {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final String placeOfSupply;
  final String? eCommerceGstin;
  final String? originalInvoiceNumber;
  final DateTime? originalInvoiceDate;
  
  B2CLInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    required this.placeOfSupply,
    this.eCommerceGstin,
    this.originalInvoiceNumber,
    this.originalInvoiceDate,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': Timestamp.fromDate(invoiceDate),
      'taxable_value': taxableValue,
      'igst_amount': igstAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'cess_amount': cessAmount,
      'place_of_supply': placeOfSupply,
      'e_commerce_gstin': eCommerceGstin,
      'original_invoice_number': originalInvoiceNumber,
      'original_invoice_date': originalInvoiceDate != null 
          ? Timestamp.fromDate(originalInvoiceDate!) 
          : null,
    };
  }
  
  factory B2CLInvoice.fromMap(Map<String, dynamic> map) {
    return B2CLInvoice(
      id: map['id'] ?? '',
      invoiceNumber: map['invoice_number'] ?? '',
      invoiceDate: map['invoice_date'] is Timestamp 
          ? (map['invoice_date'] as Timestamp).toDate() 
          : DateTime.parse(map['invoice_date'] ?? DateTime.now().toIso8601String()),
      taxableValue: map['taxable_value']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
      placeOfSupply: map['place_of_supply'] ?? '',
      eCommerceGstin: map['e_commerce_gstin'],
      originalInvoiceNumber: map['original_invoice_number'],
      originalInvoiceDate: map['original_invoice_date'] is Timestamp 
          ? (map['original_invoice_date'] as Timestamp).toDate() 
          : map['original_invoice_date'] != null 
              ? DateTime.parse(map['original_invoice_date']) 
              : null,
    );
  }
}

class B2CSInvoice {
  final String id;
  final String type;
  final String placeOfSupply;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final String? eCommerceGstin;
  
  B2CSInvoice({
    required this.id,
    required this.type,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    this.eCommerceGstin,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'place_of_supply': placeOfSupply,
      'taxable_value': taxableValue,
      'igst_amount': igstAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'cess_amount': cessAmount,
      'e_commerce_gstin': eCommerceGstin,
    };
  }
  
  factory B2CSInvoice.fromMap(Map<String, dynamic> map) {
    return B2CSInvoice(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      placeOfSupply: map['place_of_supply'] ?? '',
      taxableValue: map['taxable_value']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
      eCommerceGstin: map['e_commerce_gstin'],
    );
  }
}

class ExportInvoice {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double taxableValue;
  final double igstAmount;
  final String? shippingBillNumber;
  final DateTime? shippingBillDate;
  final String? portCode;
  final String exportType;
  final String? originalInvoiceNumber;
  final DateTime? originalInvoiceDate;
  
  ExportInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.taxableValue,
    required this.igstAmount,
    this.shippingBillNumber,
    this.shippingBillDate,
    this.portCode,
    required this.exportType,
    this.originalInvoiceNumber,
    this.originalInvoiceDate,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': Timestamp.fromDate(invoiceDate),
      'taxable_value': taxableValue,
      'igst_amount': igstAmount,
      'shipping_bill_number': shippingBillNumber,
      'shipping_bill_date': shippingBillDate != null 
          ? Timestamp.fromDate(shippingBillDate!) 
          : null,
      'port_code': portCode,
      'export_type': exportType,
      'original_invoice_number': originalInvoiceNumber,
      'original_invoice_date': originalInvoiceDate != null 
          ? Timestamp.fromDate(originalInvoiceDate!) 
          : null,
    };
  }
  
  factory ExportInvoice.fromMap(Map<String, dynamic> map) {
    return ExportInvoice(
      id: map['id'] ?? '',
      invoiceNumber: map['invoice_number'] ?? '',
      invoiceDate: map['invoice_date'] is Timestamp 
          ? (map['invoice_date'] as Timestamp).toDate() 
          : DateTime.parse(map['invoice_date'] ?? DateTime.now().toIso8601String()),
      taxableValue: map['taxable_value']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      shippingBillNumber: map['shipping_bill_number'],
      shippingBillDate: map['shipping_bill_date'] is Timestamp 
          ? (map['shipping_bill_date'] as Timestamp).toDate() 
          : map['shipping_bill_date'] != null 
              ? DateTime.parse(map['shipping_bill_date']) 
              : null,
      portCode: map['port_code'],
      exportType: map['export_type'] ?? 'With Payment',
      originalInvoiceNumber: map['original_invoice_number'],
      originalInvoiceDate: map['original_invoice_date'] is Timestamp 
          ? (map['original_invoice_date'] as Timestamp).toDate() 
          : map['original_invoice_date'] != null 
              ? DateTime.parse(map['original_invoice_date']) 
              : null,
    );
  }
}
