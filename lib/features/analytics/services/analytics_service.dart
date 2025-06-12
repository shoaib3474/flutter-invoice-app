import 'package:firebase_analytics/firebase_analytics.dart';
import '../../../core/services/error_logger_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  late ErrorLoggerService _errorLogger;
  bool _initialized = false;

  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _errorLogger = ErrorLoggerService();
      _initialized = true;
      
      _errorLogger.logInfo('AnalyticsService initialized successfully');
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Failed to initialize AnalyticsService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Screen tracking
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    if (!_initialized) return;
    
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      
      _errorLogger.addBreadcrumb('Screen viewed: $screenName');
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Failed to log screen view',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'screen_name': screenName, 'screen_class': screenClass},
      );
    }
  }

  // User actions
  Future<void> logUserAction(String action, {Map<String, dynamic>? parameters}) async {
    if (!_initialized) return;
    
    try {
      await _analytics.logEvent(
        name: 'user_action',
        parameters: {
          'action': action,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );
      
      _errorLogger.addBreadcrumb('User action: $action', data: parameters);
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Failed to log user action',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'action': action, 'parameters': parameters},
      );
    }
  }

  // Business events
  Future<void> logInvoiceCreated(String invoiceId, double amount) async {
    await logUserAction('invoice_created', parameters: {
      'invoice_id': invoiceId,
      'amount': amount,
    });
  }

  Future<void> logGSTReturnFiled(String returnType, String period) async {
    await logUserAction('gst_return_filed', parameters: {
      'return_type': returnType,
      'period': period,
    });
  }

  Future<void> logPaymentProcessed(String paymentId, double amount, String method) async {
    await logUserAction('payment_processed', parameters: {
      'payment_id': paymentId,
      'amount': amount,
      'method': method,
    });
  }

  // Error tracking
  Future<void> logError(String errorType, String errorMessage) async {
    if (!_initialized) return;
    
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Failed to log error to analytics',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'error_type': errorType, 'error_message': errorMessage},
      );
    }
  }

  // User properties
  Future<void> setUserId(String userId) async {
    if (!_initialized) return;
    
    try {
      await _analytics.setUserId(id: userId);
      _errorLogger.logInfo('Analytics user ID set: $userId');
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Failed to set analytics user ID',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'user_id': userId},
      );
    }
  }

  Future<void> setUserProperty(String name, String value) async {
    if (!_initialized) return;
    
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _errorLogger.addBreadcrumb('User property set: $name = $value');
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Failed to set user property',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'property_name': name, 'property_value': value},
      );
    }
  }
}
