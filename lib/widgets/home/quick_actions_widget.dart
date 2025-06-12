import 'package:flutter/material.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  context,
                  'New Invoice',
                  Icons.receipt,
                  () => Navigator.pushNamed(context, '/invoice/new'),
                ),
                _buildActionButton(
                  context,
                  'GSTR-1',
                  Icons.description,
                  () => Navigator.pushNamed(context, '/gstr1'),
                ),
                _buildActionButton(
                  context,
                  'GSTR-3B',
                  Icons.description,
                  () => Navigator.pushNamed(context, '/gstr3b'),
                ),
                _buildActionButton(
                  context,
                  'GSTR-9',
                  Icons.description,
                  () => Navigator.pushNamed(context, '/gstr9'),
                ),
                _buildActionButton(
                  context,
                  'GSTR-9C',
                  Icons.description,
                  () => Navigator.pushNamed(context, '/gstr9c'),
                ),
                _buildActionButton(
                  context,
                  'Database Test',
                  Icons.storage,
                  () => Navigator.pushNamed(context, '/database_test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
