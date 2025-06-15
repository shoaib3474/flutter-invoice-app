// ignore_for_file: always_put_required_named_parameters_first, prefer_int_literals, avoid_redundant_argument_values, prefer_constructors_over_static_methods
class GSTR3BModel {
  GSTR3BModel({
    this.id,
    required this.gstin,
    required this.returnPeriod,
    required this.filingDate,
    required this.outwardSupplies,
    required this.inwardSupplies,
    required this.taxPayments,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.status,
    this.taxPayableIGST = 0.0,
    this.taxPayableSGST = 0.0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  GSTR3BModel.withDetails(
    this.id,
    this.gstin,
    this.returnPeriod,
    this.filingDate,
    this.outwardSupplies,
    this.inwardSupplies,
    this.taxPayments,
    this.createdAt,
    this.updatedAt, {
    required this.financialYear,
    required this.taxPeriod,
    this.outwardSuppliesTotal = 0.0,
    this.outwardSuppliesZeroRated = 0.0,
    this.outwardSuppliesNilRated = 0.0,
    this.inwardSuppliesReverseCharge = 0.0,
    this.inwardSuppliesImport = 0.0,
    this.itcAvailed = 0.0,
    this.itcReversed = 0.0,
    this.taxPayableCGST = 0.0,
    this.taxPayableCess = 0.0,
    required this.status,
    this.taxPayableIGST = 0.0,
    this.taxPayableSGST = 0.0,
  });

  factory GSTR3BModel.fromJson(Map<String, dynamic> json) {
    return GSTR3BModel(
      id: json['id'],
      gstin: json['gstin'],
      returnPeriod: json['return_period'],
      filingDate: DateTime.parse(json['filing_date']),
      outwardSupplies: OutwardSupplies.fromJson(json['outward_supplies']),
      inwardSupplies: InwardSupplies.fromJson(json['inward_supplies']),
      taxPayments: (json['tax_payments'] as List)
          .map((payment) => TaxPayment.fromJson(payment))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: json['status'],
      taxPayableIGST: json['tax_payable_igst']?.toDouble() ?? 0.0,
      taxPayableSGST: json['tax_payable_sgst']?.toDouble() ?? 0.0,
    );
  }
  final int? id;
  late final String gstin;
  final String returnPeriod;
  final DateTime filingDate;
  final OutwardSupplies outwardSupplies;
  final InwardSupplies inwardSupplies;
  final List<TaxPayment> taxPayments;
  final DateTime createdAt;
  final DateTime updatedAt;

  late String financialYear;
  late String taxPeriod;
  late double outwardSuppliesTotal;
  late double outwardSuppliesZeroRated;
  late double outwardSuppliesNilRated;
  late double inwardSuppliesReverseCharge;
  late double inwardSuppliesImport;
  late double itcAvailed;
  late double itcReversed;
  late double taxPayableCGST;
  late double taxPayableCess;
  late String status;
  late double taxPayableIGST;
  late double taxPayableSGST;

  get ret_period => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gstin': gstin,
      'return_period': returnPeriod,
      'filing_date': filingDate.toIso8601String(),
      'outward_supplies': outwardSupplies.toJson(),
      'inward_supplies': inwardSupplies.toJson(),
      'tax_payments': taxPayments.map((payment) => payment.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'tax_payable_igst': taxPayableIGST,
      'tax_payable_sgst': taxPayableSGST,
    };
  }

  GSTR3BModel copyWith({
    int? id,
    String? gstin,
    String? returnPeriod,
    DateTime? filingDate,
    OutwardSupplies? outwardSupplies,
    InwardSupplies? inwardSupplies,
    List<TaxPayment>? taxPayments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    double? taxPayableIGST,
    double? taxPayableSGST,
  }) {
    return GSTR3BModel(
      id: id ?? this.id,
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      filingDate: filingDate ?? this.filingDate,
      outwardSupplies: outwardSupplies ?? this.outwardSupplies,
      inwardSupplies: inwardSupplies ?? this.inwardSupplies,
      taxPayments: taxPayments ?? this.taxPayments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      taxPayableIGST: taxPayableIGST ?? this.taxPayableIGST,
      taxPayableSGST: taxPayableSGST ?? this.taxPayableSGST,
    );
  }

  GSTR3BModel copy() {
    return GSTR3BModel(
      id: id,
      gstin: gstin,
      returnPeriod: returnPeriod,
      filingDate: filingDate,
      outwardSupplies: outwardSupplies,
      inwardSupplies: inwardSupplies,
      taxPayments: taxPayments
          .map((payment) => payment.copy())
          .toList()
          .cast<TaxPayment>(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      taxPayableIGST: taxPayableIGST,
      taxPayableSGST: taxPayableSGST,
    );
  }

  static GSTR3BModel empty() {
    return GSTR3BModel(
      id: null,
      gstin: '',
      returnPeriod: '',
      filingDate: DateTime.now(),
      outwardSupplies: OutwardSupplies.empty(),
      inwardSupplies: InwardSupplies.empty(),
      taxPayments: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: '',
      taxPayableIGST: 0.0,
      taxPayableSGST: 0.0,
    );
  }
}

class OutwardSupplies {
  OutwardSupplies({
    required this.taxableOutwardSupplies,
    required this.taxableOutwardSuppliesZeroRated,
    required this.taxableOutwardSuppliesNil,
    required this.nonGstOutwardSupplies,
    required this.intraStateSupplies,
    required this.interStateSupplies,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory OutwardSupplies.fromJson(Map<String, dynamic> json) {
    return OutwardSupplies(
      taxableOutwardSupplies: json['taxable_outward_supplies'],
      taxableOutwardSuppliesZeroRated:
          json['taxable_outward_supplies_zero_rated'],
      taxableOutwardSuppliesNil: json['taxable_outward_supplies_nil'],
      nonGstOutwardSupplies: json['non_gst_outward_supplies'],
      intraStateSupplies: json['intra_state_supplies'],
      interStateSupplies: json['inter_state_supplies'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      cessAmount: json['cess_amount'],
    );
  }
  final double taxableOutwardSupplies;
  final double taxableOutwardSuppliesZeroRated;
  final double taxableOutwardSuppliesNil;
  final double nonGstOutwardSupplies;
  final double intraStateSupplies;
  final double interStateSupplies;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  Map<String, dynamic> toJson() {
    return {
      'taxable_outward_supplies': taxableOutwardSupplies,
      'taxable_outward_supplies_zero_rated': taxableOutwardSuppliesZeroRated,
      'taxable_outward_supplies_nil': taxableOutwardSuppliesNil,
      'non_gst_outward_supplies': nonGstOutwardSupplies,
      'intra_state_supplies': intraStateSupplies,
      'inter_state_supplies': interStateSupplies,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }

  static OutwardSupplies empty() {
    return OutwardSupplies(
      taxableOutwardSupplies: 0.0,
      taxableOutwardSuppliesZeroRated: 0.0,
      taxableOutwardSuppliesNil: 0.0,
      nonGstOutwardSupplies: 0.0,
      intraStateSupplies: 0.0,
      interStateSupplies: 0.0,
      cgstAmount: 0.0,
      sgstAmount: 0.0,
      igstAmount: 0.0,
      cessAmount: 0.0,
    );
  }
}

class InwardSupplies {
  InwardSupplies({
    required this.reverseChargeSupplies,
    required this.importOfGoods,
    required this.importOfServices,
    required this.ineligibleITC,
    required this.eligibleITC,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory InwardSupplies.fromJson(Map<String, dynamic> json) {
    return InwardSupplies(
      reverseChargeSupplies: json['reverse_charge_supplies'],
      importOfGoods: json['import_of_goods'],
      importOfServices: json['import_of_services'],
      ineligibleITC: json['ineligible_itc'],
      eligibleITC: json['eligible_itc'],
      cgstAmount: json['cgst_amount'],
      sgstAmount: json['sgst_amount'],
      igstAmount: json['igst_amount'],
      cessAmount: json['cess_amount'],
    );
  }
  final double reverseChargeSupplies;
  final double importOfGoods;
  final double importOfServices;
  final double ineligibleITC;
  final double eligibleITC;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  Map<String, dynamic> toJson() {
    return {
      'reverse_charge_supplies': reverseChargeSupplies,
      'import_of_goods': importOfGoods,
      'import_of_services': importOfServices,
      'ineligible_itc': ineligibleITC,
      'eligible_itc': eligibleITC,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }

  static InwardSupplies empty() {
    return InwardSupplies(
      reverseChargeSupplies: 0.0,
      importOfGoods: 0.0,
      importOfServices: 0.0,
      ineligibleITC: 0.0,
      eligibleITC: 0.0,
      cgstAmount: 0.0,
      sgstAmount: 0.0,
      igstAmount: 0.0,
      cessAmount: 0.0,
    );
  }
}

class TaxPayment {
  TaxPayment({
    this.id,
    required this.taxType,
    required this.taxAmount,
    required this.paymentMode,
    required this.paymentDate,
    required this.referenceNumber,
  });

  factory TaxPayment.fromJson(Map<String, dynamic> json) {
    return TaxPayment(
      id: json['id'],
      taxType: json['tax_type'],
      taxAmount: json['tax_amount'],
      paymentMode: json['payment_mode'],
      paymentDate: DateTime.parse(json['payment_date']),
      referenceNumber: json['reference_number'],
    );
  }
  final String? id;
  final String taxType;
  final double taxAmount;
  final String paymentMode;
  final DateTime paymentDate;
  final String referenceNumber;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tax_type': taxType,
      'tax_amount': taxAmount,
      'payment_mode': paymentMode,
      'payment_date': paymentDate.toIso8601String(),
      'reference_number': referenceNumber,
    };
  }

  void copy() {}

  static void empty() {}
}
