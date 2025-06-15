// ignore_for_file: avoid_print

import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class BuildHelper {
  factory BuildHelper() {
    return _instance;
  }

  BuildHelper._internal();
  static final BuildHelper _instance = BuildHelper._internal();

  /// Get the app version
  Future<String> getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  /// Get the app package name
  Future<String> getPackageName() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }

  /// Check if the app is in debug mode
  bool isDebugMode() {
    return !const bool.fromEnvironment('dart.vm.product');
  }

  /// Execute a shell command
  Future<ProcessResult> executeCommand(
      String command, List<String> arguments) async {
    final process = await Process.run(command, arguments);
    return process;
  }

  /// Build an optimized APK
  Future<String?> buildOptimizedApk() async {
    try {
      // Check if running on a development machine
      if (!isDebugMode()) {
        throw Exception('This method should only be called in debug mode');
      }

      // Get the app version
      final String appVersion = await getAppVersion();

      // Execute flutter build command
      final ProcessResult result = await executeCommand('flutter', [
        'build',
        'apk',
        '--release',
        '--target-platform',
        'android-arm,android-arm64',
        '--split-per-abi',
        '--obfuscate',
        '--split-debug-info=build/app/outputs/symbols',
      ]);

      if (result.exitCode != 0) {
        print('Error building APK: ${result.stderr}');
        return null;
      }

      // Get the output directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String outputPath =
          '${appDocDir.path}/flutter_invoice_app_$appVersion.apk';

      // Copy the APK to the output directory
      final File apkFile =
          File('build/app/outputs/flutter-apk/app-arm64-v8a-release.apk');
      if (await apkFile.exists()) {
        await apkFile.copy(outputPath);
        return outputPath;
      }

      return null;
    } catch (e) {
      print('Error building optimized APK: $e');
      return null;
    }
  }
}
