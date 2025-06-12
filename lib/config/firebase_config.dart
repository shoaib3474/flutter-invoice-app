import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/firebase_options.dart';
import 'package:flutter_invoice_app/services/logger_service.dart';

class FirebaseConfig {
  static final LoggerService _logger = LoggerService();
  static bool _initialized = false;
  
  static bool get isInitialized => _initialized;
  
  static Future<void> initialize() async {
    try {
      if (_initialized) {
        _logger.info('Firebase already initialized');
        return;
      }
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _initialized = true;
      _logger.info('Firebase initialized successfully');
      
      // Enable offline persistence for Firestore
      if (!kIsWeb) {
        // Configure Firestore settings
        // FirebaseFirestore.instance.settings = const Settings(
        //   persistenceEnabled: true,
        //   cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        // );
      }
      
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize Firebase: $e\n$stackTrace');
      rethrow;
    }
  }
  
  static Future<void> configureForTesting() async {
    try {
      // Configure Firebase for testing environment
      if (kDebugMode) {
        _logger.info('Configuring Firebase for testing');
        // Add any test-specific configurations here
      }
    } catch (e) {
      _logger.error('Failed to configure Firebase for testing: $e');
    }
  }
}
