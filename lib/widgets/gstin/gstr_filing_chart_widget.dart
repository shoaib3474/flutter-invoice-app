import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/gstin/gstin_filing_history.dart';
import '../../utils/filing_status_util.dart';
import 'filing_status_indicator_widget.dart';
import 'filing_status_legend_widget.dart';

class GstrFilingChartWidget extends StatelessWidget {
  final String gstin;
  final String returnType;
  final GstinFilingHistory filingHistory;

  const GstrFilingChartWidget({
    super.key,
    required this.gstin,
    required this.returnType,
    required this.filingHistory,
  });

  List<GstrFiling> _getFilingsForType() {
    switch (returnType) {
      case 'GSTR1':
        return filingHistory.gstr1Filings;
      case 'GSTR3B':
        return filingHistory.gstr3bFilings;
      case 'GSTR4':
        return filingHistory.gstr4Filings;
      case 'GSTR9':
        return filingHistory.gstr9Filings;
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
    filings.sort((a, b) => a.filingDate.compareTo(b.filingDate));
    
    // Group filings by month for the chart
    final Map<String, List<GstrFiling>> filingsByMonth = {};
    for (var filing in filings) {
      final monthYear = DateFormat('MMM yyyy').format(filing.filingDate);
      filingsByMonth[monthYear] = (filingsByMonth[monthYear] ?? [])..add(filing);
    }

    final List<BarChartGroupData> barGroups = [];
    int index = 0;
    
    // Create a map to store status counts for each month
    final Map<String, Map<FilingStatus, int>> statusCountsByMonth = {};
    
    filingsByMonth.forEach((month, monthFilings) {
      // Count filings by status
      final statusCounts = <FilingStatus, int>{};
      for (var filing in monthFilings) {
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
      
      for (var status in orderedStatuses) {
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
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (filingsByMonth.values.isEmpty 
                      ? 1 
                      : filingsByMonth.values
                          .map((filings) => filings.length)
                          .reduce((a, b) => a > b ? a : b) + 1
                    ).toDouble(),
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
                            if (value.toInt() >= 0 && value.toInt() < filingsByMonth.keys.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
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
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Filings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filings.length > 5 ? 5 : filings.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final filing = filings[filings.length - 1 - index]; // Show most recent first
                        return ListTile(
                          leading: FilingStatusIndicator(
                            status: filing.filingStatus,
                            showIcon: true,
                            size: 16,
                          ),
                          title: Text(
                            'Period: ${filing.returnPeriod}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Filed on: ${DateFormat('dd MMM yyyy').format(filing.filingDate)}',
                          ),
                          trailing: Text(
                            FilingStatusUtil.getStatusLabel(filing.filingStatus),
                            style: TextStyle(
                              color: FilingStatusUtil.getStatusColor(filing.filingStatus),
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
        title: Text('Filing Status Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The chart shows the filing status for each period:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FilingStatusLegend(horizontal: false),
            SizedBox(height: 16),
            Text('Due dates by return type:'),
            SizedBox(height: 8),
            _buildDueDateInfo('GSTR1', '11th of the following month'),
            _buildDueDateInfo('GSTR3B', '20th of the following month'),
            _buildDueDateInfo('GSTR4', '18th of the month following quarter'),
            _buildDueDateInfo('GSTR9', '31st December of the following year'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDueDateInfo(String returnType, String dueDate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• '),
          Text(
            returnType,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(': $dueDate'),
        ],
      ),
    );
  }
}
