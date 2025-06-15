// ignore_for_file: avoid_print, avoid_slow_async_io, unnecessary_null_comparison

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AssetCompressor {
  factory AssetCompressor() {
    return _instance;
  }

  AssetCompressor._internal();
  static final AssetCompressor _instance = AssetCompressor._internal();

  /// Compress an image from assets and cache it
  Future<File?> compressAssetImage(
    String assetPath, {
    int quality = 80,
    int minWidth = 1024,
    int minHeight = 1024,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    try {
      // Get the asset as bytes
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Get cache directory
      final Directory cacheDir = await getTemporaryDirectory();
      final String fileName = assetPath.split('/').last;
      final String targetPath = '${cacheDir.path}/${fileName}_compressed';

      // Check if compressed file already exists
      final File targetFile = File(targetPath);
      if (await targetFile.exists()) {
        return targetFile;
      }

      // Compress the image
      final Uint8List result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: format,
      );

      if (result != null) {
        // Save the compressed image
        await targetFile.writeAsBytes(result);
        return targetFile;
      }

      return null;
    } catch (e) {
      print('Error compressing asset image: $e');
      return null;
    }
  }

  /// Compress a file image
  Future<File?> compressFileImage(
    File file, {
    int quality = 80,
    int minWidth = 1024,
    int minHeight = 1024,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    try {
      // Get cache directory
      final Directory cacheDir = await getTemporaryDirectory();
      final String fileName = file.path.split('/').last;
      final String targetPath = '${cacheDir.path}/${fileName}_compressed';

      // Compress the image
      final File? result = (await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: format,
      )) as File?;

      return result;
    } catch (e) {
      print('Error compressing file image: $e');
      return null;
    }
  }

  /// Clear the compressed assets cache
  Future<void> clearCache() async {
    try {
      final Directory cacheDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = cacheDir.listSync();

      for (final FileSystemEntity file in files) {
        if (file is File && file.path.contains('_compressed')) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
