import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // Connectivity instance
  final Connectivity _connectivity = Connectivity();
  
  // Stream controller for connectivity status
  final BehaviorSubject<bool> _connectionStatusController = BehaviorSubject<bool>.seeded(false);
  
  // Stream of connectivity status
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  // Current connectivity status
  bool get isConnected => _connectionStatusController.value;
  
  // Subscription to connectivity changes
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Initialize the service
  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnectivity();
  }

  // Check initial connectivity
  Future<void> _checkInitialConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    final bool isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(isConnected);
  }

  // Manually check connectivity
  Future<bool> checkConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    final bool isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(isConnected);
    return isConnected;
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
