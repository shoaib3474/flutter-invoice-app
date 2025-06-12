import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/reminders/filing_reminder_model.dart';
import '../../providers/filing_reminder_provider.dart';
import '../../screens/filing_reminders_screen.dart';

class UpcomingRemindersWidget extends StatefulWidget {
  const UpcomingRemindersWidget({Key? key}) : super(key: key);

  @override
  _UpcomingRemindersWidgetState createState() => _UpcomingRemindersWidgetState();
}

class _UpcomingRemindersWidgetState extends State<UpcomingRemindersWidget> {
  bool _isLoading = false;
  List<FilingReminder> _upcomingReminders = [];
  
  @override
  void initState() {
    super.initState();
    _loadUpcomingReminders();
  }
  
  Future<void> _loadUpcomingReminders() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final provider = Provider.of<FilingReminderProvider>(context, listen: false);
      _upcomingReminders = await provider.getUpcomingReminders();
      
      // Sort by due date (ascending)
      _upcomingReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Filing Deadlines',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadUpcomingReminders,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Divider(height: 1),
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_upcomingReminders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No upcoming deadlines',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add reminders to stay on top of your filing schedule',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _upcomingReminders.length > 5 ? 5 : _upcomingReminders.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final reminder = _upcomingReminders[index];
                final now = DateTime.now();
                final daysRemaining = reminder.dueDate.difference(now).inDays;
                
                Color statusColor = Colors.green;
                if (daysRemaining <= 3) {
                  statusColor = Colors.red;
                } else if (daysRemaining <= 7) {
                  statusColor = Colors.orange;
                }
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$daysRemaining',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${reminder.returnType} - ${reminder.returnPeriod}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Due on ${DateFormat('dd MMM yyyy').format(reminder.dueDate)}',
                  ),
                  trailing: Text(
                    daysRemaining == 0 
                        ? 'Today' 
                        : daysRemaining == 1 
                            ? 'Tomorrow' 
                            : '$daysRemaining days left',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FilingRemindersScreen(
                          gstin: reminder.gstin,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          if (_upcomingReminders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: TextButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text('View All Reminders'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FilingRemindersScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
