import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_invoice_app/utils/number_formatter.dart';

class TaxLiabilityChartWidget extends StatelessWidget {
  final List<dynamic> taxLiabilityData;
  
  const TaxLiabilityChartWidget({
    Key? key,
    required this.taxLiabilityData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (taxLiabilityData.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No tax liability data available',
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
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= taxLiabilityData.length) {
                            return const Text('');
                          }
                          return Text(
                            taxLiabilityData[value.toInt()]['month'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculateInterval(),
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${NumberFormatter.formatCompact(value)}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: 0,
                  maxX: taxLiabilityData.length.toDouble() - 1,
                  minY: 0,
                  maxY: _calculateMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _createSpots(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Tax Liability'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  List<FlSpot> _createSpots() {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < taxLiabilityData.length; i++) {
      final amount = taxLiabilityData[i]['amount']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), amount));
    }
    
    return spots;
  }
  
  double _calculateMaxY() {
    double maxY = 0;
    
    for (final data in taxLiabilityData) {
      final amount = data['amount']?.toDouble() ?? 0.0;
      if (amount > maxY) {
        maxY = amount;
      }
    }
    
    // Add some padding to the top
    return maxY * 1.2;
  }
  
  double _calculateInterval() {
    final maxY = _calculateMaxY();
    
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    if (maxY <= 50000) return 10000;
    if (maxY <= 100000) return 20000;
    if (maxY <= 500000) return 100000;
    
    return 200000;
  }
}
