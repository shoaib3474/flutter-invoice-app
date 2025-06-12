import 'package:flutter/foundation.dart';
import '../models/reminders/filing_reminder_model.dart';
import '../services/reminders/filing_reminder_service.dart';

class FilingReminderProvider with ChangeNotifier {
  final FilingReminderService _reminderService = FilingReminderService();
  List<FilingReminder> _reminders = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  List<FilingReminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Load all reminders
  Future<void> loadReminders() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _reminders = await _reminderService.getAllReminders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load reminders: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Add a new reminder
  Future<bool> addReminder(FilingReminder reminder) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _reminderService.addReminder(reminder);
      if (result) {
        _reminders.add(reminder);
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add reminder: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update an existing reminder
  Future<bool> updateReminder(FilingReminder updatedReminder) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _reminderService.updateReminder(updatedReminder);
      if (result) {
        final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
        if (index != -1) {
          _reminders[index] = updatedReminder;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update reminder: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _reminderService.deleteReminder(reminderId);
      if (result) {
        _reminders.removeWhere((r) => r.id == reminderId);
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete reminder: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Get upcoming reminders
  Future<List<FilingReminder>> getUpcomingReminders() async {
    try {
      return await _reminderService.getUpcomingReminders();
    } catch (e) {
      _errorMessage = 'Failed to get upcoming reminders: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  // Get reminders for a specific GSTIN
  Future<List<FilingReminder>> getRemindersForGstin(String gstin) async {
    try {
      return await _reminderService.getRemindersForGstin(gstin);
    } catch (e) {
      _errorMessage = 'Failed to get reminders for GSTIN: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  // Generate default alerts for a due date
  List<ReminderAlert> generateDefaultAlerts(DateTime dueDate) {
    return _reminderService.generateDefaultAlerts(dueDate);
  }
  
  // Calculate the due date for a GST return
  DateTime calculateDueDate(String returnType, String period) {
    return _reminderService.calculateDueDate(returnType, period);
  }
  
  // Reset error message
  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
}
