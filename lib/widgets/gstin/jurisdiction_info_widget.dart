import 'package:flutter/material.dart';
import '../../models/gstin/jurisdiction_model.dart';

class JurisdictionInfoWidget extends StatelessWidget {
  final JurisdictionModel jurisdiction;

  const JurisdictionInfoWidget({
    Key? key,
    required this.jurisdiction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jurisdiction Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Center Jurisdiction', jurisdiction.centerJurisdiction),
            _buildInfoRow('State Jurisdiction', jurisdiction.stateJurisdiction),
            _buildInfoRow('Division', jurisdiction.division),
            _buildInfoRow('Commissionerate', jurisdiction.commissionerate),
            _buildInfoRow('Range', jurisdiction.range),
            _buildInfoRow('Ward', jurisdiction.ward),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
