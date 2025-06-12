class GstinFilingHistory {
  final String gstin;
  final String returnType;
  final List<FilingRecord> records;

  const GstinFilingHistory({
    required this.gstin,
    required this.returnType,
    required this.records,
  });

  bool get isEmpty => records.isEmpty;
  bool get isNotEmpty => records.isNotEmpty;
}

class FilingRecord {
  final String period;
  final DateTime? filedDate;
  final DateTime dueDate;
  final String status;
  final bool isNilReturn;

  const FilingRecord({
    required this.period,
    this.filedDate,
    required this.dueDate,
    required this.status,
    this.isNilReturn = false,
  });

  bool get isFiled => filedDate != null;
  bool get isOverdue => !isFiled && DateTime.now().isAfter(dueDate);
  bool get isFiledLate => isFiled && filedDate!.isAfter(dueDate);
}
