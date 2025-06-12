import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FilingStatusChartWidget extends StatelessWidget {
  final Map<String, dynamic> filingStatusData;
  
  const FilingStatusChartWidget({
    Key? key,
    required this.filingStatusData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filed = filingStatusData['filed'] ?? 0;
    final pending = filingStatusData['pending'] ?? 0;
    final overdue = filingStatusData['overdue'] ?? 0;
    final total = filed + pending + overdue;
    
    if (total == 0) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No filing data available',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: filed.toDouble(),
                      title: '${(filed / total * 100).round()}%',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: pending.toDouble(),
                      title: '${(pending / total * 100).round()}%',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: overdue.toDouble(),
                      title: '${(overdue / total * 100).round()}%',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem('Filed', filed, Colors.green),
                _buildStatusItem('Pending', pending, Colors.orange),
                _buildStatusItem('Overdue', overdue, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
          ),
        ),
      ],
    );
  }
}
