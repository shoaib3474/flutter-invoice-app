enum TransactionType {
  sale,
  purchase,
}

enum TransactionStatus {
  pending,
  completed,
  cancelled,
}

class PersonTransaction {
  final String id;
  final String personId;
  final TransactionType type;
  final DateTime date;
  final String invoiceNumber;
  final double amount;
  final double taxAmount;
  final TransactionStatus status;

  PersonTransaction({
    required this.id,
    required this.personId,
    required this.type,
    required this.date,
    required this.invoiceNumber,
    required this.amount,
    required this.taxAmount,
    required this.status,
  });

  factory PersonTransaction.fromMap(Map<String, dynamic> map) {
    return PersonTransaction(
      id: map['id'],
      personId: map['personId'],
      type: TransactionType.values[map['type']],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      invoiceNumber: map['invoiceNumber'],
      amount: map['amount'],
      taxAmount: map['taxAmount'],
      status: TransactionStatus.values[map['status']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'type': type.index,
      'date': date.millisecondsSinceEpoch,
      'invoiceNumber': invoiceNumber,
      'amount': amount,
      'taxAmount': taxAmount,
      'status': status.index,
    };
  }

  String getTypeDisplayName() {
    switch (type) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.purchase:
        return 'Purchase';
    }
  }

  String getStatusDisplayName() {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}
