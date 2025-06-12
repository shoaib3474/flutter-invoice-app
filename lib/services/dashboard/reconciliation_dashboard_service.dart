import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/repositories/reconciliation_repository.dart';
import 'package:intl/intl.dart';

class ReconciliationDashboardService {
  final ReconciliationRepository _reconciliationRepository;

  ReconciliationDashboardService(this._reconciliationRepository);

  Future<ReconciliationDashboardMetrics> getDashboardMetrics() async {
    try {
      // Get all reconciliation results
      final allResults = await _reconciliationRepository.getAllReconciliationResults();
      
      if (allResults.isEmpty) {
        return ReconciliationDashboardMetrics.empty();
      }

      // Calculate total reconciliations
      final totalReconciliations = allResults.length;

      // Calculate pending issues
      final pendingIssues = allResults.fold<int>(0, (sum, result) {
        return sum + result.summary.mismatchedInvoices + result.summary.partiallyMatchedInvoices;
      });

      // Calculate total tax difference
      final totalTaxDifference = allResults.fold<double>(0, (sum, result) {
        return sum + result.summary.totalTaxDifference;
      });

      // Calculate compliance score (100% - percentage of issues)
      final totalInvoices = allResults.fold<int>(0, (sum, result) {
        return sum + result.summary.totalInvoices;
      });
      
      final totalIssues = allResults.fold<int>(0, (sum, result) {
        return sum + result.summary.mismatchedInvoices + result.summary.partiallyMatchedInvoices;
      });
      
      final complianceScore = totalInvoices > 0 
          ? 100 - ((totalIssues / totalInvoices) * 100)
          : 100;

      // Calculate metrics by reconciliation type
      final typeMetrics = <ReconciliationType, ReconciliationTypeMetric>{};
      
      for (final type in ReconciliationType.values) {
        final resultsOfType = allResults.where((r) => r.type == type).toList();
        
        if (resultsOfType.isNotEmpty) {
          final count = resultsOfType.length;
          
          final issuesCount = resultsOfType.fold<int>(0, (sum, result) {
            return sum + result.summary.mismatchedInvoices + result.summary.partiallyMatchedInvoices;
          });
          
          final totalTaxDiff = resultsOfType.fold<double>(0, (sum, result) {
            return sum + result.summary.totalTaxDifference;
          });
          
          final averageTaxDifference = count > 0 ? totalTaxDiff / count : 0;
          
          final totalMatchedInvoices = resultsOfType.fold<int>(0, (sum, result) {
            return sum + result.summary.matchedInvoices;
          });
          
          final totalInvoicesOfType = resultsOfType.fold<int>(0, (sum, result) {
            return sum + result.summary.totalInvoices;
          });
          
          final matchPercentage = totalInvoicesOfType > 0 
              ? (totalMatchedInvoices / totalInvoicesOfType) * 100
              : 0;
          
          typeMetrics[type] = ReconciliationTypeMetric(
            type: type,
            count: count,
            issuesCount: issuesCount,
            averageTaxDifference: averageTaxDifference,
            matchPercentage: matchPercentage,
          );
        }
      }

      // Calculate monthly metrics
      final monthlyData = <String, MonthlyReconciliationMetric>{};
      final dateFormat = DateFormat('MMM yyyy');
      
      for (final result in allResults) {
        final month = dateFormat.format(result.reconciliationDate);
        
        if (!monthlyData.containsKey(month)) {
          monthlyData[month] = MonthlyReconciliationMetric(
            month: month,
            reconciliationCount: 0,
            issuesCount: 0,
            taxDifference: 0,
            matchPercentage: 0,
          );
        }
        
        final currentData = monthlyData[month]!;
        final issuesCount = result.summary.mismatchedInvoices + result.summary.partiallyMatchedInvoices;
        final matchPercentage = result.summary.totalInvoices > 0 
            ? (result.summary.matchedInvoices / result.summary.totalInvoices) * 100
            : 0;
        
        monthlyData[month] = MonthlyReconciliationMetric(
          month: month,
          reconciliationCount: currentData.reconciliationCount + 1,
          issuesCount: currentData.issuesCount + issuesCount,
          taxDifference: currentData.taxDifference + result.summary.totalTaxDifference,
          matchPercentage: (currentData.matchPercentage * currentData.reconciliationCount + matchPercentage) / 
              (currentData.reconciliationCount + 1),
        );
      }
      
      // Sort monthly metrics by date
      final sortedMonthlyMetrics = monthlyData.values.toList()
        ..sort((a, b) {
          final aDate = DateFormat('MMM yyyy').parse(a.month);
          final bDate = DateFormat('MMM yyyy').parse(b.month);
          return aDate.compareTo(bDate);
        });

      // Calculate top discrepancies
      final discrepancyTypes = <String, DiscrepancyTypeMetric>{};
      
      for (final result in allResults) {
        for (final item in result.items) {
          if (item.discrepancies != null) {
            for (final discrepancy in item.discrepancies!) {
              if (!discrepancyTypes.containsKey(discrepancy)) {
                discrepancyTypes[discrepancy] = DiscrepancyTypeMetric(
                  discrepancyType: discrepancy,
                  count: 0,
                  totalValue: 0,
                  percentageOfTotal: 0,
                );
              }
              
              final currentData = discrepancyTypes[discrepancy]!;
              final discrepancyValue = _calculateDiscrepancyValue(item, discrepancy);
              
              discrepancyTypes[discrepancy] = DiscrepancyTypeMetric(
                discrepancyType: discrepancy,
                count: currentData.count + 1,
                totalValue: currentData.totalValue + discrepancyValue,
                percentageOfTotal: 0, // Will calculate after summing all
              );
            }
          }
        }
      }
      
      // Calculate percentage of total for each discrepancy type
      final totalDiscrepancyValue = discrepancyTypes.values.fold<double>(0, (sum, metric) {
        return sum + metric.totalValue;
      });
      
      final updatedDiscrepancyTypes = discrepancyTypes.map((key, value) {
        return MapEntry(
          key,
          DiscrepancyTypeMetric(
            discrepancyType: value.discrepancyType,
            count: value.count,
            totalValue: value.totalValue,
            percentageOfTotal: totalDiscrepancyValue > 0 
                ? (value.totalValue / totalDiscrepancyValue) * 100
                : 0,
          ),
        );
      });
      
      // Sort discrepancy types by total value
      final sortedDiscrepancyTypes = updatedDiscrepancyTypes.values.toList()
        ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
      
      // Get top 5 discrepancies
      final topDiscrepancies = sortedDiscrepancyTypes.take(5).toList();

      // Get recent reconciliations
      final sortedResults = allResults.toList()
        ..sort((a, b) => b.reconciliationDate.compareTo(a.reconciliationDate));
      
      final recentReconciliations = sortedResults.take(5).map((result) {
        final issuesCount = result.summary.mismatchedInvoices + result.summary.partiallyMatchedInvoices;
        final matchPercentage = result.summary.totalInvoices > 0 
            ? (result.summary.matchedInvoices / result.summary.totalInvoices) * 100
            : 0;
        
        return RecentReconciliation(
          id: result.id,
          type: result.type,
          period: result.period,
          date: result.reconciliationDate,
          issuesCount: issuesCount,
          taxDifference: result.summary.totalTaxDifference,
          matchPercentage: matchPercentage,
        );
      }).toList();

      // Create dashboard metrics
      return ReconciliationDashboardMetrics(
        totalReconciliations: totalReconciliations,
        pendingIssues: pendingIssues,
        totalTaxDifference: totalTaxDifference,
        complianceScore: complianceScore,
        reconciliationTypeMetrics: typeMetrics.values.toList(),
        monthlyMetrics: sortedMonthlyMetrics,
        topDiscrepancies: topDiscrepancies,
        recentReconciliations: recentReconciliations,
      );
    } catch (e) {
      throw Exception('Failed to generate dashboard metrics: ${e.toString()}');
    }
  }

  double _calculateDiscrepancyValue(ReconciliationItem item, String discrepancyType) {
    switch (discrepancyType) {
      case 'Taxable value mismatch':
        final value1 = item.taxableValueSource1 ?? 0;
        final value2 = item.taxableValueSource2 ?? 0;
        return (value1 - value2).abs();
      case 'IGST amount mismatch':
        final value1 = item.igstSource1 ?? 0;
        final value2 = item.igstSource2 ?? 0;
        return (value1 - value2).abs();
      case 'CGST amount mismatch':
        final value1 = item.cgstSource1 ?? 0;
        final value2 = item.cgstSource2 ?? 0;
        return (value1 - value2).abs();
      case 'SGST amount mismatch':
        final value1 = item.sgstSource1 ?? 0;
        final value2 = item.sgstSource2 ?? 0;
        return (value1 - value2).abs();
      default:
        return 0;
    }
  }
}
