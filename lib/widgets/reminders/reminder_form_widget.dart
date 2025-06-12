import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/reminders/filing_reminder_model.dart';
import '../../providers/filing_reminder_provider.dart';
import '../pickers/date_picker_widget.dart';
import 'reminder_alert_list_widget.dart';

class ReminderFormWidget extends StatefulWidget {
  final FilingReminder? reminder;
  final String? gstin;
  final Function(FilingReminder) onSave;
  
  const ReminderFormWidget({
    Key? key,
    this.reminder,
    this.gstin,
    required this.onSave,
  }) : super(key: key);

  @override
  _ReminderFormWidgetState createState() => _ReminderFormWidgetState();
}

class _ReminderFormWidgetState extends State<ReminderFormWidget> {
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
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.reminder != null ? 'Edit Reminder' : 'Add Reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              
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
              
              // Due Date
              DatePickerWidget(
                labelText: 'Due Date *',
                initialDate: _dueDate,
                onDateSelected: (date) {
                  setState(() {
                    _dueDate = date;
                    _generateDefaultAlerts();
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Reminder Alerts
              Text(
                'Reminder Alerts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              ReminderAlertListWidget(
                alerts: _alerts,
                dueDate: _dueDate,
                onAlertsChanged: (alerts) {
                  setState(() {
                    _alerts = alerts;
                  });
                },
              ),
              SizedBox(height: 16),
              
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
              SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveReminder,
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
