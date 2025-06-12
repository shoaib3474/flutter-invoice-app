class TaxCalculator {
  static Map<String, double> calculateGST({
    required double taxableValue,
    required double gstRate,
    required bool isInterState,
  }) {
    final gstAmount = (taxableValue * gstRate) / 100;
    
    if (isInterState) {
      return {
        'igst': gstAmount,
        'cgst': 0.0,
        'sgst': 0.0,
        'total_tax': gstAmount,
      };
    } else {
      final cgst = gstAmount / 2;
      final sgst = gstAmount / 2;
      return {
        'igst': 0.0,
        'cgst': cgst,
        'sgst': sgst,
        'total_tax': gstAmount,
      };
    }
  }

  static double calculateCess({
    required double taxableValue,
    required double cessRate,
  }) {
    return (taxableValue * cessRate) / 100;
  }

  static Map<String, double> calculateTotalTax({
    required double taxableValue,
    required double gstRate,
    required double cessRate,
    required bool isInterState,
  }) {
    final gstCalculation = calculateGST(
      taxableValue: taxableValue,
      gstRate: gstRate,
      isInterState: isInterState,
    );
    
    final cess = calculateCess(
      taxableValue: taxableValue,
      cessRate: cessRate,
    );
    
    return {
      'taxable_value': taxableValue,
      'igst': gstCalculation['igst']!,
      'cgst': gstCalculation['cgst']!,
      'sgst': gstCalculation['sgst']!,
      'cess': cess,
      'total_tax': gstCalculation['total_tax']! + cess,
      'total_amount': taxableValue + gstCalculation['total_tax']! + cess,
    };
  }

  static double reverseCalculateGST({
    required double totalAmount,
    required double gstRate,
  }) {
    return totalAmount / (1 + (gstRate / 100));
  }
}
