// ignore_for_file: always_put_required_named_parameters_first

class GSTR4Model {
  GSTR4Model({
    this.id,
    required this.gstin,
    required this.returnPeriod,
    required this.filingDate,
    required this.b2bInvoices,
    required this.b2burInvoices,
    required this.importedGoods,
    required this.taxesPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory GSTR4Model.fromJson(Map<String, dynamic> json) {
    return GSTR4Model(
      id: json['id'],
      gstin: json['gstin'],
      returnPeriod: json['return_period'],
      filingDate: DateTime.parse(json['filing_date']),
      b2bInvoices: (json['b2b_invoices'] as List)
          .map((invoice) => B2BInvoice.fromJson(invoice))
          .toList(),
      b2burInvoices: (json['b2bur_invoices'] as List)
          .map((invoice) => B2BURInvoice.fromJson(invoice))
          .toList(),
      importedGoods: (json['imported_goods'] as List)
          .map((goods) => ImportedGoods.fromJson(goods))
          .toList(),
      taxesPaid: (json['taxes_paid'] as List)
          .map((tax) => TaxPaid.fromJson(tax))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  final int? id;
  final String gstin;
  final String returnPeriod;
  final DateTime filingDate;
  final List<B2BInvoice> b2bInvoices;
  final List<B2BURInvoice> b2burInvoices;
  final List<ImportedGoods> importedGoods;
  final List<TaxPaid> taxesPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gstin': gstin,
      'return_period': returnPeriod,
      'filing_date': filingDate.toIso8601String(),
      'b2b_invoices': b2bInvoices.map((invoice) => invoice.toJson()).toList(),
      'b2bur_invoices':
          b2burInvoices.map((invoice) => invoice.toJson()).toList(),
      'imported_goods': importedGoods.map((goods) => goods.toJson()).toList(),
      'taxes_paid': taxesPaid.map((tax) => tax.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GSTR4Model copyWith({
    int? id,
    String? gstin,
    String? returnPeriod,
    DateTime? filingDate,
    List<B2BInvoice>? b2bInvoices,
    List<B2BURInvoice>? b2burInvoices,
    List<ImportedGoods>? importedGoods,
    List<TaxPaid>? taxesPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GSTR4Model(
      id: id ?? this.id,
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      filingDate: filingDate ?? this.filingDate,
      b2bInvoices: b2bInvoices ?? this.b2bInvoices,
      b2burInvoices: b2burInvoices ?? this.b2burInvoices,
      importedGoods: importedGoods ?? this.importedGoods,
      taxesPaid: taxesPaid ?? this.taxesPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class B2BInvoice {
  B2BInvoice({
    this.id,
    required this.supplierGstin,
    required this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory B2BInvoice.fromJson(Map<String, dynamic> json) {
    return B2BInvoice(
      id: json['id'],
      supplierGstin: json['supplier_gstin'],
      supplierName: json['supplier_name'],
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      invoiceValue: json['invoice_value'].toDouble(),
      placeOfSupply: json['place_of_supply'],
      taxableValue: json['taxable_value'].toDouble(),
      cgstAmount: json['cgst_amount'].toDouble(),
      sgstAmount: json['sgst_amount'].toDouble(),
      igstAmount: json['igst_amount'].toDouble(),
      cessAmount: json['cess_amount'].toDouble(),
    );
  }
  final String? id;
  final String supplierGstin;
  final String supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final String placeOfSupply;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_gstin': supplierGstin,
      'supplier_name': supplierName,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'invoice_value': invoiceValue,
      'place_of_supply': placeOfSupply,
      'taxable_value': taxableValue,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }
}

class B2BURInvoice {
  B2BURInvoice({
    this.id,
    required this.supplierGstin,
    required this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory B2BURInvoice.fromJson(Map<String, dynamic> json) {
    return B2BURInvoice(
      id: json['id'],
      supplierGstin: json['supplier_gstin'],
      supplierName: json['supplier_name'],
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      invoiceValue: json['invoice_value'].toDouble(),
      placeOfSupply: json['place_of_supply'],
      taxableValue: json['taxable_value'].toDouble(),
      cgstAmount: json['cgst_amount'].toDouble(),
      sgstAmount: json['sgst_amount'].toDouble(),
      igstAmount: json['igst_amount'].toDouble(),
      cessAmount: json['cess_amount'].toDouble(),
    );
  }
  final String? id;
  final String supplierGstin;
  final String supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final String placeOfSupply;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_gstin': supplierGstin,
      'supplier_name': supplierName,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'invoice_value': invoiceValue,
      'place_of_supply': placeOfSupply,
      'taxable_value': taxableValue,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }
}

class ImportedGoods {
  ImportedGoods({
    this.id,
    required this.portCode,
    required this.billOfEntryNumber,
    required this.billOfEntryDate,
    required this.billOfEntryValue,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.taxableValue,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory ImportedGoods.fromJson(Map<String, dynamic> json) {
    return ImportedGoods(
      id: json['id'],
      portCode: json['port_code'],
      billOfEntryNumber: json['bill_of_entry_number'],
      billOfEntryDate: DateTime.parse(json['bill_of_entry_date']),
      billOfEntryValue: json['bill_of_entry_value'].toDouble(),
      description: json['description'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      taxableValue: json['taxable_value'].toDouble(),
      igstAmount: json['igst_amount'].toDouble(),
      cessAmount: json['cess_amount'].toDouble(),
    );
  }
  final String? id;
  final String portCode;
  final String billOfEntryNumber;
  final DateTime billOfEntryDate;
  final double billOfEntryValue;
  final String description;
  final double quantity;
  final String unit;
  final double taxableValue;
  final double igstAmount;
  final double cessAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'port_code': portCode,
      'bill_of_entry_number': billOfEntryNumber,
      'bill_of_entry_date': billOfEntryDate.toIso8601String(),
      'bill_of_entry_value': billOfEntryValue,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'taxable_value': taxableValue,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }
}

class TaxPaid {
  TaxPaid({
    this.id,
    required this.description,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.interestAmount,
    required this.penaltyAmount,
    required this.feeAmount,
    required this.otherAmount,
  });

  factory TaxPaid.fromJson(Map<String, dynamic> json) {
    return TaxPaid(
      id: json['id'],
      description: json['description'],
      cgstAmount: json['cgst_amount'].toDouble(),
      sgstAmount: json['sgst_amount'].toDouble(),
      igstAmount: json['igst_amount'].toDouble(),
      cessAmount: json['cess_amount'].toDouble(),
      interestAmount: json['interest_amount'].toDouble(),
      penaltyAmount: json['penalty_amount'].toDouble(),
      feeAmount: json['fee_amount'].toDouble(),
      otherAmount: json['other_amount'].toDouble(),
    );
  }
  final String? id;
  final String description;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double interestAmount;
  final double penaltyAmount;
  final double feeAmount;
  final double otherAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
      'interest_amount': interestAmount,
      'penalty_amount': penaltyAmount,
      'fee_amount': feeAmount,
      'other_amount': otherAmount,
    };
  }
}
