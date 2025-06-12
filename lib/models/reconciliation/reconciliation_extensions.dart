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
