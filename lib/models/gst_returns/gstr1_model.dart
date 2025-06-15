import 'package:json_annotation/json_annotation.dart';

part 'gstr1_model.g.dart';

@JsonSerializable()
class GSTR1 {
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
  final String status;
  final DateTime filingDate;

  GSTR1({
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
    required this.filingDate,
  });

  factory GSTR1.fromJson(Map<String, dynamic> json) => _$GSTR1FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR1ToJson(this);
}

@JsonSerializable()
class GSTR1Summary {
  final String gstin;
  final String returnPeriod;
  final int totalInvoices;
  final double totalTaxableValue;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final int b2bInvoiceCount;
  final int b2clInvoiceCount;
  final int b2csInvoiceCount;
  final int exportInvoiceCount;
  final String status;
  final DateTime filingDate;

  GSTR1Summary({
    required this.gstin,
    required this.returnPeriod,
    required this.totalInvoices,
    required this.totalTaxableValue,
    required this.totalIgst,
    required this.totalCgst,
    required this.totalSgst,
    required this.b2bInvoiceCount,
    required this.b2clInvoiceCount,
    required this.b2csInvoiceCount,
    required this.exportInvoiceCount,
    required this.status,
    required this.filingDate,
  });

  factory GSTR1Summary.fromJson(Map<String, dynamic> json) =>
      _$GSTR1SummaryFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR1SummaryToJson(this);
}

@JsonSerializable()
class GSTR1Model {
  final String gstin;
  final String financialYear;
  final String taxPeriod;
  final int b2bInvoiceCount;
  final double b2bInvoiceValue;
  final int b2cInvoiceCount;
  final double b2cInvoiceValue;
  final int hsnSummaryCount;
  final double hsnTotalValue;

  GSTR1Model({
    required this.gstin,
    required this.financialYear,
    required this.taxPeriod,
    required this.b2bInvoiceCount,
    required this.b2bInvoiceValue,
    required this.b2cInvoiceCount,
    required this.b2cInvoiceValue,
    required this.hsnSummaryCount,
    required this.hsnTotalValue,
  });

  get fp => null;

  static Future<GSTR1Model?> fromJson(data) async {}

  // factory GSTR1Model.fromJson(Map<String, dynamic> json) => _$GSTR1ModelFromJson(json);
  // Map<String, dynamic> toJson() => _$GSTR1ModelToJson(this);
}

@JsonSerializable()
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
  });

  factory B2BInvoice.fromJson(Map<String, dynamic> json) =>
      _$B2BInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$B2BInvoiceToJson(this);
}

@JsonSerializable()
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
  });

  factory B2CLInvoice.fromJson(Map<String, dynamic> json) =>
      _$B2CLInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$B2CLInvoiceToJson(this);
}

@JsonSerializable()
class B2CSInvoice {
  final String id;
  final String type;
  final String placeOfSupply;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;

  B2CSInvoice({
    required this.id,
    required this.type,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
  });

  factory B2CSInvoice.fromJson(Map<String, dynamic> json) =>
      _$B2CSInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$B2CSInvoiceToJson(this);
}

@JsonSerializable()
class ExportInvoice {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double taxableValue;
  final double igstAmount;
  final String shippingBillNumber;
  final DateTime shippingBillDate;
  final String portCode;
  final String exportType;

  ExportInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.taxableValue,
    required this.igstAmount,
    required this.shippingBillNumber,
    required this.shippingBillDate,
    required this.portCode,
    required this.exportType,
  });

  factory ExportInvoice.fromJson(Map<String, dynamic> json) =>
      _$ExportInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$ExportInvoiceToJson(this);
}
