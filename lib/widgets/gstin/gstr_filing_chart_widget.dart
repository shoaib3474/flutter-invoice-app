// ignore_for_file: always_put_required_named_parameters_first, avoid_redundant_argument_values, deprecated_member_use, unused_element

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/gstin/gstin_filing_history.dart';
import '../../utils/filing_status_util.dart';
import 'filing_status_indicator_widget.dart';

class GstrFilingChartWidget extends StatelessWidget {
  const GstrFilingChartWidget({
    super.key,
    required this.gstin,
    required this.returnType,
    required this.filingHistory,
  });
  final String gstin;
  final String returnType;
  final GstinFilingHistory filingHistory;

  List<FilingRecord> _getFilingsForType() {
    switch (returnType) {
      case 'GSTR1':
        return filingHistory.records.where((r) => r.status == 'GSTR1').toList();
      case 'GSTR3B':
        return filingHistory.records
            .where((r) => r.status == 'GSTR3B')
            .toList();
      case 'GSTR4':
        return filingHistory.records.where((r) => r.status == 'GSTR4').toList();
      case 'GSTR9':
        return filingHistory.records.where((r) => r.status == 'GSTR9').toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final filings = _getFilingsForType();

    if (filings.isEmpty) {
      return Center(
        child: Text(
          'No filing history available for $returnType',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    // Sort filings by date
    filings.sort((a, b) {
      if (a.filedDate == null && b.filedDate == null) return 0;
      if (a.filedDate == null) return 1;
      if (b.filedDate == null) return -1;
      return (a.filedDate ?? DateTime(1970))
          .compareTo(b.filedDate ?? DateTime(1970));
    });

    // Group filings by month for the chart
    final Map<String, List<FilingRecord>> filingsByMonth = {};
    for (final filing in filings) {
      final monthYear = DateFormat('MMM yyyy').format(filing.filedDate!);
      filingsByMonth[monthYear] = (filingsByMonth[monthYear] ?? [])
        ..add(filing);
    }

    final List<BarChartGroupData> barGroups = [];
    int index = 0;

    // Create a map to store status counts for each month
    final Map<String, Map<FilingStatus, int>> statusCountsByMonth = {};

    filingsByMonth.forEach((month, monthFilings) {
      // Count filings by status
      final statusCounts = <FilingStatus, int>{};
      for (final filing in monthFilings) {
        final status = filing.filingStatus;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      statusCountsByMonth[month] = statusCounts;

      // Create stacked bar for each status
      final List<BarChartRodStackItem> stackItems = [];
      double cumulativeHeight = 0;

      // Order: on time, late, not filed, unknown
      final orderedStatuses = [
        FilingStatus.onTime,
        FilingStatus.late,
        FilingStatus.notFiled,
        FilingStatus.unknown,
      ];

      for (final status in orderedStatuses) {
        final count = statusCounts[status] ?? 0;
        if (count > 0) {
          final color = FilingStatusUtil.getStatusColor(status);
          stackItems.add(
            BarChartRodStackItem(
              cumulativeHeight,
              cumulativeHeight + count,
              color,
            ),
          );
          cumulativeHeight += count;
        }
      }

      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: cumulativeHeight,
              rodStackItems: stackItems,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$returnType Filing History for $gstin',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (filingsByMonth.values.isEmpty
                            ? 1
                            : filingsByMonth.values
                                    .map((filings) => filings.length)
                                    .reduce((a, b) => a > b ? a : b) +
                                1)
                        .toDouble(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < filingsByMonth.keys.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  filingsByMonth.keys.elementAt(value.toInt()),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                    ),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ),

            // Filing Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Filings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filings.length > 5 ? 5 : filings.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final filing = filings[filings.length -
                            1 -
                            index]; // Show most recent first
                        return ListTile(
                          leading: FilingStatusIndicator(
                            status: filing.filingStatus,
                            showIcon: true,
                            size: 16,
                          ),
                          title: Text(
                            'Period: ${filing.returnPeriod}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Filed on: ${filing.filingDate != null ? DateFormat('dd MMM yyyy').format(filing.filingDate!) : 'N/A'}',
                          ),
                          trailing: Text(
                            FilingStatusUtil.getStatusLabel(
                                filing.filingStatus),
                            style: TextStyle(
                              color: FilingStatusUtil.getStatusColor(
                                  filing.filingStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilingInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filing Status Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The chart shows the filing status for each period:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // FilingStatusLegend(horizontal: false),
            const SizedBox(height: 16),
            const Text('Due dates by return type:'),
            const SizedBox(height: 8),
            _buildDueDateInfo('GSTR1', '11th of the following month'),
            _buildDueDateInfo('GSTR3B', '20th of the following month'),
            _buildDueDateInfo('GSTR4', '18th of the month following quarter'),
            _buildDueDateInfo('GSTR9', '31st December of the following year'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateInfo(String returnType, String dueDate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Text(
            returnType,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(': $dueDate'),
        ],
      ),
    );
  }
}

// Calculate due date based on return type and period
DateTime calculateDueDate(String returnType, String returnPeriod) {
  // Example: returnPeriod is '042024' for April 2024
  int month = int.parse(returnPeriod.substring(0, 2));
  int year = int.parse(returnPeriod.substring(2));
  DateTime baseDate = DateTime(year, month);

  switch (returnType) {
    case 'GSTR1':
      // 11th of the following month
      return DateTime(baseDate.year, baseDate.month + 1, 11);
    case 'GSTR3B':
      // 20th of the following month
      return DateTime(baseDate.year, baseDate.month + 1, 20);
    case 'GSTR4':
      // 18th of the month following quarter (assuming quarterly period)
      return DateTime(baseDate.year, baseDate.month + 1, 18);
    case 'GSTR9':
      // 31st December of the following year
      return DateTime(baseDate.year + 1, 12, 31);
    default:
      return baseDate;
  }
}

// Example usage:
// final dueDate = calculateDueDate(filing.returnType, filing.returnPeriod);

// Compare filing date with due date
// if (filing.filingDate.isAfter(dueDate)) {
//   return FilingStatus.late;
// } else {
//   return FilingStatus.onTime;
// }
