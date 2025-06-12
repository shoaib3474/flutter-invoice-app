import 'package:json_annotation/json_annotation.dart';

part 'gstr9_model.g.dart';

@JsonSerializable()
class GSTR9 {
  final String gstin;
  final String financialYear;
  final String legalName;
  final String tradeName;
  final GSTR9Part1 part1;
  final GSTR9Part2 part2;
  final GSTR9Part3 part3;
  final GSTR9Part4 part4;
  final GSTR9Part5 part5;
  final GSTR9Part6 part6;

  GSTR9({
    required this.gstin,
    required this.financialYear,
    required this.legalName,
    required this.tradeName,
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
    required this.part5,
    required this.part6,
  });

  factory GSTR9.fromJson(Map<String, dynamic> json) => _$GSTR9FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9ToJson(this);
}

@JsonSerializable()
class GSTR9Part1 {
  final double totalOutwardSupplies;
  final double zeroRatedSupplies;
  final double nilRatedSupplies;
  final double exemptedSupplies;
  final double nonGSTSupplies;

  GSTR9Part1({
    required this.totalOutwardSupplies,
    required this.zeroRatedSupplies,
    required this.nilRatedSupplies,
    required this.exemptedSupplies,
    required this.nonGSTSupplies,
  });

  factory GSTR9Part1.fromJson(Map<String, dynamic> json) => _$GSTR9Part1FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9Part1ToJson(this);
}

@JsonSerializable()
class GSTR9Part2 {
  final double inwardSuppliesAttractingReverseCharge;
  final double importsOfGoodsAndServices;
  final double inwardSuppliesLiableToReverseCharge;

  GSTR9Part2({
    required this.inwardSuppliesAttractingReverseCharge,
    required this.importsOfGoodsAndServices,
    required this.inwardSuppliesLiableToReverseCharge,
  });

  factory GSTR9Part2.fromJson(Map<String, dynamic> json) => _$GSTR9Part2FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9Part2ToJson(this);
}

@JsonSerializable()
class GSTR9Part3 {
  final double taxPayableOnOutwardSupplies;
  final double taxPayableOnReverseCharge;
  final double interestPayable;
  final double lateFeePayable;
  final double penaltyPayable;

  GSTR9Part3({
    required this.taxPayableOnOutwardSupplies,
    required this.taxPayableOnReverseCharge,
    required this.interestPayable,
    required this.lateFeePayable,
    required this.penaltyPayable,
  });

  factory GSTR9Part3.fromJson(Map<String, dynamic> json) => _$GSTR9Part3FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9Part3ToJson(this);
}

@JsonSerializable()
class GSTR9Part4 {
  final double itcAvailedOnInvoices;
  final double itcReversedAndReclaimed;
  final double itcAvailedButIneligible;

  GSTR9Part4({
    required this.itcAvailedOnInvoices,
    required this.itcReversedAndReclaimed,
    required this.itcAvailedButIneligible,
  });

  factory GSTR9Part4.fromJson(Map<String, dynamic> json) => _$GSTR9Part4FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9Part4ToJson(this);
}

@JsonSerializable()
class GSTR9Part5 {
  final double refundClaimed;
  final double refundSanctioned;
  final double refundRejected;
  final double refundPending;

  GSTR9Part5({
    required this.refundClaimed,
    required this.refundSanctioned,
    required this.refundRejected,
    required this.refundPending,
  });

  factory GSTR9Part5.fromJson(Map<String, dynamic> json) => _$GSTR9Part5FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9Part5ToJson(this);
}

@JsonSerializable()
class GSTR9Part6 {
  final double taxPayableAsPerSection73Or74;
  final double taxPaidAsPerSection73Or74;
  final double interestPayableAsPerSection73Or74;
  final double interestPaidAsPerSection73Or74;

  GSTR9Part6({
    required this.taxPayableAsPerSection73Or74,
    required this.taxPaidAsPerSection73Or74,
    required this.interestPayableAsPerSection73Or74,
    required this.interestPaidAsPerSection73Or74,
  });

  factory GSTR9Part6.fromJson(Map<String, dynamic> json) => _$GSTR9Part6FromJson(json);
  Map<String, dynamic> toJson() => _$GSTR9Part6ToJson(this);
}
