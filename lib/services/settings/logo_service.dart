import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoService {
  static const String _logoPathKey = 'company_logo_path';
  static const String _defaultLogoAssetPath = 'assets/images/default_logo.png';
  static const String _logoFileName = 'company_logo.png';

  // Get the logo as bytes
  Future<Uint8List?> getLogoBytes() async {
    try {
      final logoPath = await _getLogoPath();
      
      if (logoPath != null) {
        // Custom logo exists
        final file = File(logoPath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
      
      // Try to load default logo from assets
      try {
        final ByteData data = await rootBundle.load(_defaultLogoAssetPath);
        return data.buffer.asUint8List();
      } catch (e) {
        // Default logo not found
        return null;
      }
    } catch (e) {
      print('Error getting logo: $e');
      return null;
    }
  }

  // Set a new logo from image picker
  Future<bool> setLogoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image != null) {
        return await _saveLogoFile(File(image.path));
      }
      return false;
    } catch (e) {
      print('Error setting logo from gallery: $e');
      return false;
    }
  }

  // Set a new logo from camera
  Future<bool> setLogoFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image != null) {
        return await _saveLogoFile(File(image.path));
      }
      return false;
    } catch (e) {
      print('Error setting logo from camera: $e');
      return false;
    }
  }

  // Reset to default logo
  Future<bool> resetToDefaultLogo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logoPath = await _getLogoPath();
      
      if (logoPath != null) {
        final file = File(logoPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      return await prefs.remove(_logoPathKey);
    } catch (e) {
      print('Error resetting logo: $e');
      return false;
    }
  }

  // Check if a custom logo exists
  Future<bool> hasCustomLogo() async {
    final logoPath = await _getLogoPath();
    if (logoPath == null) return false;
    
    final file = File(logoPath);
    return await file.exists();
  }

  // Get the logo file path
  Future<String?> _getLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_logoPathKey);
  }

  // Save the logo file and store its path
  Future<bool> _saveLogoFile(File sourceFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final targetPath = '${directory.path}/$_logoFileName';
      final targetFile = File(targetPath);
      
      // Copy the file
      await sourceFile.copy(targetPath);
      
      // Save the path in preferences
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_logoPathKey, targetPath);
    } catch (e) {
      print('Error saving logo file: $e');
      return false;
    }
  }
}
