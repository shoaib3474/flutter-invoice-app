import 'package:flutter/material.dart';

class GstReturnsDashboard extends StatelessWidget {
  const GstReturnsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GST Returns Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Returns status grid
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatusCard(
                  context,
                  'GSTR-1',
                  'Monthly',
                  'Filed',
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatusCard(
                  context,
                  'GSTR-3B',
                  'Monthly',
                  'Pending',
                  Colors.orange,
                  Icons.warning,
                ),
                _buildStatusCard(
                  context,
                  'GSTR-9',
                  'Annual',
                  'Not Due',
                  Colors.blue,
                  Icons.info,
                ),
                _buildStatusCard(
                  context,
                  'GSTR-9C',
                  'Annual',
                  'Not Due',
                  Colors.blue,
                  Icons.info,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Due dates section
            Text(
              'Upcoming Due Dates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Due dates list
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDueDateItem(
                  context,
                  'GSTR-1',
                  'April 2023',
                  '11 May 2023',
                  isDue: true,
                ),
                _buildDueDateItem(
                  context,
                  'GSTR-3B',
                  'April 2023',
                  '20 May 2023',
                  isDue: false,
                ),
                _buildDueDateItem(
                  context,
                  'GSTR-9',
                  'FY 2022-23',
                  '31 Dec 2023',
                  isDue: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard(
    BuildContext context,
    String returnType,
    String frequency,
    String status,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            returnType,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            frequency,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDueDateItem(
    BuildContext context,
    String returnType,
    String period,
    String dueDate, {
    required bool isDue,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDue ? Colors.red.shade100 : Colors.blue.shade100,
        child: Icon(
          isDue ? Icons.event_busy : Icons.event,
          color: isDue ? Colors.red : Colors.blue,
        ),
      ),
      title: Text(returnType),
      subtitle: Text(period),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            dueDate,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDue ? Colors.red : null,
            ),
          ),
          Text(
            isDue ? 'Due Soon' : 'Upcoming',
            style: TextStyle(
              fontSize: 12,
              color: isDue ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
