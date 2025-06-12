import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminders/filing_reminder_model.dart';

class ReminderAlertListWidget extends StatefulWidget {
  final List<ReminderAlert> alerts;
  final DateTime dueDate;
  final Function(List<ReminderAlert>) onAlertsChanged;
  
  const ReminderAlertListWidget({
    super.key,
    required this.alerts,
    required this.dueDate,
    required this.onAlertsChanged,
  });

  @override
  _ReminderAlertListWidgetState createState() => _ReminderAlertListWidgetState();
}

class _ReminderAlertListWidgetState extends State<ReminderAlertListWidget> {
  late List<ReminderAlert> _alerts;
  
  @override
  void initState() {
    super.initState();
    _alerts = List.from(widget.alerts);
  }
  
  @override
  void didUpdateWidget(ReminderAlertListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alerts != widget.alerts) {
      _alerts = List.from(widget.alerts);
    }
  }
  
  void _addAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select how many days before the due date:'),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 2, 3, 5, 7, 10, 14, 30].map((days) {
                return ActionChip(
                  label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                  onPressed: () {
                    final scheduledDate = widget.dueDate.subtract(Duration(days: days));
                    final newAlert = ReminderAlert(
                      daysBeforeDue: days,
                      scheduledDate: scheduledDate,
                    );
                    
                    setState(() {
                      _alerts.add(newAlert);
                      _alerts.sort((a, b) => b.daysBeforeDue.compareTo(a.daysBeforeDue));
                    });
                    
                    widget.onAlertsChanged(_alerts);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _removeAlert(int index) {
    setState(() {
      _alerts.removeAt(index);
    });
    
    widget.onAlertsChanged(_alerts);
  }
  
  void _toggleAlertEnabled(int index) {
    setState(() {
      final alert = _alerts[index];
      _alerts[index] = alert.copyWith(isEnabled: !alert.isEnabled);
    });
    
    widget.onAlertsChanged(_alerts);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_alerts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No alerts configured',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _alerts.length,
            itemBuilder: (context, index) {
              final alert = _alerts[index];
              final scheduledDate = widget.dueDate.subtract(Duration(days: alert.daysBeforeDue));
              
              return ListTile(
                leading: Checkbox(
                  value: alert.isEnabled,
                  onChanged: (_) => _toggleAlertEnabled(index),
                ),
                title: Text(
                  '${alert.daysBeforeDue} ${alert.daysBeforeDue == 1 ? 'day' : 'days'} before due date',
                ),
                subtitle: Text(
                  'On ${DateFormat('dd MMM yyyy').format(scheduledDate)}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeAlert(index),
                ),
              );
            },
          ),
        SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add Alert'),
            onPressed: _addAlert,
          ),
        ),
      ],
    );
  }
}
