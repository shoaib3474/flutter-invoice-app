import 'package:flutter/material.dart';

class FilingStatusLegendWidget extends StatelessWidget {
  const FilingStatusLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filing Status Legend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendItem(Colors.green, 'Filed on Time'),
            _buildLegendItem(Colors.orange, 'Filed Late'),
            _buildLegendItem(Colors.red, 'Not Filed'),
            _buildLegendItem(Colors.blue, 'Nil Return'),
            _buildLegendItem(Colors.grey, 'No Data'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
