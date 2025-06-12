import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class MemoryOptimizer {
  static final MemoryOptimizer _instance = MemoryOptimizer._internal();
  
  factory MemoryOptimizer() {
    return _instance;
  }
  
  MemoryOptimizer._internal();
  
  /// Clear the app cache
  Future<void> clearAppCache() async {
    try {
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      
      // Clear network cache
      await DefaultCacheManager().emptyCache();
      
      // Clear temporary files
      final Directory tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.listSync().forEach((FileSystemEntity entity) {
          if (entity is File) {
            try {
              entity.deleteSync();
            } catch (e) {
              // Ignore errors for files that can't be deleted
            }
          }
        });
      }
    } catch (e) {
      print('Error clearing app cache: $e');
    }
  }
  
  /// Get the app cache size in bytes
  Future<int> getAppCacheSize() async {
    try {
      int totalSize = 0;
      
      // Get temporary directory size
      final Directory tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
      
      return totalSize;
    } catch (e) {
      print('Error getting app cache size: $e');
      return 0;
    }
  }
  
  /// Format the size in bytes to a human-readable format
  String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const List<String> suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  /// Optimize memory usage by reducing image cache size
  void optimizeImageCache({int size = 50, int maximumSize = 100}) {
    PaintingBinding.instance.imageCache.maximumSize = maximumSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = size * 1024 * 1024; // Convert MB to bytes
  }
  
  /// Dispose resources
  void dispose() {
    // Nothing to dispose
  }
}
