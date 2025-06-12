import 'package:json_annotation/json_annotation.dart';

part 'gstr2a_model.g.dart';

@JsonSerializable()
class GSTR2A {
  final String gstin;
  final String returnPeriod;
  final List<B2BInvoice> b2bInvoices;
  final List<CDNRInvoice> cdnrInvoices;
  final List<IMPSInvoice> impsInvoices;
  final List<IMPGInvoice> impgInvoices;
  final double totalTaxableValue;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final String status;
  final DateTime? lastUpdated;

  GSTR2A({
    required this.gstin,
    required this.returnPeriod,
    required this.b2bInvoices,
    required this.cdnrInvoices,
    required this.impsInvoices,
    required this.impgInvoices,
    required this.totalTaxableValue,
    required this.totalIgst,
    required this.totalCgst,
    required this.totalSgst,
    required this.status,
    this.lastUpdated,
  });

  factory GSTR2A.fromJson(Map<String, dynamic> json) => _$GSTR2AFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR2AToJson(this);
}

@JsonSerializable()
class GSTR2ASummary {
  final String gstin;
  final String returnPeriod;
  final int totalInvoices;
  final double totalTaxableValue;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final int b2bInvoiceCount;
  final int cdnrInvoiceCount;
  final int impsInvoiceCount;
  final int impgInvoiceCount;
  final String status;
  final DateTime? lastUpdated;

  GSTR2ASummary({
    required this.gstin,
    required this.returnPeriod,
    required this.totalInvoices,
    required this.totalTaxableValue,
    required this.totalIgst,
    required this.totalCgst,
    required this.totalSgst,
    required this.b2bInvoiceCount,
    required this.cdnrInvoiceCount,
    required this.impsInvoiceCount,
    required this.impgInvoiceCount,
    required this.status,
    this.lastUpdated,
  });

  factory GSTR2ASummary.fromJson(Map<String, dynamic> json) => _$GSTR2ASummaryFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR2ASummaryToJson(this);
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

  factory B2BInvoice.fromJson(Map<String, dynamic> json) => _$B2BInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$B2BInvoiceToJson(this);
}

@JsonSerializable()
class CDNRInvoice {
  final String id;
  final String noteNumber;
  final DateTime noteDate;
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
  final String noteType; // Credit or Debit
  final String reasonForIssuing;

  CDNRInvoice({
    required this.id,
    required this.noteNumber,
    required this.noteDate,
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
    required this.noteType,
    required this.reasonForIssuing,
  });

  factory CDNRInvoice.fromJson(Map<String, dynamic> json) => _$CDNRInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$CDNRInvoiceToJson(this);
}

@JsonSerializable()
class IMPSInvoice {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double taxableValue;
  final double igstAmount;
  final double cessAmount;
  final String portCode;

  IMPSInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.taxableValue,
    required this.igstAmount,
    required this.cessAmount,
    required this.portCode,
  });

  factory IMPSInvoice.fromJson(Map<String, dynamic> json) => _$IMPSInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$IMPSInvoiceToJson(this);
}

@JsonSerializable()
class IMPGInvoice {
  final String id;
  final String portCode;
  final String billOfEntryNumber;
  final DateTime billOfEntryDate;
  final double taxableValue;
  final double igstAmount;
  final double cessAmount;

  IMPGInvoice({
    required this.id,
    required this.portCode,
    required this.billOfEntryNumber,
    required this.billOfEntryDate,
    required this.taxableValue,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory IMPGInvoice.fromJson(Map<String, dynamic> json) => _$IMPGInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$IMPGInvoiceToJson(this);
}
