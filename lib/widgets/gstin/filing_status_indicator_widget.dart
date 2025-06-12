import 'package:flutter/material.dart';
import '../../utils/filing_status_util.dart';

class FilingStatusIndicator extends StatelessWidget {
  const FilingStatusIndicator({
    required this.status,
    Key? key,
    this.size = 12.0,
    this.showLabel = false,
    this.showIcon = false,
  }) : super(key: key);
  final FilingStatus status;
  final double size;
  final bool showLabel;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final color = FilingStatusUtil.getStatusColor(status);
    final label = FilingStatusUtil.getStatusLabel(status);
    final icon = FilingStatusUtil.getStatusIcon(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon)
          Icon(
            icon,
            color: color,
            size: size * 1.5,
          )
        else
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: size * 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
