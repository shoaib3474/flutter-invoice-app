class GstinFilingHistory {
  const GstinFilingHistory({
    required this.gstin,
    required this.returnType,
    required this.records,
  });
  final String gstin;
  final String returnType;
  final List<FilingRecord> records;

  bool get isEmpty => records.isEmpty;
  bool get isNotEmpty => records.isNotEmpty;
}

class FilingRecord {
  const FilingRecord({
    required this.period,
    required this.dueDate,
    required this.status,
    this.filedDate,
    this.isNilReturn = false,
  });
  final String period;
  final DateTime? filedDate;
  final DateTime dueDate;
  final String status;
  final bool isNilReturn;

  bool get isFiled => filedDate != null;
  bool get isOverdue => !isFiled && DateTime.now().isAfter(dueDate);
  bool get isFiledLate => isFiled && filedDate!.isAfter(dueDate);
}
