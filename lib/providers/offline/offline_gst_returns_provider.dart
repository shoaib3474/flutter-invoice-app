import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/sync/sync_status.dart';
import 'package:flutter_invoice_app/repositories/gst_returns/offline_gst_returns_repository.dart';
import 'package:flutter_invoice_app/services/connectivity/connectivity_service.dart';
import 'package:flutter_invoice_app/services/sync/sync_service.dart';

class OfflineGSTR1Provider with ChangeNotifier {
  final OfflineGSTR1Repository _repository = OfflineGSTR1Repository();
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();
  
  bool _isLoading = false;
  String? _error;
  List<GSTR1> _returns = [];
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<GSTR1> get returns => _returns;
  bool get isOffline => !_connectivityService.isConnected;
  int get pendingChanges => _syncService.pendingChanges;
  bool get isSyncing => _syncService.isSyncingNow;
  
  // Load all returns for a GSTIN
  Future<void> loadReturns(String gstin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _returns = await _repository.getAllForGstin(gstin);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load returns: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get a return by GSTIN and period
  Future<GSTR1?> getReturn(String gstin, String returnPeriod) async {
    try {
      return await _repository.getByGstinAndPeriod(gstin, returnPeriod);
    } catch (e) {
      _error = 'Failed to get return: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
  
  // Save a return
  Future<bool> saveReturn(GSTR1 gstReturn) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if return already exists
      final existing = await _repository.getByGstinAndPeriod(
        gstReturn.gstin,
        gstReturn.returnPeriod,
      );
      
      if (existing != null) {
        // Update existing return
        await _repository.update(gstReturn);
      } else {
        // Create new return
        await _repository.create(gstReturn);
      }
      
      // Reload returns
      await loadReturns(gstReturn.gstin);
      
      return true;
    } catch (e) {
      _error = 'Failed to save return: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete a return
  Future<bool> deleteReturn(String gstin, String returnPeriod) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final id = '${gstin}_${returnPeriod}';
      await _repository.delete(id);
      
      // Reload returns
      await loadReturns(gstin);
      
      return true;
    } catch (e) {
      _error = 'Failed to delete return: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get sync status for a return
  Future<SyncStatus> getSyncStatus(String gstin, String returnPeriod) async {
    final id = '${gstin}_${returnPeriod}';
    return await _repository.getSyncStatus(id);
  }
  
  // Force sync
  Future<bool> syncNow() async {
    return await _syncService.forceSyncNow();
  }
  
  // Import returns from JSON
  Future<bool> importFromJson(String json) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _repository.importFromJson(json);
      
      // Reload returns for the first GSTIN in the list
      if (_returns.isNotEmpty) {
        await loadReturns(_returns.first.gstin);
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to import returns: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Export returns to JSON
  Future<String?> exportToJson() async {
    try {
      return await _repository.exportToJson();
    } catch (e) {
      _error = 'Failed to export returns: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
