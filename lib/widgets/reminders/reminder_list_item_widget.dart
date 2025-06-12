import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminders/filing_reminder_model.dart';

class ReminderListItemWidget extends StatelessWidget {
  final FilingReminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleEnabled;
  
  const ReminderListItemWidget({
    Key? key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = reminder.dueDate.isBefore(now);
    final isDueSoon = !isOverdue && 
        reminder.dueDate.difference(now).inDays <= 7;
    
    Color statusColor = Colors.green;
    if (isOverdue) {
      statusColor = Colors.red;
    } else if (isDueSoon) {
      statusColor = Colors.orange;
    }
    
    return Opacity(
      opacity: reminder.isEnabled ? 1.0 : 0.5,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isOverdue 
                ? Icons.warning 
                : isDueSoon 
                    ? Icons.access_time 
                    : Icons.check_circle,
            color: statusColor,
          ),
        ),
        title: Text(
          '${reminder.returnType} - ${reminder.returnPeriod}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GSTIN: ${reminder.gstin}'),
            Text(
              'Due: ${DateFormat('dd MMM yyyy').format(reminder.dueDate)}',
              style: TextStyle(
                color: isOverdue ? Colors.red : null,
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
            if (reminder.notes != null && reminder.notes!.isNotEmpty)
              Text(
                'Note: ${reminder.notes}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: reminder.isEnabled,
              onChanged: (_) => onToggleEnabled(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Reminder'),
                      content: Text('Are you sure you want to delete this reminder?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDelete();
                          },
                          child: Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: onEdit,
      ),
    );
  }
}
