import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reminders/filing_reminder_model.dart';
import '../providers/filing_reminder_provider.dart';

class FilingRemindersScreen extends StatefulWidget {
  final String? gstin;
  
  const FilingRemindersScreen({
    Key? key,
    this.gstin,
  }) : super(key: key);

  @override
  _FilingRemindersScreenState createState() => _FilingRemindersScreenState();
}

class _FilingRemindersScreenState extends State<FilingRemindersScreen> {
  bool _isLoading = false;
  List<FilingReminder> _reminders = [];
  
  @override
  void initState() {
    super.initState();
    _loadReminders();
  }
  
  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });
    
    final provider = Provider.of<FilingReminderProvider>(context, listen: false);
    
    try {
      if (widget.gstin != null) {
        _reminders = await provider.getRemindersForGstin(widget.gstin!);
      } else {
        await provider.loadReminders();
        _reminders = provider.reminders;
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReminderFormDialog(
        gstin: widget.gstin,
        onSave: (reminder) async {
          final provider = Provider.of<FilingReminderProvider>(context, listen: false);
          final result = await provider.addReminder(reminder);
          
          if (result) {
            _loadReminders();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reminder added successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add reminder: ${provider.errorMessage}')),
            );
          }
        },
      ),
    );
  }
  
  void _showEditReminderDialog(FilingReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => _ReminderFormDialog(
        reminder: reminder,
        onSave: (updatedReminder) async {
          final provider = Provider.of<FilingReminderProvider>(context, listen: false);
          final result = await provider.updateReminder(updatedReminder);
          
          if (result) {
            _loadReminders();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reminder updated successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update reminder: ${provider.errorMessage}')),
            );
          }
        },
      ),
    );
  }
  
  Future<void> _deleteReminder(String reminderId) async {
    final provider = Provider.of<FilingReminderProvider>(context, listen: false);
    final result = await provider.deleteReminder(reminderId);
    
    if (result) {
      _loadReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reminder: ${provider.errorMessage}')),
      );
    }
  }
  
  Future<void> _toggleReminderEnabled(FilingReminder reminder) async {
    final provider = Provider.of<FilingReminderProvider>(context, listen: false);
    final updatedReminder = reminder.copyWith(isEnabled: !reminder.isEnabled);
    
    final result = await provider.updateReminder(updatedReminder);
    
    if (result) {
      _loadReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedReminder.isEnabled 
                ? 'Reminder enabled' 
                : 'Reminder disabled'
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reminder: ${provider.errorMessage}')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gstin != null 
            ? 'Reminders for ${widget.gstin}' 
            : 'Filing Reminders'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReminders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No reminders found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a reminder',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _reminders.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return _ReminderListItem(
                      reminder: reminder,
                      onEdit: () => _showEditReminderDialog(reminder),
                      onDelete: () => _deleteReminder(reminder.id),
                      onToggleEnabled: () => _toggleReminderEnabled(reminder),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Reminder',
      ),
    );
  }
}

// Simple reminder list item widget
class _ReminderListItem extends StatelessWidget {
  final FilingReminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleEnabled;
  
  const _ReminderListItem({
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

// Simple reminder form dialog
class _ReminderFormDialog extends StatefulWidget {
  final FilingReminder? reminder;
  final String? gstin;
  final Function(FilingReminder) onSave;
  
  const _ReminderFormDialog({
    Key? key,
    this.reminder,
    this.gstin,
    required this.onSave,
  }) : super(key: key);

  @override
  _ReminderFormDialogState createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _gstinController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _returnType = 'GSTR1';
  String _returnPeriod = '';
  DateTime _dueDate = DateTime.now().add(Duration(days: 7));
  List<ReminderAlert> _alerts = [];
  bool _isEnabled = true;
  
  final List<String> _returnTypes = [
    'GSTR1',
    'GSTR3B',
    'GSTR4',
    'GSTR9',
    'GSTR9C',
  ];
  
  @override
  void initState() {
    super.initState();
    
    if (widget.reminder != null) {
      _gstinController.text = widget.reminder!.gstin;
      _returnType = widget.reminder!.returnType;
      _returnPeriod = widget.reminder!.returnPeriod;
      _dueDate = widget.reminder!.dueDate;
      _alerts = List.from(widget.reminder!.alerts);
      _isEnabled = widget.reminder!.isEnabled;
      _notesController.text = widget.reminder!.notes ?? '';
    } else if (widget.gstin != null) {
      _gstinController.text = widget.gstin!;
    }
    
    if (_alerts.isEmpty) {
      _generateDefaultAlerts();
    }
    
    _generateReturnPeriod();
  }
  
  @override
  void dispose() {
    _gstinController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _generateDefaultAlerts() {
    final provider = Provider.of<FilingReminderProvider>(context, listen: false);
    _alerts = provider.generateDefaultAlerts(_dueDate);
  }
  
  void _generateReturnPeriod() {
    final now = DateTime.now();
    
    if (_returnType == 'GSTR4') {
      // Quarterly return
      final quarter = (now.month - 1) ~/ 3 + 1;
      _returnPeriod = 'Q$quarter-${now.year}';
    } else if (_returnType == 'GSTR9' || _returnType == 'GSTR9C') {
      // Annual return
      _returnPeriod = 'FY-${now.year - 1}';
    } else {
      // Monthly return
      _returnPeriod = '${now.month.toString().padLeft(2, '0')}-${now.year}';
    }
    
    _updateDueDate();
  }
  
  void _updateDueDate() {
    final provider = Provider.of<FilingReminderProvider>(context, listen: false);
    _dueDate = provider.calculateDueDate(_returnType, _returnPeriod);
    _generateDefaultAlerts();
  }
  
  void _saveReminder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final reminder = FilingReminder(
      id: widget.reminder?.id,
      gstin: _gstinController.text,
      returnType: _returnType,
      returnPeriod: _returnPeriod,
      dueDate: _dueDate,
      alerts: _alerts,
      isEnabled: _isEnabled,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
    
    widget.onSave(reminder);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder != null ? 'Edit Reminder' : 'Add Reminder'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GSTIN
              TextFormField(
                controller: _gstinController,
                decoration: InputDecoration(
                  labelText: 'GSTIN *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter GSTIN';
                  }
                  return null;
                },
                enabled: widget.gstin == null,
              ),
              SizedBox(height: 16),
              
              // Return Type
              DropdownButtonFormField<String>(
                value: _returnType,
                decoration: InputDecoration(
                  labelText: 'Return Type *',
                  border: OutlineInputBorder(),
                ),
                items: _returnTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _returnType = value;
                      _generateReturnPeriod();
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              
              // Return Period
              TextFormField(
                initialValue: _returnPeriod,
                decoration: InputDecoration(
                  labelText: 'Return Period *',
                  hintText: 'MM-YYYY or Q1-YYYY',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter return period';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _returnPeriod = value;
                    _updateDueDate();
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Due Date (simplified)
              ListTile(
                title: Text('Due Date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_dueDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  
                  if (date != null) {
                    setState(() {
                      _dueDate = date;
                      _generateDefaultAlerts();
                    });
                  }
                },
              ),
              
              // Enabled Switch
              SwitchListTile(
                title: Text('Enable Reminder'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveReminder,
          child: Text('Save'),
        ),
      ],
    );
  }
}
