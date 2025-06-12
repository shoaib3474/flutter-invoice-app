import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;

class EnhancedDeviceInstallationService {
  static const String adbCommand = 'adb';
  
  Future<List<AndroidDevice>> getConnectedDevices() async {
    try {
      print('🔍 Scanning for connected Android devices...');
      
      // Check if ADB is available
      final adbCheck = await Process.run(adbCommand, ['version']);
      if (adbCheck.exitCode != 0) {
        throw Exception('ADB not found. Please install Android SDK Platform Tools.');
      }
      
      // Get connected devices
      final result = await Process.run(adbCommand, ['devices', '-l']);
      if (result.exitCode != 0) {
        throw Exception('Failed to get device list: ${result.stderr}');
      }
      
      final devices = <AndroidDevice>[];
      final lines = result.stdout.toString().split('\n');
      
      for (final line in lines) {
        if (line.contains('device') && !line.contains('List of devices')) {
          final device = _parseDeviceLine(line);
          if (device != null) {
            devices.add(device);
          }
        }
      }
      
      // Get additional device info for each device
      for (final device in devices) {
        await _enrichDeviceInfo(device);
      }
      
      print('📱 Found ${devices.length} connected device(s)');
      return devices;
      
    } catch (e) {
      print('❌ Error getting devices: $e');
      rethrow;
    }
  }
  
  AndroidDevice? _parseDeviceLine(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final deviceId = parts[0];
      final status = parts[1];
      
      if (status == 'device') {
        // Extract model and product info if available
        String? model;
        String? product;
        
        if (line.contains('model:')) {
          final modelMatch = RegExp(r'model:(\S+)').firstMatch(line);
          model = modelMatch?.group(1);
        }
        
        if (line.contains('product:')) {
          final productMatch = RegExp(r'product:(\S+)').firstMatch(line);
          product = productMatch?.group(1);
        }
        
        return AndroidDevice(
          id: deviceId,
          status: status,
          model: model,
          product: product,
        );
      }
    }
    return null;
  }
  
  Future<void> _enrichDeviceInfo(AndroidDevice device) async {
    try {
      // Get device properties
      final props = await _getDeviceProperties(device.id);
      
      device.manufacturer = props['ro.product.manufacturer'];
      device.model = device.model ?? props['ro.product.model'];
      device.androidVersion = props['ro.build.version.release'];
      device.apiLevel = props['ro.build.version.sdk'];
      device.architecture = props['ro.product.cpu.abi'];
      device.deviceName = props['ro.product.device'];
      device.buildNumber = props['ro.build.display.id'];
      
    } catch (e) {
      print('⚠️ Could not get detailed info for device ${device.id}: $e');
    }
  }
  
  Future<Map<String, String>> _getDeviceProperties(String deviceId) async {
    final result = await Process.run(adbCommand, ['-s', deviceId, 'shell', 'getprop']);
    final props = <String, String>{};
    
    if (result.exitCode == 0) {
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        final match = RegExp(r'\[([^\]]+)\]: \[([^\]]*)\]').firstMatch(line);
        if (match != null) {
          props[match.group(1)!] = match.group(2)!;
        }
      }
    }
    
    return props;
  }
  
  String? getBestApkForDevice(AndroidDevice device, List<String> availableApks) {
    if (availableApks.isEmpty) return null;
    
    final architecture = device.architecture?.toLowerCase() ?? '';
    
    // Priority order for APK selection
    final priorities = <String, int>{
      'universal': 1,  // Universal APK works on all devices
      'arm64-v8a': 2,  // Modern 64-bit ARM devices
      'armeabi-v7a': 3, // Older 32-bit ARM devices
      'x86_64': 4,     // 64-bit x86 (tablets/emulators)
      'x86': 5,        // 32-bit x86 (older tablets/emulators)
    };
    
    // Find the best matching APK
    String? bestApk;
    int bestPriority = 999;
    
    for (final apk in availableApks) {
      final fileName = path.basename(apk).toLowerCase();
      
      // Skip debug APKs unless no release APKs are available
      if (fileName.contains('debug') && availableApks.any((a) => a.contains('release'))) {
        continue;
      }
      
      // Check for architecture-specific APKs
      for (final entry in priorities.entries) {
        if (fileName.contains(entry.key)) {
          // Prefer architecture-specific match
          if (architecture.contains(entry.key.replaceAll('-', '_')) || 
              entry.key == 'universal') {
            if (entry.value < bestPriority) {
              bestApk = apk;
              bestPriority = entry.value;
            }
          }
        }
      }
    }
    
    // Fallback to first available APK if no specific match
    return bestApk ?? availableApks.first;
  }
  
  Future<InstallationResult> installApk(String deviceId, String apkPath, {
    bool reinstall = true,
    bool grantPermissions = true,
    Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('📦 Starting APK installation...');
      
      // Check if APK file exists
      final apkFile = File(apkPath);
      if (!apkFile.existsSync()) {
        throw Exception('APK file not found: $apkPath');
      }
      
      onProgress?.call('📱 Installing on device $deviceId...');
      
      // Build install command
      final installArgs = ['-s', deviceId, 'install'];
      if (reinstall) installArgs.add('-r');
      if (grantPermissions) installArgs.add('-g');
      installArgs.add(apkPath);
      
      // Execute installation
      final result = await Process.run(adbCommand, installArgs);
      
      if (result.exitCode == 0) {
        onProgress?.call('✅ Installation completed successfully!');
        
        // Try to get package name and launch the app
        final packageName = await _getPackageName(apkPath);
        
        return InstallationResult(
          success: true,
          deviceId: deviceId,
          apkPath: apkPath,
          packageName: packageName,
          message: 'APK installed successfully',
          output: result.stdout.toString(),
        );
      } else {
        final errorMessage = result.stderr.toString();
        onProgress?.call('❌ Installation failed: $errorMessage');
        
        return InstallationResult(
          success: false,
          deviceId: deviceId,
          apkPath: apkPath,
          message: 'Installation failed: $errorMessage',
          output: result.stdout.toString(),
          error: errorMessage,
        );
      }
      
    } catch (e) {
      onProgress?.call('❌ Installation error: $e');
      return InstallationResult(
        success: false,
        deviceId: deviceId,
        apkPath: apkPath,
        message: 'Installation error: $e',
        error: e.toString(),
      );
    }
  }
  
  Future<String?> _getPackageName(String apkPath) async {
    try {
      final result = await Process.run('aapt', ['dump', 'badging', apkPath]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r"package: name='([^']+)'").firstMatch(output);
        return match?.group(1);
      }
    } catch (e) {
      // aapt might not be available, try alternative method
      return 'com.example.flutter_invoice_app'; // fallback
    }
    return null;
  }
  
  Future<bool> launchApp(String deviceId, String packageName) async {
    try {
      final result = await Process.run(adbCommand, [
        '-s', deviceId, 'shell', 'monkey', '-p', packageName, '1'
      ]);
      return result.exitCode == 0;
    } catch (e) {
      print('⚠️ Could not launch app: $e');
      return false;
    }
  }
  
  Future<bool> uninstallApp(String deviceId, String packageName) async {
    try {
      final result = await Process.run(adbCommand, [
        '-s', deviceId, 'uninstall', packageName
      ]);
      return result.exitCode == 0;
    } catch (e) {
      print('⚠️ Could not uninstall app: $e');
      return false;
    }
  }
  
  Future<List<String>> getAvailableApks() async {
    final apks = <String>[];
    final releaseDir = Directory('release');
    
    if (releaseDir.existsSync()) {
      final files = releaseDir.listSync();
      for (final file in files) {
        if (file is File && file.path.endsWith('.apk')) {
          apks.add(file.path);
        }
      }
    }
    
    // Also check build/app/outputs/flutter-apk/
    final buildDir = Directory('build/app/outputs/flutter-apk');
    if (buildDir.existsSync()) {
      final files = buildDir.listSync();
      for (final file in files) {
        if (file is File && file.path.endsWith('.apk')) {
          apks.add(file.path);
        }
      }
    }
    
    // Sort APKs by preference (release first, then by architecture)
    apks.sort((a, b) {
      if (a.contains('release') && !b.contains('release')) return -1;
      if (!a.contains('release') && b.contains('release')) return 1;
      if (a.contains('universal')) return -1;
      if (b.contains('universal')) return 1;
      return a.compareTo(b);
    });
    
    return apks;
  }
  
  Future<bool> checkDeviceCompatibility(AndroidDevice device, String apkPath) async {
    try {
      // Get APK info
      final result = await Process.run('aapt', ['dump', 'badging', apkPath]);
      if (result.exitCode != 0) return true; // Assume compatible if can't check
      
      final output = result.stdout.toString();
      
      // Check minimum SDK version
      final sdkMatch = RegExp(r"sdkVersion:'(\d+)'").firstMatch(output);
      if (sdkMatch != null) {
        final minSdk = int.tryParse(sdkMatch.group(1)!) ?? 0;
        final deviceSdk = int.tryParse(device.apiLevel ?? '0') ?? 0;
        
        if (deviceSdk < minSdk) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return true; // Assume compatible if can't check
    }
  }
}

