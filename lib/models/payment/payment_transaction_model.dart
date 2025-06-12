class PaymentTransactionModel {
  final String transactionId;
  final String challanId;
  final double amount;
  final String paymentMethod;
  final String paymentId;
  final String status;
  final DateTime timestamp;

  PaymentTransactionModel({
    required this.transactionId,
    required this.challanId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'challanId': challanId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      transactionId: json['transactionId'] ?? '',
      challanId: json['challanId'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      paymentId: json['paymentId'] ?? '',
      status: json['status'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
