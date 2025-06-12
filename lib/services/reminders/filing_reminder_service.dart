import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/reminders/filing_reminder_model.dart';

// This service uses only shared_preferences which is a core Flutter dependency
class FilingReminderService {
  static const String _storageKey = 'filing_reminders';
  
  // Get all filing reminders
  Future<List<FilingReminder>> getAllReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? remindersJson = prefs.getString(_storageKey);
      
      if (remindersJson == null) {
        return [];
      }
      
      final List<dynamic> decodedList = json.decode(remindersJson);
      return decodedList
          .map((item) => FilingReminder.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting reminders: $e');
      return [];
    }
  }
  
  // Save all reminders
  Future<bool> saveReminders(List<FilingReminder> reminders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(
        reminders.map((reminder) => reminder.toMap()).toList()
      );
      
      return await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
      return false;
    }
  }
  
  // Add a new reminder
  Future<bool> addReminder(FilingReminder reminder) async {
    try {
      final reminders = await getAllReminders();
      reminders.add(reminder);
      return await saveReminders(reminders);
    } catch (e) {
      debugPrint('Error adding reminder: $e');
      return false;
    }
  }
  
  // Update an existing reminder
  Future<bool> updateReminder(FilingReminder updatedReminder) async {
    try {
      final reminders = await getAllReminders();
      final index = reminders.indexWhere((r) => r.id == updatedReminder.id);
      
      if (index == -1) {
        return false;
      }
      
      reminders[index] = updatedReminder;
      return await saveReminders(reminders);
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      return false;
    }
  }
  
  // Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final reminders = await getAllReminders();
      final filteredReminders = reminders.where((r) => r.id != reminderId).toList();
      
      if (reminders.length == filteredReminders.length) {
        return false;
      }
      
      return await saveReminders(filteredReminders);
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      return false;
    }
  }
  
  // Get reminders for a specific GSTIN
  Future<List<FilingReminder>> getRemindersForGstin(String gstin) async {
    final reminders = await getAllReminders();
    return reminders.where((r) => r.gstin == gstin).toList();
  }
  
  // Get upcoming reminders (due within the next 30 days)
  Future<List<FilingReminder>> getUpcomingReminders() async {
    final reminders = await getAllReminders();
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));
    
    return reminders.where((r) => 
      r.isEnabled && 
      r.dueDate.isAfter(now) && 
      r.dueDate.isBefore(thirtyDaysLater)
    ).toList();
  }
  
  // Generate default alerts for a due date
  List<ReminderAlert> generateDefaultAlerts(DateTime dueDate) {
    return [
      ReminderAlert.fromDaysBeforeDue(1, dueDate),   // 1 day before
      ReminderAlert.fromDaysBeforeDue(3, dueDate),   // 3 days before
      ReminderAlert.fromDaysBeforeDue(7, dueDate),   // 1 week before
    ];
  }
  
  // Calculate the due date for a GST return
  DateTime calculateDueDate(String returnType, String period) {
    // Parse period (format: MM-YYYY for monthly, Q1-YYYY for quarterly)
    DateTime dueDate;
    
    if (period.startsWith('Q')) {
      // Quarterly return
      final quarter = int.parse(period.substring(1, 2));
      final year = int.parse(period.substring(3));
      
      switch (returnType) {
        case 'GSTR4':
          // Due on 18th of the month following the quarter
          final month = quarter * 3;
          dueDate = DateTime(year, month + 1, 18);
          break;
        case 'GSTR9':
        case 'GSTR9C':
          // Due on 31st December of the following year
          dueDate = DateTime(year + 1, 12, 31);
          break;
        default:
          // Default to end of next month
          final month = quarter * 3;
          dueDate = DateTime(year, month + 1, 20);
      }
    } else {
      // Monthly return
      final parts = period.split('-');
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      
      switch (returnType) {
        case 'GSTR1':
          // Due on 11th of the following month
          dueDate = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 11);
          break;
        case 'GSTR3B':
          // Due on 20th of the following month
          dueDate = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 20);
          break;
        default:
          // Default to end of next month
          dueDate = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 20);
      }
    }
    
    return dueDate;
  }
}
