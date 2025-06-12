enum ReconciliationType { typeA, typeB, typeC }

class ReconciliationDashboardMetrics {
  ReconciliationDashboardMetrics({
    required this.totalReconciliations,
    required this.pendingIssues,
    required this.totalTaxDifference,
    required this.complianceScore,
    required this.reconciliationTypeMetrics,
    required this.monthlyMetrics,
    required this.topDiscrepancies,
    required this.recentReconciliations,
  });

  factory ReconciliationDashboardMetrics.empty() {
    return ReconciliationDashboardMetrics(
      totalReconciliations: 0,
      pendingIssues: 0,
      totalTaxDifference: 0,
      complianceScore: 100,
      reconciliationTypeMetrics: [],
      monthlyMetrics: [],
      topDiscrepancies: [],
      recentReconciliations: [],
    );
  }
  final int totalReconciliations;
  final int pendingIssues;
  final double totalTaxDifference;
  final double complianceScore;
  final List<ReconciliationTypeMetric> reconciliationTypeMetrics;
  final List<MonthlyReconciliationMetric> monthlyMetrics;
  final List<DiscrepancyTypeMetric> topDiscrepancies;
  final List<RecentReconciliation> recentReconciliations;
}

class ReconciliationTypeMetric {
  ReconciliationTypeMetric({
    required this.type,
    required this.count,
    required this.issuesCount,
    required this.averageTaxDifference,
    required this.matchPercentage,
  });
  final ReconciliationType type;
  final int count;
  final int issuesCount;
  final double averageTaxDifference;
  final double matchPercentage;
}

class MonthlyReconciliationMetric {
  MonthlyReconciliationMetric({
    required this.month,
    required this.reconciliationCount,
    required this.issuesCount,
    required this.taxDifference,
    required this.matchPercentage,
  });
  final String month;
  final int reconciliationCount;
  final int issuesCount;
  final double taxDifference;
  final double matchPercentage;
}

class DiscrepancyTypeMetric {
  DiscrepancyTypeMetric({
    required this.discrepancyType,
    required this.count,
    required this.totalValue,
    required this.percentageOfTotal,
  });
  final String discrepancyType;
  final int count;
  final double totalValue;
  final double percentageOfTotal;
}

class RecentReconciliation {
  RecentReconciliation({
    required this.id,
    required this.type,
    required this.period,
    required this.date,
    required this.issuesCount,
    required this.taxDifference,
    required this.matchPercentage,
  });
  final String id;
  final ReconciliationType type;
  final String period;
  final DateTime date;
  final int issuesCount;
  final double taxDifference;
  final double matchPercentage;
}
