import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/firestore_model.dart';

enum GSTR3BStatus {
  notFiled,
  filed,
  error,
}

class FirestoreGSTR3B extends FirestoreModel {
  final String gstin;
  final String returnPeriod;
  final OutwardSupplies outwardSupplies;
  final InwardSupplies inwardSupplies;
  final ITCDetails itcDetails;
  final TaxPayment taxPayment;
  final GSTR3BStatus status;
  final DateTime? filingDate;
  final String? acknowledgementNumber;
  final String? errorMessage;
  
  FirestoreGSTR3B({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
    required this.gstin,
    required this.returnPeriod,
    required this.outwardSupplies,
    required this.inwardSupplies,
    required this.itcDetails,
    required this.taxPayment,
    required this.status,
    this.filingDate,
    this.acknowledgementNumber,
    this.errorMessage,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
  );
  
  factory FirestoreGSTR3B.create({
    required String gstin,
    required String returnPeriod,
    required OutwardSupplies outwardSupplies,
    required InwardSupplies inwardSupplies,
    required ITCDetails itcDetails,
    required TaxPayment taxPayment,
    String createdBy = '',
  }) {
    final now = DateTime.now();
    final id = FirebaseFirestore.instance.collection('gstr3b').doc().id;
    
    return FirestoreGSTR3B(
      id: id,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      gstin: gstin,
      returnPeriod: returnPeriod,
      outwardSupplies: outwardSupplies,
      inwardSupplies: inwardSupplies,
      itcDetails: itcDetails,
      taxPayment: taxPayment,
      status: GSTR3BStatus.notFiled,
    );
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gstin': gstin,
      'return_period': returnPeriod,
      'outward_supplies': outwardSupplies.toMap(),
      'inward_supplies': inwardSupplies.toMap(),
      'itc_details': itcDetails.toMap(),
      'tax_payment': taxPayment.toMap(),
      'status': status.index,
      'filing_date': filingDate != null ? Timestamp.fromDate(filingDate!) : null,
      'acknowledgement_number': acknowledgementNumber,
      'error_message': errorMessage,
    };
  }
  
