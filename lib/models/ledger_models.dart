// Base class for all ledger entries
abstract class LedgerEntry {
  LedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.referenceNumber,
    required this.status,
  });
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String referenceNumber;
  final String status;

  Map<String, dynamic> toJson();
}

// Cash Ledger Model
class CashLedger {
  CashLedger({
    required this.gstin,
    required this.cgstBalance,
    required this.sgstBalance,
    required this.igstBalance,
    required this.cessBalance,
    required this.interestBalance,
    required this.penaltyBalance,
    required this.feeBalance,
    required this.othersBalance,
    required this.entries,
  });

  factory CashLedger.fromJson(Map<String, dynamic> json) {
    List<CashLedgerEntry> entries = [];
    if (json['entries'] != null) {
      json['entries'].forEach((entry) {
        entries.add(CashLedgerEntry.fromJson(entry));
      });
    }

    return CashLedger(
      gstin: json['gstin'],
      cgstBalance: json['cgst_balance'] ?? 0.0,
      sgstBalance: json['sgst_balance'] ?? 0.0,
      igstBalance: json['igst_balance'] ?? 0.0,
      cessBalance: json['cess_balance'] ?? 0.0,
      interestBalance: json['interest_balance'] ?? 0.0,
      penaltyBalance: json['penalty_balance'] ?? 0.0,
      feeBalance: json['fee_balance'] ?? 0.0,
      othersBalance: json['others_balance'] ?? 0.0,
      entries: entries,
    );
  }
  final String gstin;
  final double cgstBalance;
  final double sgstBalance;
  final double igstBalance;
  final double cessBalance;
  final double interestBalance;
  final double penaltyBalance;
  final double feeBalance;
  final double othersBalance;
  final List<CashLedgerEntry> entries;

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'cgst_balance': cgstBalance,
      'sgst_balance': sgstBalance,
      'igst_balance': igstBalance,
      'cess_balance': cessBalance,
      'interest_balance': interestBalance,
      'penalty_balance': penaltyBalance,
      'fee_balance': feeBalance,
      'others_balance': othersBalance,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }
}

class CashLedgerEntry {
  const CashLedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.taxType,
    required this.amount,
    required this.paymentMode,
    required this.referenceNumber,
    required this.openingBalance,
    required this.closingBalance,
  });

  factory CashLedgerEntry.fromJson(Map<String, dynamic> json) {
    return CashLedgerEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      taxType: json['taxType'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['paymentMode'] as String,
      referenceNumber: json['referenceNumber'] as String,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'taxType': taxType,
      'amount': amount,
      'paymentMode': paymentMode,
      'referenceNumber': referenceNumber,
      'openingBalance': openingBalance,
      'closingBalance': closingBalance,
    };
  }

  final String id;
  final DateTime date;
  final String description;
  final String taxType;
  final double amount;
  final String paymentMode;
  final String referenceNumber;
  final double openingBalance;
  final double closingBalance;
}

// RCM (Reverse Charge Mechanism) Ledger Model
class RCMLedger {
  RCMLedger({
    required this.gstin,
    required this.cgstBalance,
    required this.sgstBalance,
    required this.igstBalance,
    required this.cessBalance,
    required this.entries,
  });

  factory RCMLedger.fromJson(Map<String, dynamic> json) {
    List<RCMLedgerEntry> entries = [];
    if (json['entries'] != null) {
      json['entries'].forEach((entry) {
        entries.add(RCMLedgerEntry.fromJson(entry));
      });
    }

    return RCMLedger(
      gstin: json['gstin'],
      cgstBalance: json['cgst_balance'] ?? 0.0,
      sgstBalance: json['sgst_balance'] ?? 0.0,
      igstBalance: json['igst_balance'] ?? 0.0,
      cessBalance: json['cess_balance'] ?? 0.0,
      entries: entries,
    );
  }
  final String gstin;
  final double cgstBalance;
  final double sgstBalance;
  final double igstBalance;
  final double cessBalance;
  final List<RCMLedgerEntry> entries;

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'cgst_balance': cgstBalance,
      'sgst_balance': sgstBalance,
      'igst_balance': igstBalance,
      'cess_balance': cessBalance,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }
}

