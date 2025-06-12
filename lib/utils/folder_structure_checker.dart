import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/logger_service.dart';

class FolderStructureChecker {
  static final LoggerService _logger = LoggerService();

  static Future<bool> checkAndCreateFolders() async {
    try {
      _logger.info('Checking and creating required folders');
      
      // Get app directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final baseDir = appDocDir.path;
      
      // Define required folders
      final requiredFolders = [
        '$baseDir/exports',
        '$baseDir/exports/pdf',
        '$baseDir/exports/excel',
        '$baseDir/exports/json',
        '$baseDir/imports',
        '$baseDir/cache',
        '$baseDir/logs',
        '$baseDir/backups',
        '$baseDir/temp',
      ];
      
      // Check and create each folder
      for (var folderPath in requiredFolders) {
        final folder = Directory(folderPath);
        if (!await folder.exists()) {
          _logger.info('Creating folder: $folderPath');
          await folder.create(recursive: true);
        }
      }
      
      _logger.info('All required folders are available');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Error checking/creating folders', e, stackTrace);
      return false;
    }
  }

  static Future<Map<String, dynamic>> getFolderStructureInfo() async {
    try {
      _logger.info('Getting folder structure information');
      
      // Get app directories
      final appDocDir = await getApplicationDocumentsDirectory();
      final appSupportDir = await getApplicationSupportDirectory();
      final tempDir = await getTemporaryDirectory();
      
      // Get folder sizes
      final Map<String, int> folderSizes = {};
      
      // Check app document directory structure
      final baseDir = appDocDir.path;
      final folders = [
        'exports',
        'exports/pdf',
        'exports/excel',
        'exports/json',
        'imports',
        'cache',
        'logs',
        'backups',
        'temp',
      ];
      
      for (var folderName in folders) {
        final folderPath = '$baseDir/$folderName';
        final folder = Directory(folderPath);
        
        if (await folder.exists()) {
          folderSizes[folderName] = await _calculateDirSize(folder);
        } else {
          folderSizes[folderName] = -1; // Indicates folder doesn't exist
        }
      }
      
      // Get total sizes
      final appDocSize = await _calculateDirSize(appDocDir);
      final appSupportSize = await _calculateDirSize(appSupportDir);
      final tempSize = await _calculateDirSize(tempDir);
      
      return {
        'appDocDir': appDocDir.path,
        'appSupportDir': appSupportDir.path,
        'tempDir': tempDir.path,
        'appDocSize': appDocSize,
        'appSupportSize': appSupportSize,
        'tempSize': tempSize,
        'folderSizes': folderSizes,
        'totalSize': appDocSize + appSupportSize + tempSize,
      };
    } catch (e, stackTrace) {
      _logger.error('Error getting folder structure info', e, stackTrace);
      return {'error': e.toString()};
    }
  }

  static Future<int> _calculateDirSize(Directory dir) async {
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (var entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      _logger.warning('Error calculating directory size: $e');
    }
    return totalSize;
  }
}
