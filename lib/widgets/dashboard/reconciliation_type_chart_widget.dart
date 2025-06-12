// ignore_for_file: avoid_redundant_argument_values

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';

class ReconciliationTypeChartWidget extends StatelessWidget {
  const ReconciliationTypeChartWidget({
    required this.typeMetrics,
    Key? key,
  }) : super(key: key);
  final List<ReconciliationTypeMetric> typeMetrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reconciliation by Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: typeMetrics.isEmpty
                  ? const Center(child: Text('No data available'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final metric = typeMetrics[groupIndex];
                              return BarTooltipItem(
                                '${_getReconciliationTypeText(metric.type)}\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        'Match: ${metric.matchPercentage.toStringAsFixed(1)}%\n',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Issues: ${metric.issuesCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value >= typeMetrics.length || value < 0) {
                                  return const SizedBox.shrink();
                                }
                                final type = typeMetrics[value.toInt()].type;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getReconciliationTypeShortText(type),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: typeMetrics.asMap().entries.map((entry) {
                          final index = entry.key;
                          final metric = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: metric.matchPercentage,
                                color: _getBarColor(metric.matchPercentage),
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Legend',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: typeMetrics.map((metric) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getBarColor(metric.matchPercentage),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getReconciliationTypeText(metric.type),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(double matchPercentage) {
    if (matchPercentage >= 90) {
      return Colors.green;
    } else if (matchPercentage >= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getReconciliationTypeText(ReconciliationType type) {
    switch (type) {
      case ReconciliationType.gstr1VsGstr2a:
        return 'GSTR-1 vs GSTR-2A';
      case ReconciliationType.gstr2aVsGstr2b:
        return 'GSTR-2A vs GSTR-2B';
      case ReconciliationType.comprehensive:
        return 'Comprehensive';
      default:
        return 'Unknown';
    }
  }

  String _getReconciliationTypeShortText(ReconciliationType type) {
    switch (type) {
      case ReconciliationType.gstr1VsGstr2a:
        return '1 vs 2A';
      case ReconciliationType.gstr2aVsGstr2b:
        return '2A vs 2B';
      case ReconciliationType.comprehensive:
        return 'Comp.';
      default:
        return 'Unknown';
    }
  }
}