class AndroidDevice {
  final String id;
  final String status;
  String? model;
  String? product;
  String? manufacturer;
  String? androidVersion;
  String? apiLevel;
  String? architecture;
  String? deviceName;
  String? buildNumber;
  
  AndroidDevice({
    required this.id,
    required this.status,
    this.model,
    this.product,
    this.manufacturer,
    this.androidVersion,
    this.apiLevel,
    this.architecture,
    this.deviceName,
    this.buildNumber,
  });
  
  String get displayName {
    if (manufacturer != null && model != null) {
      return '$manufacturer $model';
    } else if (model != null) {
      return model!;
    } else if (deviceName != null) {
      return deviceName!;
    } else {
      return 'Android Device';
    }
  }
  
  String get detailsText {
    final details = <String>[];
    if (androidVersion != null) details.add('Android $androidVersion');
    if (apiLevel != null) details.add('API $apiLevel');
    if (architecture != null) details.add(architecture!);
    return details.join(' • ');
  }
  
  bool get isEmulator {
    return id.startsWith('emulator-') || 
           (product?.contains('sdk') == true) ||
           (deviceName?.contains('generic') == true);
  }
  
  String get architectureDisplayName {
    switch (architecture?.toLowerCase()) {
      case 'arm64-v8a':
        return '64-bit ARM (Modern)';
      case 'armeabi-v7a':
        return '32-bit ARM (Compatible)';
      case 'x86_64':
        return '64-bit x86 (Intel)';
      case 'x86':
        return '32-bit x86 (Intel)';
      default:
        return architecture ?? 'Unknown';
    }
  }
}

class InstallationResult {
  final bool success;
  final String deviceId;
  final String apkPath;
  final String? packageName;
  final String message;
  final String? output;
  final String? error;
  
  InstallationResult({
    required this.success,
    required this.deviceId,
    required this.apkPath,
    this.packageName,
    required this.message,
    this.output,
    this.error,
  });
}