class RCMLedgerEntry {
  const RCMLedgerEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.taxType,
    required this.status,
    required this.category,
    required this.supplierGstin,
    required this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    required this.paymentStatus,
    this.metadata = const {},
  });

  factory RCMLedgerEntry.fromJson(Map<String, dynamic> json) {
    return RCMLedgerEntry(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      taxType: json['taxType'] as String,
      status: json['status'] as String,
      category: json['category'] as String,
      supplierGstin: json['supplierGstin'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      invoiceDate: json['invoiceDate'] != null
          ? DateTime.parse(json['invoiceDate'] as String)
          : DateTime.now(),
      taxableValue: (json['taxableValue'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (json['igstAmount'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (json['cgstAmount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgstAmount'] as num?)?.toDouble() ?? 0.0,
      cessAmount: (json['cessAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus:
          json['paymentStatus'] as String? ?? json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String taxType;
  final String status;
  final String category;
  final String supplierGstin;
  final String supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final String paymentStatus;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'taxType': taxType,
      'status': status,
      'category': category,
      'supplierGstin': supplierGstin,
      'supplierName': supplierName,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'taxableValue': taxableValue,
      'igstAmount': igstAmount,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'cessAmount': cessAmount,
      'paymentStatus': paymentStatus,
      'metadata': metadata,
    };
  }

  RCMLedgerEntry copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? taxType,
    String? status,
    String? category,
    String? supplierGstin,
    String? supplierName,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? taxableValue,
    double? igstAmount,
    double? cgstAmount,
    double? sgstAmount,
    double? cessAmount,
    String? paymentStatus,
    Map<String, dynamic>? metadata,
  }) {
    return RCMLedgerEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      taxType: taxType ?? this.taxType,
      status: status ?? this.status,
      category: category ?? this.category,
      supplierGstin: supplierGstin ?? this.supplierGstin,
      supplierName: supplierName ?? this.supplierName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      taxableValue: taxableValue ?? this.taxableValue,
      igstAmount: igstAmount ?? this.igstAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      cessAmount: cessAmount ?? this.cessAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Liabilities Ledger Model
class LiabilitiesLedger {
  LiabilitiesLedger({
    required this.gstin,
    required this.cgstBalance,
    required this.sgstBalance,
    required this.igstBalance,
    required this.cessBalance,
    required this.interestBalance,
    required this.penaltyBalance,
    required this.feeBalance,
    required this.othersBalance,
    required this.entries,
  });

  factory LiabilitiesLedger.fromJson(Map<String, dynamic> json) {
    List<LiabilitiesLedgerEntry> entries = [];
    if (json['entries'] != null) {
      json['entries'].forEach((entry) {
        entries.add(LiabilitiesLedgerEntry.fromJson(entry));
      });
    }

    return LiabilitiesLedger(
      gstin: json['gstin'],
      cgstBalance: json['cgst_balance'] ?? 0.0,
      sgstBalance: json['sgst_balance'] ?? 0.0,
      igstBalance: json['igst_balance'] ?? 0.0,
      cessBalance: json['cess_balance'] ?? 0.0,
      interestBalance: json['interest_balance'] ?? 0.0,
      penaltyBalance: json['penalty_balance'] ?? 0.0,
      feeBalance: json['fee_balance'] ?? 0.0,
      othersBalance: json['others_balance'] ?? 0.0,
      entries: entries,
    );
  }
  final String gstin;
  final double cgstBalance;
  final double sgstBalance;
  final double igstBalance;
  final double cessBalance;
  final double interestBalance;
  final double penaltyBalance;
  final double feeBalance;
  final double othersBalance;
  final List<LiabilitiesLedgerEntry> entries;

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'cgst_balance': cgstBalance,
      'sgst_balance': sgstBalance,
      'igst_balance': igstBalance,
      'cess_balance': cessBalance,
      'interest_balance': interestBalance,
      'penalty_balance': penaltyBalance,
      'fee_balance': feeBalance,
      'others_balance': othersBalance,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }
}

class LiabilitiesLedgerEntry {
  const LiabilitiesLedgerEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.taxType,
    required this.status,
    required this.category,
    this.metadata = const {},
  });

  factory LiabilitiesLedgerEntry.fromJson(Map<String, dynamic> json) {
    return LiabilitiesLedgerEntry(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      taxType: json['taxType'] as String,
      status: json['status'] as String,
      category: json['category'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String taxType;
  final String status;
  final String category;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'taxType': taxType,
      'status': status,
      'category': category,
      'metadata': metadata,
    };
  }
}

class LiabilityEntry {
  const LiabilityEntry({
    required this.description,
    required this.taxPeriod,
    required this.amount,
    required this.interest,
    required this.penalty,
    required this.status,
  });

  factory LiabilityEntry.fromJson(Map<String, dynamic> json) {
    return LiabilityEntry(
      description: json['description'] as String? ?? 'No description',
      taxPeriod: json['taxPeriod'] as String? ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      interest: (json['interest'] as num?)?.toDouble() ?? 0.0,
      penalty: (json['penalty'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Unknown',
    );
  }
  final String description;
  final String taxPeriod;
  final double amount;
  final double interest;
  final double penalty;
  final String status;

  double get total => amount + interest + penalty;

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'taxPeriod': taxPeriod,
      'amount': amount,
      'interest': interest,
      'penalty': penalty,
      'status': status,
    };
  }
}

// Electronic Ledger Model
class ElectronicLedger {
  ElectronicLedger({
    required this.gstin,
    required this.cgstBalance,
    required this.sgstBalance,
    required this.igstBalance,
    required this.cessBalance,
    required this.entries,
  });

  factory ElectronicLedger.fromJson(Map<String, dynamic> json) {
    List<ElectronicLedgerEntry> entries = [];
    if (json['entries'] != null) {
      json['entries'].forEach((entry) {
        entries.add(ElectronicLedgerEntry.fromJson(entry));
      });
    }

    return ElectronicLedger(
      gstin: json['gstin'],
      cgstBalance: json['cgst_balance'] ?? 0.0,
      sgstBalance: json['sgst_balance'] ?? 0.0,
      igstBalance: json['igst_balance'] ?? 0.0,
      cessBalance: json['cess_balance'] ?? 0.0,
      entries: entries,
    );
  }
  final String gstin;
  final double cgstBalance;
  final double sgstBalance;
  final double igstBalance;
  final double cessBalance;
  final List<ElectronicLedgerEntry> entries;

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'cgst_balance': cgstBalance,
      'sgst_balance': sgstBalance,
      'igst_balance': igstBalance,
      'cess_balance': cessBalance,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }
}

class ElectronicLedgerEntry {
  const ElectronicLedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.transactionType,
    required this.taxType,
    required this.source,
    required this.amount,
    required this.referenceNumber,
    required this.openingBalance,
    required this.closingBalance,
    required this.status,
  });

  factory ElectronicLedgerEntry.fromJson(Map<String, dynamic> json) {
    return ElectronicLedgerEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      transactionType: json['transactionType'] as String,
      taxType: json['taxType'] as String,
      source: json['source'] as String,
      amount: (json['amount'] as num).toDouble(),
      referenceNumber: json['referenceNumber'] as String,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'transactionType': transactionType,
      'taxType': taxType,
      'source': source,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'openingBalance': openingBalance,
      'closingBalance': closingBalance,
      'status': status,
    };
  }

  final String id;
  final DateTime date;
  final String description;
  final String transactionType;
  final String taxType;
  final String source;
  final double amount;
  final String referenceNumber;
  final double openingBalance;
  final double closingBalance;
  final String status;
}
