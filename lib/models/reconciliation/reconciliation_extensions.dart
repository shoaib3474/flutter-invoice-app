extension ReconciliationSummaryExtensions on ReconciliationSummary {
  int get unmatchedInvoices => mismatchedInvoices;
  double get totalTaxableValueInSource1 => totalTaxableValueSource1 ?? 0;
  double get totalTaxableValueInSource2 => totalTaxableValueSource2 ?? 0;
  double get totalTaxInSource1 => totalTaxSource1 ?? 0;
  double get totalTaxInSource2 => totalTaxSource2 ?? 0;
  double get taxDifference => totalTaxDifference;
}

extension ReconciliationItemExtensions on ReconciliationItem {
  double get taxableValueInSource1 => taxableValueSource1 ?? 0;
  double get taxableValueInSource2 => taxableValueSource2 ?? 0;
  double get igstInSource1 => igstSource1 ?? 0;
  double get igstInSource2 => igstSource2 ?? 0;
  double get cgstInSource1 => cgstSource1 ?? 0;
  double get cgstInSource2 => cgstSource2 ?? 0;
  double get sgstInSource1 => sgstSource1 ?? 0;
  double get sgstInSource2 => sgstSource2 ?? 0;
}

// class
class ReconciliationSummary {
  ReconciliationSummary({
    required this.mismatchedInvoices,
    required this.totalTaxDifference,
    this.totalTaxableValueSource1,
    this.totalTaxableValueSource2,
    this.totalTaxSource1,
    this.totalTaxSource2,
  });
  final int mismatchedInvoices;
  final double? totalTaxableValueSource1;
  final double? totalTaxableValueSource2;
  final double? totalTaxSource1;
  final double? totalTaxSource2;
  final double totalTaxDifference;
}

// class

class ReconciliationItem {
  ReconciliationItem({
    this.taxableValueSource1,
    this.taxableValueSource2,
    this.igstSource1,
    this.igstSource2,
    this.cgstSource1,
    this.cgstSource2,
    this.sgstSource1,
    this.sgstSource2,
  });
  final double? taxableValueSource1;
  final double? taxableValueSource2;
  final double? igstSource1;
  final double? igstSource2;
  final double? cgstSource1;
  final double? cgstSource2;
  final double? sgstSource1;
  final double? sgstSource2;
}
