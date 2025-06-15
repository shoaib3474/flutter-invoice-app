import 'package:json_annotation/json_annotation.dart';

part 'gstr4_model.g.dart';

@JsonSerializable()
class GSTR4Model {
  final String gstin;
  final String returnPeriod;
  final String financialYear;
  final List<B2BInvoice> b2bInvoices;
  final List<B2BURInvoice> b2burInvoices;
  final List<ImportedGoods> importedGoods;
  final List<TaxPaid> taxPaid;

  const GSTR4Model({
    required this.gstin,
    required this.returnPeriod,
    required this.financialYear,
    required this.b2bInvoices,
    required this.b2burInvoices,
    required this.importedGoods,
    required this.taxPaid,
  });

  factory GSTR4Model.fromJson(Map<String, dynamic> json) =>
      _$GSTR4ModelFromJson(json);

  Map<String, dynamic> toJson() => _$GSTR4ModelToJson(this);

  factory GSTR4Model.empty() {
    return const GSTR4Model(
      gstin: '',
      returnPeriod: '',
      financialYear: '',
      b2bInvoices: [],
      b2burInvoices: [],
      importedGoods: [],
      taxPaid: [],
    );
  }

  GSTR4Model copyWith({
    String? gstin,
    String? returnPeriod,
    String? financialYear,
    List<B2BInvoice>? b2bInvoices,
    List<B2BURInvoice>? b2burInvoices,
    List<ImportedGoods>? importedGoods,
    List<TaxPaid>? taxPaid,
  }) {
    return GSTR4Model(
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      financialYear: financialYear ?? this.financialYear,
      b2bInvoices: b2bInvoices ?? this.b2bInvoices,
      b2burInvoices: b2burInvoices ?? this.b2burInvoices,
      importedGoods: importedGoods ?? this.importedGoods,
      taxPaid: taxPaid ?? this.taxPaid,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GSTR4Model &&
        other.gstin == gstin &&
        other.returnPeriod == returnPeriod &&
        other.financialYear == financialYear;
  }

  @override
  int get hashCode {
    return gstin.hashCode ^ returnPeriod.hashCode ^ financialYear.hashCode;
  }

  get ret_period => null;
}

@JsonSerializable()
class B2BInvoice {
  final String ctin;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final String placeOfSupply;
  final bool reverseCharge;
  final String invoiceType;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;

  const B2BInvoice({
    required this.ctin,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.placeOfSupply,
    required this.reverseCharge,
    required this.invoiceType,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
  });

  factory B2BInvoice.fromJson(Map<String, dynamic> json) =>
      _$B2BInvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$B2BInvoiceToJson(this);

  factory B2BInvoice.empty() {
    return B2BInvoice(
      ctin: '',
      invoiceNumber: '',
      invoiceDate: DateTime.now(),
      invoiceValue: 0.0,
      placeOfSupply: '',
      reverseCharge: false,
      invoiceType: 'Regular',
      taxableValue: 0.0,
      igstAmount: 0.0,
      cgstAmount: 0.0,
      sgstAmount: 0.0,
    );
  }

  B2BInvoice copyWith({
    String? ctin,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? invoiceValue,
    String? placeOfSupply,
    bool? reverseCharge,
    String? invoiceType,
    double? taxableValue,
    double? igstAmount,
    double? cgstAmount,
    double? sgstAmount,
  }) {
    return B2BInvoice(
      ctin: ctin ?? this.ctin,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceValue: invoiceValue ?? this.invoiceValue,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      invoiceType: invoiceType ?? this.invoiceType,
      taxableValue: taxableValue ?? this.taxableValue,
      igstAmount: igstAmount ?? this.igstAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
    );
  }
}

@JsonSerializable()
class B2BURInvoice {
  final String supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final String placeOfSupply;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;

  const B2BURInvoice({
    required this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
  });

  factory B2BURInvoice.fromJson(Map<String, dynamic> json) =>
      _$B2BURInvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$B2BURInvoiceToJson(this);

  factory B2BURInvoice.empty() {
    return B2BURInvoice(
      supplierName: '',
      invoiceNumber: '',
      invoiceDate: DateTime.now(),
      invoiceValue: 0.0,
      placeOfSupply: '',
      taxableValue: 0.0,
      igstAmount: 0.0,
      cgstAmount: 0.0,
      sgstAmount: 0.0,
    );
  }
}

@JsonSerializable()
class ImportedGoods {
  final String portCode;
  final String billOfEntry;
  final DateTime billDate;
  final double billValue;
  final String documentType;
  final double taxableValue;
  final double igstAmount;

  const ImportedGoods({
    required this.portCode,
    required this.billOfEntry,
    required this.billDate,
    required this.billValue,
    required this.documentType,
    required this.taxableValue,
    required this.igstAmount,
  });

  factory ImportedGoods.fromJson(Map<String, dynamic> json) =>
      _$ImportedGoodsFromJson(json);

  Map<String, dynamic> toJson() => _$ImportedGoodsToJson(this);

  factory ImportedGoods.empty() {
    return ImportedGoods(
      portCode: '',
      billOfEntry: '',
      billDate: DateTime.now(),
      billValue: 0.0,
      documentType: '',
      taxableValue: 0.0,
      igstAmount: 0.0,
    );
  }
}

@JsonSerializable()
class TaxPaid {
  final String description;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;

  const TaxPaid({
    required this.description,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
  });

  factory TaxPaid.fromJson(Map<String, dynamic> json) =>
      _$TaxPaidFromJson(json);

  Map<String, dynamic> toJson() => _$TaxPaidToJson(this);

  factory TaxPaid.empty() {
    return const TaxPaid(
      description: '',
      taxableValue: 0.0,
      igstAmount: 0.0,
      cgstAmount: 0.0,
      sgstAmount: 0.0,
      cessAmount: 0.0,
    );
  }
}
