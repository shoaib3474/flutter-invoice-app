enum GstReturnType {
  gstr1,
  gstr2a,
  gstr2b,
  gstr3b,
  gstr4,
  gstr9,
  gstr9c,
}

enum GstReturnStatus {
  notDue,
  pending,
  filed,
  error,
}

class GstReturnSummary {
  final String id;
  final GstReturnType type;
  final String period;
  final DateTime dueDate;
  final GstReturnStatus status;
  final DateTime? filedDate;
  final String? acknowledgementNumber;
  final double? totalTaxAmount;
  final String? gstin;

  GstReturnSummary({
    required this.id,
    required this.type,
    required this.period,
    required this.dueDate,
    required this.status,
    this.filedDate,
    this.acknowledgementNumber,
    this.totalTaxAmount,
    this.gstin,
  });

  factory GstReturnSummary.fromMap(Map<String, dynamic> map) {
    return GstReturnSummary(
      id: map['id'],
      type: GstReturnType.values[map['type']],
      period: map['period'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      status: GstReturnStatus.values[map['status']],
      filedDate: map['filedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['filedDate'])
          : null,
      acknowledgementNumber: map['acknowledgementNumber'],
      totalTaxAmount: map['totalTaxAmount'],
      gstin: map['gstin'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'period': period,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status.index,
      'filedDate': filedDate?.millisecondsSinceEpoch,
      'acknowledgementNumber': acknowledgementNumber,
      'totalTaxAmount': totalTaxAmount,
      'gstin': gstin,
    };
  }

  String getTypeDisplayName() {
    switch (type) {
      case GstReturnType.gstr1:
        return 'GSTR-1';
      case GstReturnType.gstr2a:
        return 'GSTR-2A';
      case GstReturnType.gstr2b:
        return 'GSTR-2B';
      case GstReturnType.gstr3b:
        return 'GSTR-3B';
      case GstReturnType.gstr4:
        return 'GSTR-4';
      case GstReturnType.gstr9:
        return 'GSTR-9';
      case GstReturnType.gstr9c:
        return 'GSTR-9C';
    }
  }

  String getStatusDisplayName() {
    switch (status) {
      case GstReturnStatus.notDue:
        return 'Not Due';
      case GstReturnStatus.pending:
        return 'Pending';
      case GstReturnStatus.filed:
        return 'Filed';
      case GstReturnStatus.error:
        return 'Error';
    }
  }

  String getTypeDescription() {
    switch (type) {
      case GstReturnType.gstr1:
        return 'Outward Supplies';
      case GstReturnType.gstr2a:
        return 'Inward Supplies (Auto-populated)';
      case GstReturnType.gstr2b:
        return 'ITC Statement';
      case GstReturnType.gstr3b:
        return 'Monthly Summary Return';
      case GstReturnType.gstr4:
        return 'Composition Scheme Return';
      case GstReturnType.gstr9:
        return 'Annual Return';
      case GstReturnType.gstr9c:
        return 'Annual Reconciliation Statement';
    }
  }

  String getFrequency() {
    switch (type) {
      case GstReturnType.gstr1:
      case GstReturnType.gstr2a:
      case GstReturnType.gstr2b:
      case GstReturnType.gstr3b:
        return 'Monthly';
      case GstReturnType.gstr4:
        return 'Quarterly';
      case GstReturnType.gstr9:
      case GstReturnType.gstr9c:
        return 'Annual';
    }
  }
}
