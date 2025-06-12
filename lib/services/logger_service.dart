import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  late Logger _logger;
  late File _logFile;
  bool _initialized = false;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal() {
    _initializeLogger();
  }

  Future<void> _initializeLogger() async {
    if (_initialized) return;

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String logDirPath = '${appDocDir.path}/logs';
      final Directory logDir = Directory(logDirPath);
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Create a log file with current date
      final String today = DateTime.now().toIso8601String().split('T')[0];
      _logFile = File('$logDirPath/app_log_$today.log');
      
      // Create a file output
      final output = FileOutput(_logFile);
      
      // Configure logger with console and file outputs
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: MultiOutput([ConsoleOutput(), output]),
        level: Level.debug,
      );
      
      _initialized = true;
      _logger.i('Logger initialized successfully');
    } catch (e) {
      print('Failed to initialize logger: $e');
      // Fallback to console-only logger
      _logger = Logger();
      _logger.e('Failed to initialize file logging: $e');
    }
  }

  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _initializeLogger();
    }
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  Future<String> getLogFilePath() async {
    await ensureInitialized();
    return _logFile.path;
  }

  Future<String> getLogContent() async {
    await ensureInitialized();
    if (await _logFile.exists()) {
      return await _logFile.readAsString();
    }
    return 'No logs available';
  }

  Future<void> clearLogs() async {
    await ensureInitialized();
    if (await _logFile.exists()) {
      await _logFile.writeAsString('');
      _logger.i('Logs cleared');
    }
  }
}

// Custom output to write logs to a file
class FileOutput extends LogOutput {
  final File file;
  
  FileOutput(this.file);
  
  @override
  void output(OutputEvent event) async {
    final logString = event.lines.join('\n') + '\n';
    await file.writeAsString(logString, mode: FileMode.append);
  }
}

// Output that writes to multiple destinations
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;
  
  MultiOutput(this.outputs);
  
  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }
}
