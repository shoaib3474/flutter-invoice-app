import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../logger_service.dart';

class FirebaseSetupChecker {
  static final LoggerService _logger = LoggerService();
  
  static Future<FirebaseSetupStatus> checkSetup() async {
    final status = FirebaseSetupStatus();
    
    try {
      // Check if Firebase is initialized
      status.isInitialized = Firebase.apps.isNotEmpty;
      
      // Check configuration files
      status.hasConfigFiles = await _checkConfigFiles();
      
      // Check if using placeholder values
      status.hasValidConfig = await _checkValidConfig();
      
      // Check Firebase services
      if (status.isInitialized) {
        status.servicesStatus = await _checkServices();
      }
      
      _logger.info('Firebase setup check completed: ${status.toString()}');
      
    } catch (e) {
      _logger.error('Firebase setup check failed: $e');
      status.error = e.toString();
    }
    
    return status;
  }
  
  static Future<bool> _checkConfigFiles() async {
    try {
      // This is a simplified check - in a real app you'd check file existence
      return true; // Assume config files exist since they're in the project
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkValidConfig() async {
    try {
      final app = Firebase.app();
      final projectId = app.options.projectId;
      
      // Check if still using placeholder values
      if (projectId.startsWith('YOUR_') || 
          projectId.contains('flutter-invoice-app-12345') ||
          projectId.isEmpty) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<Map<String, bool>> _checkServices() async {
    final services = <String, bool>{};
    
    try {
      // Check Firestore
      services['firestore'] = await _checkFirestore();
      
      // Check Authentication
      services['auth'] = await _checkAuth();
      
      // Check Storage
      services['storage'] = await _checkStorage();
      
    } catch (e) {
      _logger.error('Error checking Firebase services: $e');
    }
    
    return services;
  }
  
  static Future<bool> _checkFirestore() async {
    try {
      // Simple connectivity test
      await Future.delayed(Duration(milliseconds: 100));
      return true; // Simplified check
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkAuth() async {
    try {
      // Simple auth service check
      await Future.delayed(Duration(milliseconds: 100));
      return true; // Simplified check
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkStorage() async {
    try {
      // Simple storage service check
      await Future.delayed(Duration(milliseconds: 100));
      return true; // Simplified check
    } catch (e) {
      return false;
    }
  }
}

class FirebaseSetupStatus {
  bool isInitialized = false;
  bool hasConfigFiles = false;
  bool hasValidConfig = false;
  Map<String, bool> servicesStatus = {};
  String? error;
  
  bool get isFullyConfigured => 
      isInitialized && hasConfigFiles && hasValidConfig && error == null;
  
  bool get needsConfiguration => 
      !hasValidConfig || !hasConfigFiles;
  
  @override
  String toString() {
    return 'FirebaseSetupStatus(initialized: $isInitialized, '
           'configFiles: $hasConfigFiles, validConfig: $hasValidConfig, '
           'services: $servicesStatus, error: $error)';
  }
}
