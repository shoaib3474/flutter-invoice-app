class GSTR1Summary {
  final double totalTaxableValue;
  final double totalIgstAmount;
  final double totalCgstAmount;
  final double totalSgstAmount;
  final double totalCessAmount;
  final int totalB2BInvoices;
  final int totalB2CLInvoices;
  final int totalB2CSInvoices;
  final int totalHSNEntries;

  GSTR1Summary({
    required this.totalTaxableValue,
    required this.totalIgstAmount,
    required this.totalCgstAmount,
    required this.totalSgstAmount,
    required this.totalCessAmount,
    required this.totalB2BInvoices,
    required this.totalB2CLInvoices,
    required this.totalB2CSInvoices,
    required this.totalHSNEntries,
  });

  factory GSTR1Summary.fromJson(Map<String, dynamic> json) {
    return GSTR1Summary(
      totalTaxableValue: (json['total_taxable_value'] ?? 0.0).toDouble(),
      totalIgstAmount: (json['total_igst_amount'] ?? 0.0).toDouble(),
      totalCgstAmount: (json['total_cgst_amount'] ?? 0.0).toDouble(),
      totalSgstAmount: (json['total_sgst_amount'] ?? 0.0).toDouble(),
      totalCessAmount: (json['total_cess_amount'] ?? 0.0).toDouble(),
      totalB2BInvoices: json['total_b2b_invoices'] ?? 0,
      totalB2CLInvoices: json['total_b2cl_invoices'] ?? 0,
      totalB2CSInvoices: json['total_b2cs_invoices'] ?? 0,
      totalHSNEntries: json['total_hsn_entries'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_taxable_value': totalTaxableValue,
      'total_igst_amount': totalIgstAmount,
      'total_cgst_amount': totalCgstAmount,
      'total_sgst_amount': totalSgstAmount,
      'total_cess_amount': totalCessAmount,
      'total_b2b_invoices': totalB2BInvoices,
      'total_b2cl_invoices': totalB2CLInvoices,
      'total_b2cs_invoices': totalB2CSInvoices,
      'total_hsn_entries': totalHSNEntries,
    };
  }
}

class GSTR3BSummary {
  final double totalOutwardTaxableValue;
  final double totalOutwardTax;
  final double totalInwardTaxableValue;
  final double totalInwardTax;
  final double totalITCAvailable;
  final double totalITCUtilized;
  final double totalTaxPayable;
  final double totalTaxPaid;

  GSTR3BSummary({
    required this.totalOutwardTaxableValue,
    required this.totalOutwardTax,
    required this.totalInwardTaxableValue,
    required this.totalInwardTax,
    required this.totalITCAvailable,
    required this.totalITCUtilized,
    required this.totalTaxPayable,
    required this.totalTaxPaid,
  });

  factory GSTR3BSummary.fromJson(Map<String, dynamic> json) {
    return GSTR3BSummary(
      totalOutwardTaxableValue: (json['total_outward_taxable_value'] ?? 0.0).toDouble(),
      totalOutwardTax: (json['total_outward_tax'] ?? 0.0).toDouble(),
      totalInwardTaxableValue: (json['total_inward_taxable_value'] ?? 0.0).toDouble(),
      totalInwardTax: (json['total_inward_tax'] ?? 0.0).toDouble(),
      totalITCAvailable: (json['total_itc_available'] ?? 0.0).toDouble(),
      totalITCUtilized: (json['total_itc_utilized'] ?? 0.0).toDouble(),
      totalTaxPayable: (json['total_tax_payable'] ?? 0.0).toDouble(),
      totalTaxPaid: (json['total_tax_paid'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_outward_taxable_value': totalOutwardTaxableValue,
      'total_outward_tax': totalOutwardTax,
      'total_inward_taxable_value': totalInwardTaxableValue,
      'total_inward_tax': totalInwardTax,
      'total_itc_available': totalITCAvailable,
      'total_itc_utilized': totalITCUtilized,
      'total_tax_payable': totalTaxPayable,
      'total_tax_paid': totalTaxPaid,
    };
  }
}

class GSTR9Summary {
  final double totalAnnualTurnover;
  final double totalTaxLiability;
  final double totalTaxPaid;
  final double totalITCAvailed;
  final double totalITCReversed;
  final double netTaxLiability;
  final double additionalTaxPayable;
  final double refundClaimed;

  GSTR9Summary({
    required this.totalAnnualTurnover,
    required this.totalTaxLiability,
    required this.totalTaxPaid,
    required this.totalITCAvailed,
    required this.totalITCReversed,
    required this.netTaxLiability,
    required this.additionalTaxPayable,
    required this.refundClaimed,
  });

  factory GSTR9Summary.fromJson(Map<String, dynamic> json) {
    return GSTR9Summary(
      totalAnnualTurnover: (json['total_annual_turnover'] ?? 0.0).toDouble(),
      totalTaxLiability: (json['total_tax_liability'] ?? 0.0).toDouble(),
      totalTaxPaid: (json['total_tax_paid'] ?? 0.0).toDouble(),
      totalITCAvailed: (json['total_itc_availed'] ?? 0.0).toDouble(),
      totalITCReversed: (json['total_itc_reversed'] ?? 0.0).toDouble(),
      netTaxLiability: (json['net_tax_liability'] ?? 0.0).toDouble(),
      additionalTaxPayable: (json['additional_tax_payable'] ?? 0.0).toDouble(),
      refundClaimed: (json['refund_claimed'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_annual_turnover': totalAnnualTurnover,
      'total_tax_liability': totalTaxLiability,
      'total_tax_paid': totalTaxPaid,
      'total_itc_availed': totalITCAvailed,
      'total_itc_reversed': totalITCReversed,
      'net_tax_liability': netTaxLiability,
      'additional_tax_payable': additionalTaxPayable,
      'refund_claimed': refundClaimed,
    };
  }
}

class GSTR9CSummary {
  final double turnoversPerAuditedFS;
  final double turnoversPerAnnualReturn;
  final double unreconciledDifference;
  final List<String> reasonsForDifference;
  final double additionalLiabilityIdentified;
  final double additionalTaxPaid;
  final double lateFeePaid;
  final double interestPaid;

  GSTR9CSummary({
    required this.turnoversPerAuditedFS,
    required this.turnoversPerAnnualReturn,
    required this.unreconciledDifference,
    required this.reasonsForDifference,
    required this.additionalLiabilityIdentified,
    required this.additionalTaxPaid,
    required this.lateFeePaid,
    required this.interestPaid,
  });

  factory GSTR9CSummary.fromJson(Map<String, dynamic> json) {
    return GSTR9CSummary(
      turnoversPerAuditedFS: (json['turnovers_per_audited_fs'] ?? 0.0).toDouble(),
      turnoversPerAnnualReturn: (json['turnovers_per_annual_return'] ?? 0.0).toDouble(),
      unreconciledDifference: (json['unreconciled_difference'] ?? 0.0).toDouble(),
      reasonsForDifference: List<String>.from(json['reasons_for_difference'] ?? []),
      additionalLiabilityIdentified: (json['additional_liability_identified'] ?? 0.0).toDouble(),
      additionalTaxPaid: (json['additional_tax_paid'] ?? 0.0).toDouble(),
      lateFeePaid: (json['late_fee_paid'] ?? 0.0).toDouble(),
      interestPaid: (json['interest_paid'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'turnovers_per_audited_fs': turnoversPerAuditedFS,
      'turnovers_per_annual_return': turnoversPerAnnualReturn,
      'unreconciled_difference': unreconciledDifference,
      'reasons_for_difference': reasonsForDifference,
      'additional_liability_identified': additionalLiabilityIdentified,
      'additional_tax_paid': additionalTaxPaid,
      'late_fee_paid': lateFeePaid,
      'interest_paid': interestPaid,
    };
  }
}
