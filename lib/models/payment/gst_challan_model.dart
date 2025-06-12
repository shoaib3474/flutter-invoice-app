class GSTChallanModel {
  final String challanId;
  final String gstin;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAmount;
  final String returnPeriod;
  final String returnType;
  final DateTime validUntil;
  final DateTime createdAt;

  GSTChallanModel({
    required this.challanId,
    required this.gstin,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAmount,
    required this.returnPeriod,
    required this.returnType,
    required this.validUntil,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'challanId': challanId,
      'gstin': gstin,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'cessAmount': cessAmount,
      'totalAmount': totalAmount,
      'returnPeriod': returnPeriod,
      'returnType': returnType,
      'validUntil': validUntil.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GSTChallanModel.fromJson(Map<String, dynamic> json) {
    return GSTChallanModel(
      challanId: json['challanId'] ?? '',
      gstin: json['gstin'] ?? '',
      cgstAmount: json['cgstAmount']?.toDouble() ?? 0.0,
      sgstAmount: json['sgstAmount']?.toDouble() ?? 0.0,
      igstAmount: json['igstAmount']?.toDouble() ?? 0.0,
      cessAmount: json['cessAmount']?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      returnPeriod: json['returnPeriod'] ?? '',
      returnType: json['returnType'] ?? '',
      validUntil: DateTime.parse(json['validUntil'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
