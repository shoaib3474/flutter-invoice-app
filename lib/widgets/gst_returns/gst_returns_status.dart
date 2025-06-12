import 'package:flutter/material.dart';
import 'package:path/path.dart';

class GstReturnsStatus extends StatelessWidget {
  const GstReturnsStatus({
    required this.returnType,
    required this.period,
    required this.financialYear,
    required this.status,
    super.key,
    this.acknowledgementNumber,
    this.filedDate,
  });

  final String returnType;
  final String period;
  final String financialYear;
  final String status;
  final String? acknowledgementNumber;
  final String? filedDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Return Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Return details
            _buildInfoRow('Return Type', returnType),
            _buildInfoRow('Period', period),
            _buildInfoRow('Financial Year', financialYear),
            _buildInfoRow('Status', status, isStatus: true),

            if (acknowledgementNumber != null)
              _buildInfoRow('Acknowledgement', acknowledgementNumber!),

            if (filedDate != null) _buildInfoRow('Filed Date', filedDate!),

            const SizedBox(height: 16),

            // Status timeline
            _buildStatusTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info;

    if (isStatus) {
      switch (value.toUpperCase()) {
        case 'FILED':
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
          break;
        case 'PREPARED':
          statusColor = Colors.blue;
          statusIcon = Icons.assignment_turned_in;
          break;
        case 'FETCHED':
          statusColor = Colors.orange;
          statusIcon = Icons.download_done;
          break;
        case 'PENDING':
          statusColor = Colors.red;
          statusIcon = Icons.warning;
          break;
        default:
          statusColor = Colors.grey;
          statusIcon = Icons.info;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context) {
    final statusIndex = _getStatusIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTimelineStep(
              context,
              'Fetch Data',
              Icons.download,
              isCompleted: statusIndex >= 1,
              isFirst: true,
            ),
            _buildTimelineConnector(isCompleted: statusIndex >= 2),
            _buildTimelineStep(
              context,
              'Prepare Return',
              Icons.assignment,
              isCompleted: statusIndex >= 2,
            ),
            _buildTimelineConnector(isCompleted: statusIndex >= 3),
            _buildTimelineStep(
              context,
              'File Return',
              Icons.upload_file,
              isCompleted: statusIndex >= 3,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
    BuildContext context,
    String label,
    IconData icon, {
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isCompleted
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector({required bool isCompleted}) {
    return Container(
      width: 40,
      height: 2,
      color: isCompleted
          ? Theme.of(context as BuildContext).primaryColor
          : Colors.grey.shade300,
    );
  }

  int _getStatusIndex() {
    switch (status.toUpperCase()) {
      case 'FILED':
        return 3;
      case 'PREPARED':
        return 2;
      case 'FETCHED':
        return 1;
      default:
        return 0;
    }
  }
}
