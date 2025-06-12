import 'package:json_annotation/json_annotation.dart';

part 'gstr3b_model.g.dart';

@JsonSerializable()
class GSTR3B {
  final String gstin;
  final String returnPeriod;
  final OutwardSupplies outwardSupplies;
  final InwardSupplies inwardSupplies;
  final ITCDetails itcDetails;
  final TaxPayment taxPayment;
  final String status;
  final DateTime filingDate;

  const GSTR3B({
    required this.gstin,
    required this.returnPeriod,
    required this.outwardSupplies,
    required this.inwardSupplies,
    required this.itcDetails,
    required this.taxPayment,
    required this.status,
    required this.filingDate,
  });

  factory GSTR3B.fromJson(Map<String, dynamic> json) => _$GSTR3BFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR3BToJson(this);
}

@JsonSerializable()
class GSTR3BSummary {
  final String gstin;
  final String returnPeriod;
  final double totalOutwardSupplies;
  final double totalInwardSupplies;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final double totalCess;
  final double totalTaxPayable;
  final double totalItcAvailed;
  final String status;
  final DateTime filingDate;

  const GSTR3BSummary({
    required this.gstin,
    required this.returnPeriod,
    required this.totalOutwardSupplies,
    required this.totalInwardSupplies,
    required this.totalIgst,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalCess,
    required this.totalTaxPayable,
    required this.totalItcAvailed,
    required this.status,
    required this.filingDate,
  });

  factory GSTR3BSummary.fromJson(Map<String, dynamic> json) => _$GSTR3BSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$GSTR3BSummaryToJson(this);
}

@JsonSerializable()
class OutwardSupplies {
  final double taxableOutwardSupplies;
  final double taxableOutwardSuppliesZeroRated;
  final double taxableOutwardSuppliesNilRated;
  final double nonGstOutwardSupplies;
  final double intraStateSupplies;
  final double interStateSupplies;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;

  const OutwardSupplies({
    required this.taxableOutwardSupplies,
    required this.taxableOutwardSuppliesZeroRated,
    required this.taxableOutwardSuppliesNilRated,
    required this.nonGstOutwardSupplies,
    required this.intraStateSupplies,
    required this.interStateSupplies,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
  });

  factory OutwardSupplies.fromJson(Map<String, dynamic> json) => _$OutwardSuppliesFromJson(json);
  Map<String, dynamic> toJson() => _$OutwardSuppliesToJson(this);
}

@JsonSerializable()
class InwardSupplies {
  final double reverseChargeSupplies;
  final double importOfGoods;
  final double importOfServices;
  final double ineligibleITC;
  final double eligibleITC;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;

  const InwardSupplies({
    required this.reverseChargeSupplies,
    required this.importOfGoods,
    required this.importOfServices,
    required this.ineligibleITC,
    required this.eligibleITC,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
  });

  factory InwardSupplies.fromJson(Map<String, dynamic> json) => _$InwardSuppliesFromJson(json);
  Map<String, dynamic> toJson() => _$InwardSuppliesToJson(this);
}

@JsonSerializable()
class ITCDetails {
  final double itcAvailed;
  final double itcReversed;
  final double itcNet;
  final double ineligibleITC;

  const ITCDetails({
    required this.itcAvailed,
    required this.itcReversed,
    required this.itcNet,
    required this.ineligibleITC,
  });

  factory ITCDetails.fromJson(Map<String, dynamic> json) => _$ITCDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$ITCDetailsToJson(this);
}

@JsonSerializable()
class TaxPayment {
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final double interestAmount;
  final double lateFeesAmount;
  final double penaltyAmount;
  final double totalAmount;

  const TaxPayment({
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    required this.interestAmount,
    required this.lateFeesAmount,
    required this.penaltyAmount,
    required this.totalAmount,
  });

  factory TaxPayment.fromJson(Map<String, dynamic> json) => _$TaxPaymentFromJson(json);
  Map<String, dynamic> toJson() => _$TaxPaymentToJson(this);
}
