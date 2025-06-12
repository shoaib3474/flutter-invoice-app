import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageOptimizer {
  static final ImageOptimizer _instance = ImageOptimizer._internal();
  
  factory ImageOptimizer() {
    return _instance;
  }
  
  ImageOptimizer._internal();
  
  /// Optimize all images in the assets directory
  Future<void> optimizeAssetImages({
    required String assetsDir,
    required String outputDir,
    int quality = 80,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      // Create output directory if it doesn't exist
      final Directory output = Directory(outputDir);
      if (!await output.exists()) {
        await output.create(recursive: true);
      }
      
      // Get all files in the assets directory
      final Directory assets = Directory(assetsDir);
      final List<FileSystemEntity> files = assets.listSync(recursive: true);
      
      int optimizedCount = 0;
      int totalSavings = 0;
      
      // Process each file
      for (final FileSystemEntity entity in files) {
        if (entity is File) {
          final String extension = path.extension(entity.path).toLowerCase();
          
          // Only process image files
          if (['.jpg', '.jpeg', '.png', '.webp'].contains(extension)) {
            final String relativePath = entity.path.replaceFirst(assetsDir, '');
            final String outputPath = path.join(outputDir, relativePath);
            
            // Create parent directories if they don't exist
            final Directory parent = Directory(path.dirname(outputPath));
            if (!await parent.exists()) {
              await parent.create(recursive: true);
            }
            
            // Compress the image
            final File? result = await FlutterImageCompress.compressAndGetFile(
              entity.absolute.path,
              outputPath,
              quality: quality,
              minWidth: maxWidth,
              minHeight: maxHeight,
              format: _getFormatFromExtension(extension),
            );
            
            if (result != null) {
              final int originalSize = entity.lengthSync();
              final int optimizedSize = result.lengthSync();
              final int savings = originalSize - optimizedSize;
              
              if (savings > 0) {
                optimizedCount++;
                totalSavings += savings;
                
                print('Optimized: ${entity.path}');
                print('  Original size: ${_formatSize(originalSize)}');
                print('  Optimized size: ${_formatSize(optimizedSize)}');
                print('  Savings: ${_formatSize(savings)} (${(savings / originalSize * 100).toStringAsFixed(2)}%)');
              } else {
                // If no savings, copy the original file
                await entity.copy(outputPath);
                print('No optimization needed: ${entity.path}');
              }
            }
          }
        }
      }
      
      print('Optimization complete:');
      print('  Optimized $optimizedCount images');
      print('  Total savings: ${_formatSize(totalSavings)}');
    } catch (e) {
      print('Error optimizing asset images: $e');
    }
  }
  
  /// Get the compression format from file extension
  CompressFormat _getFormatFromExtension(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return CompressFormat.jpeg;
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
    }
  }
  
  /// Format the size in bytes to a human-readable format
  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const List<String> suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}
