// ignore_for_file: always_put_required_named_parameters_first

class GSTR4Model {
  GSTR4Model({
    required this.gstin,
    required this.returnPeriod,
    required this.filingDate,
    this.taxPeriod,
    this.financialYear,
    this.outwardSupplies,
    this.inwardSupplies,
    this.taxPayment,
    this.b2bInvoices = const [],
    this.b2burInvoices = const [],
    this.importedGoods = const [],
    this.taxesPaid = const [],
  });

  factory GSTR4Model.fromJson(Map<String, dynamic> json) {
    return GSTR4Model(
      gstin: json['gstin'],
      returnPeriod: json['return_period'],
      filingDate: DateTime.parse(json['filing_date']),
      taxPeriod: json['tax_period'],
      financialYear: json['financial_year'],
      outwardSupplies: json['outward_supplies'] != null
          ? GSTR4OutwardSupplies.fromJson(json['outward_supplies'])
          : null,
      inwardSupplies: json['inward_supplies'] != null
          ? GSTR4InwardSupplies.fromJson(json['inward_supplies'])
          : null,
      taxPayment: json['tax_payment'] != null
          ? GSTR4TaxPayment.fromJson(json['tax_payment'])
          : null,
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
    );
  }
  late final String gstin;
  final String returnPeriod;
  late final String? taxPeriod;
  late final String? financialYear;
  final DateTime filingDate;

  // Outward supplies
  late final GSTR4OutwardSupplies? outwardSupplies;

  // Inward supplies
  late final GSTR4InwardSupplies? inwardSupplies;

  // Tax payment
  late final GSTR4TaxPayment? taxPayment;

  // Other fields from your constructor
  final List<B2BInvoice> b2bInvoices;
  final List<B2BURInvoice> b2burInvoices;
  final List<ImportedGoods> importedGoods;
  final List<TaxPaid> taxesPaid;

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'return_period': returnPeriod,
      'filing_date': filingDate.toIso8601String(),
      'tax_period': taxPeriod,
      'financial_year': financialYear,
      'outward_supplies': outwardSupplies?.toJson(),
      'inward_supplies': inwardSupplies?.toJson(),
      'tax_payment': taxPayment?.toJson(),
      'b2b_invoices': b2bInvoices.map((invoice) => invoice.toJson()).toList(),
      'b2bur_invoices':
          b2burInvoices.map((invoice) => invoice.toJson()).toList(),
      'imported_goods': importedGoods.map((goods) => goods.toJson()).toList(),
      'taxes_paid': taxesPaid.map((tax) => tax.toJson()).toList(),
    };
  }

  GSTR4Model copyWith({
    String? gstin,
    String? returnPeriod,
    String? taxPeriod,
    String? financialYear,
    DateTime? filingDate,
    GSTR4OutwardSupplies? outwardSupplies,
    GSTR4InwardSupplies? inwardSupplies,
    GSTR4TaxPayment? taxPayment,
    List<B2BInvoice>? b2bInvoices,
    List<B2BURInvoice>? b2burInvoices,
    List<ImportedGoods>? importedGoods,
    List<TaxPaid>? taxesPaid,
  }) {
    return GSTR4Model(
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      taxPeriod: taxPeriod ?? this.taxPeriod,
      financialYear: financialYear ?? this.financialYear,
      filingDate: filingDate ?? this.filingDate,
      outwardSupplies: outwardSupplies ?? this.outwardSupplies,
      inwardSupplies: inwardSupplies ?? this.inwardSupplies,
      taxPayment: taxPayment ?? this.taxPayment,
      b2bInvoices: b2bInvoices ?? this.b2bInvoices,
      b2burInvoices: b2burInvoices ?? this.b2burInvoices,
      importedGoods: importedGoods ?? this.importedGoods,
      taxesPaid: taxesPaid ?? this.taxesPaid,
    );
  }

  static GSTR4Model empty() => GSTR4Model(
        gstin: '',
        returnPeriod: '',
        filingDate: DateTime.now(),
        taxPeriod: '',
        financialYear: '',
        outwardSupplies: GSTR4OutwardSupplies(),
        inwardSupplies: GSTR4InwardSupplies(),
        taxPayment: GSTR4TaxPayment(),
        b2bInvoices: const [],
        b2burInvoices: const [],
        importedGoods: const [],
        taxesPaid: const [],
      );
}

// Outward Supplies Model
class GSTR4OutwardSupplies {
  GSTR4OutwardSupplies({
    this.b2bSupplies = 0,
    this.b2cSupplies = 0,
  });

  factory GSTR4OutwardSupplies.fromJson(Map<String, dynamic> json) {
    return GSTR4OutwardSupplies(
      b2bSupplies: json['b2b_supplies']?.toDouble() ?? 0,
      b2cSupplies: json['b2c_supplies']?.toDouble() ?? 0,
    );
  }

  double? b2bSupplies;
  double? b2cSupplies;

  Map<String, dynamic> toJson() {
    return {
      'b2b_supplies': b2bSupplies,
      'b2c_supplies': b2cSupplies,
    };
  }
}

// Inward Supplies Model
class GSTR4InwardSupplies {
  GSTR4InwardSupplies({
    this.reverseChargeSupplies = 0,
    this.imports = 0,
  });

  factory GSTR4InwardSupplies.fromJson(Map<String, dynamic> json) {
    return GSTR4InwardSupplies(
      reverseChargeSupplies: json['reverse_charge_supplies']?.toDouble() ?? 0,
      imports: json['imports']?.toDouble() ?? 0,
    );
  }

  double? reverseChargeSupplies;
  double? imports;

  Map<String, dynamic> toJson() {
    return {
      'reverse_charge_supplies': reverseChargeSupplies,
      'imports': imports,
    };
  }
}

// Tax Payment Model
class GSTR4TaxPayment {
  GSTR4TaxPayment({
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.cess = 0,
  });

  factory GSTR4TaxPayment.fromJson(Map<String, dynamic> json) {
    return GSTR4TaxPayment(
      cgst: json['cgst']?.toDouble() ?? 0,
      sgst: json['sgst']?.toDouble() ?? 0,
      igst: json['igst']?.toDouble() ?? 0,
      cess: json['cess']?.toDouble() ?? 0,
    );
  }

  double? cgst;
  double? sgst;
  double? igst;
  double? cess;

  Map<String, dynamic> toJson() {
    return {
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'cess': cess,
    };
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