  factory FirestoreGSTR3B.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FirestoreGSTR3B(
      id: doc.id,
      createdAt: FirestoreModel.timestampToDateTime(data['created_at']),
      updatedAt: FirestoreModel.timestampToDateTime(data['updated_at']),
      createdBy: data['created_by'] ?? '',
      gstin: data['gstin'] ?? '',
      returnPeriod: data['return_period'] ?? '',
      outwardSupplies: OutwardSupplies.fromMap(data['outward_supplies'] ?? {}),
      inwardSupplies: InwardSupplies.fromMap(data['inward_supplies'] ?? {}),
      itcDetails: ITCDetails.fromMap(data['itc_details'] ?? {}),
      taxPayment: TaxPayment.fromMap(data['tax_payment'] ?? {}),
      status: GSTR3BStatus.values[data['status'] ?? 0],
      filingDate: data['filing_date'] != null 
          ? FirestoreModel.timestampToDateTime(data['filing_date']) 
          : null,
      acknowledgementNumber: data['acknowledgement_number'],
      errorMessage: data['error_message'],
    );
  }
  
  FirestoreGSTR3B copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? gstin,
    String? returnPeriod,
    OutwardSupplies? outwardSupplies,
    InwardSupplies? inwardSupplies,
    ITCDetails? itcDetails,
    TaxPayment? taxPayment,
    GSTR3BStatus? status,
    DateTime? filingDate,
    String? acknowledgementNumber,
    String? errorMessage,
  }) {
    return FirestoreGSTR3B(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      outwardSupplies: outwardSupplies ?? this.outwardSupplies,
      inwardSupplies: inwardSupplies ?? this.inwardSupplies,
      itcDetails: itcDetails ?? this.itcDetails,
      taxPayment: taxPayment ?? this.taxPayment,
      status: status ?? this.status,
      filingDate: filingDate ?? this.filingDate,
      acknowledgementNumber: acknowledgementNumber ?? this.acknowledgementNumber,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

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
  
  OutwardSupplies({
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
  
  Map<String, dynamic> toMap() {
    return {
      'taxable_outward_supplies': taxableOutwardSupplies,
      'taxable_outward_supplies_zero_rated': taxableOutwardSuppliesZeroRated,
      'taxable_outward_supplies_nil_rated': taxableOutwardSuppliesNilRated,
      'non_gst_outward_supplies': nonGstOutwardSupplies,
      'intra_state_supplies': intraStateSupplies,
      'inter_state_supplies': interStateSupplies,
      'igst_amount': igstAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'cess_amount': cessAmount,
    };
  }
  
  factory OutwardSupplies.fromMap(Map<String, dynamic> map) {
    return OutwardSupplies(
      taxableOutwardSupplies: map['taxable_outward_supplies']?.toDouble() ?? 0.0,
      taxableOutwardSuppliesZeroRated: map['taxable_outward_supplies_zero_rated']?.toDouble() ?? 0.0,
      taxableOutwardSuppliesNilRated: map['taxable_outward_supplies_nil_rated']?.toDouble() ?? 0.0,
      nonGstOutwardSupplies: map['non_gst_outward_supplies']?.toDouble() ?? 0.0,
      intraStateSupplies: map['intra_state_supplies']?.toDouble() ?? 0.0,
      interStateSupplies: map['inter_state_supplies']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
    );
  }
}

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
  
  InwardSupplies({
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
  
  Map<String, dynamic> toMap() {
    return {
      'reverse_charge_supplies': reverseChargeSupplies,
      'import_of_goods': importOfGoods,
      'import_of_services': importOfServices,
      'ineligible_itc': ineligibleITC,
      'eligible_itc': eligibleITC,
      'igst_amount': igstAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'cess_amount': cessAmount,
    };
  }
  
  factory InwardSupplies.fromMap(Map<String, dynamic> map) {
    return InwardSupplies(
      reverseChargeSupplies: map['reverse_charge_supplies']?.toDouble() ?? 0.0,
      importOfGoods: map['import_of_goods']?.toDouble() ?? 0.0,
      importOfServices: map['import_of_services']?.toDouble() ?? 0.0,
      ineligibleITC: map['ineligible_itc']?.toDouble() ?? 0.0,
      eligibleITC: map['eligible_itc']?.toDouble() ?? 0.0,
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
    );
  }
}

class ITCDetails {
  final double itcAvailed;
  final double itcReversed;
  final double itcNet;
  final double ineligibleITC;
  
  ITCDetails({
    required this.itcAvailed,
    required this.itcReversed,
    required this.itcNet,
    required this.ineligibleITC,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'itc_availed': itcAvailed,
      'itc_reversed': itcReversed,
      'itc_net': itcNet,
      'ineligible_itc': ineligibleITC,
    };
  }
  
  factory ITCDetails.fromMap(Map<String, dynamic> map) {
    return ITCDetails(
      itcAvailed: map['itc_availed']?.toDouble() ?? 0.0,
      itcReversed: map['itc_reversed']?.toDouble() ?? 0.0,
      itcNet: map['itc_net']?.toDouble() ?? 0.0,
      ineligibleITC: map['ineligible_itc']?.toDouble() ?? 0.0,
    );
  }
}

class TaxPayment {
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final double interestAmount;
  final double lateFeesAmount;
  final double penaltyAmount;
  final double totalAmount;
  
  TaxPayment({
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    required this.interestAmount,
    required this.lateFeesAmount,
    required this.penaltyAmount,
    required this.totalAmount,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'igst_amount': igstAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'cess_amount': cessAmount,
      'interest_amount': interestAmount,
      'late_fees_amount': lateFeesAmount,
      'penalty_amount': penaltyAmount,
      'total_amount': totalAmount,
    };
  }
  
  factory TaxPayment.fromMap(Map<String, dynamic> map) {
    return TaxPayment(
      igstAmount: map['igst_amount']?.toDouble() ?? 0.0,
      cgstAmount: map['cgst_amount']?.toDouble() ?? 0.0,
      sgstAmount: map['sgst_amount']?.toDouble() ?? 0.0,
      cessAmount: map['cess_amount']?.toDouble() ?? 0.0,
      interestAmount: map['interest_amount']?.toDouble() ?? 0.0,
      lateFeesAmount: map['late_fees_amount']?.toDouble() ?? 0.0,
      penaltyAmount: map['penalty_amount']?.toDouble() ?? 0.0,
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
    );
  }
}
