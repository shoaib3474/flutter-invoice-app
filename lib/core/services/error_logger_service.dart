import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class ErrorLoggerService {
  static final ErrorLoggerService _instance = ErrorLoggerService._internal();
  factory ErrorLoggerService() => _instance;
  ErrorLoggerService._internal();

  late Logger _logger;
  late File _logFile;
  bool _initialized = false;

  // Device and app info
  String? _deviceInfo;
  String? _appVersion;
  String? _buildNumber;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize logger
      await _initializeLogger();

      // Collect device and app info
      await _collectDeviceInfo();
      await _collectAppInfo();

      // Set up global error handling
      _setupGlobalErrorHandling();

      _initialized = true;
      logInfo('ErrorLoggerService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize ErrorLoggerService: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> _initializeLogger() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String logDirPath = '${appDocDir.path}/logs';
      final Directory logDir = Directory(logDirPath);

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Create log file with timestamp
      final String timestamp = DateTime.now().toIso8601String().split('T')[0];
      _logFile = File('$logDirPath/app_log_$timestamp.log');

      // Configure logger
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 3,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: MultiOutput([
          ConsoleOutput(),
          FileOutput(_logFile),
        ]),
        level: kDebugMode ? Level.debug : Level.info,
      );
    } catch (e) {
      // Fallback to console-only logger
      _logger = Logger(
        printer: PrettyPrinter(),
        output: ConsoleOutput(),
      );
      debugPrint('Failed to initialize file logging: $e');
    }
  }

  Future<void> _collectDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = 'Android ${androidInfo.version.release} '
            '(API ${androidInfo.version.sdkInt}) - '
            '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = 'iOS ${iosInfo.systemVersion} - ${iosInfo.model}';
      }
    } catch (e) {
      _deviceInfo = 'Unknown device';
      debugPrint('Failed to collect device info: $e');
    }
  }

  Future<void> _collectAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } catch (e) {
      debugPrint('Failed to collect app info: $e');
    }
  }

  void _setupGlobalErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      logError(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
        additionalData: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
    };

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(
        'Platform Error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }

  // Public logging methods
  void logDebug(String message, {Map<String, dynamic>? additionalData}) {
    _log(LogLevel.debug, message, additionalData: additionalData);
  }

  void logInfo(String message, {Map<String, dynamic>? additionalData}) {
    _log(LogLevel.info, message, additionalData: additionalData);
  }

  void logWarning(String message, {Map<String, dynamic>? additionalData}) {
    _log(LogLevel.warning, message, additionalData: additionalData);
  }

  void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    _log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );
  }

  void logCritical(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    _log(
      LogLevel.critical,
      message,
      error: error,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    if (!_initialized) {
      debugPrint('ErrorLoggerService not initialized: $message');
      return;
    }

    // Create enriched log data
    final Map<String, dynamic> logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'message': message,
      'device_info': _deviceInfo,
      'app_version': _appVersion,
      'build_number': _buildNumber,
      if (additionalData != null) ...additionalData,
    };

    // Log to console and file
    switch (level) {
      case LogLevel.debug:
        _logger.d(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        _logger.i(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.warning:
        _logger.w(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.critical:
        _logger.f(message, error: error, stackTrace: stackTrace);
        break;
    }
  }

  // Network error logging
  void logNetworkError(
    String endpoint,
    int? statusCode,
    String? errorMessage, {
    Map<String, dynamic>? requestData,
  }) {
    logError(
      'Network Error: $endpoint',
      additionalData: {
        'endpoint': endpoint,
        'status_code': statusCode,
        'error_message': errorMessage,
        'request_data': requestData?.toString(),
      },
    );
  }

  // Business logic error logging
  void logBusinessError(
    String feature,
    String operation,
    String errorMessage, {
    Map<String, dynamic>? context,
  }) {
    logError(
      'Business Error: $feature - $operation',
      additionalData: {
        'feature': feature,
        'operation': operation,
        'error_message': errorMessage,
        'context': context?.toString(),
      },
    );
  }

  // Get log file content for debugging
  Future<String> getLogContent() async {
    try {
      if (await _logFile.exists()) {
        return await _logFile.readAsString();
      }
      return 'No logs available';
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  // Clear logs
  Future<void> clearLogs() async {
    try {
      if (await _logFile.exists()) {
        await _logFile.writeAsString('');
        logInfo('Logs cleared');
      }
    } catch (e) {
      debugPrint('Failed to clear logs: $e');
    }
  }

  // Export logs for support
  Future<String> exportLogs() async {
    try {
      final logs = await getLogContent();
      final deviceInfo = _deviceInfo ?? 'Unknown device';
      final appVersion = _appVersion ?? 'Unknown version';
      
      return '''
=== GST Invoice App Error Report ===
Generated: ${DateTime.now().toIso8601String()}
Device: $deviceInfo
App Version: $appVersion
Build: $_buildNumber

=== Logs ===
$logs
''';
    } catch (e) {
      return 'Failed to export logs: $e';
    }
  }
}

// Custom file output for logger
class FileOutput extends LogOutput {
  final File file;
  
  FileOutput(this.file);
  
  @override
  void output(OutputEvent event) async {
    try {
      final logString = event.lines.join('\n') + '\n';
      await file.writeAsString(logString, mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }
}

// Multi-output for logger
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;
  
  MultiOutput(this.outputs);
  
  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      try {
        output.output(event);
      } catch (e) {
        debugPrint('Failed to output to logger: $e');
      }
    }
  }
}
