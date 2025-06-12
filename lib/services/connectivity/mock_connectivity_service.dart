import 'dart:async';

// Mock connectivity service to replace connectivity_plus dependency
class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // Mock connectivity status
  bool _isConnected = true;
  
  // Stream controller for connectivity status
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  // Stream of connectivity status
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  // Current connectivity status
  bool get isConnected => _isConnected;

  // Initialize the service
  void initialize() {
    // Simulate initial connectivity check
    _connectionStatusController.add(_isConnected);
    
    // Simulate periodic connectivity changes for testing
    Timer.periodic(const Duration(minutes: 5), (timer) {
      // Randomly simulate connectivity changes (for testing)
      if (DateTime.now().millisecond % 100 == 0) {
        _isConnected = !_isConnected;
        _connectionStatusController.add(_isConnected);
      }
    });
  }

  // Manually check connectivity
  Future<bool> checkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network check
    _connectionStatusController.add(_isConnected);
    return _isConnected;
  }
  
  // Manually set connectivity status (for testing)
  void setConnectivityStatus(bool connected) {
    _isConnected = connected;
    _connectionStatusController.add(_isConnected);
  }

  // Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }
}
