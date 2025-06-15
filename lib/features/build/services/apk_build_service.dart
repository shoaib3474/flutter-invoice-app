// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ApkBuildService {
  factory ApkBuildService() => _instance;
  ApkBuildService._internal();
  static final ApkBuildService _instance = ApkBuildService._internal();

  /// Build production APK
  Future<ApkBuildResult> buildProductionApk({
    bool splitPerAbi = true,
    bool obfuscate = true,
    bool shrinkResources = true,
    String? outputPath,
  }) async {
    try {
      final buildStartTime = DateTime.now();

      // Get app info
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Create build configuration
      final buildConfig = ApkBuildConfig(
        appName: packageInfo.appName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        splitPerAbi: splitPerAbi,
        obfuscate: obfuscate,
        shrinkResources: shrinkResources,
        targetSdk: androidInfo.version.sdkInt,
      );

      // Execute build process
      final buildResult = await _executeBuildProcess(buildConfig);

      // Calculate build time
      final buildDuration = DateTime.now().difference(buildStartTime);

      // Copy APK to downloads
      final apkPath =
          await _copyApkToDownloads(buildResult.apkPath, buildConfig);

      return ApkBuildResult(
        success: true,
        apkPath: apkPath,
        buildConfig: buildConfig,
        buildDuration: buildDuration,
        fileSize: await _getFileSize(apkPath),
        buildLog: buildResult.buildLog,
      );
    } catch (e, stackTrace) {
      return ApkBuildResult(
        success: false,
        error: e.toString(),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  /// Execute the actual build process
  Future<_BuildProcessResult> _executeBuildProcess(
      ApkBuildConfig config) async {
    final buildCommands = _generateBuildCommands(config);
    final buildLog = StringBuffer();

    for (final command in buildCommands) {
      buildLog.writeln('Executing: ${command.join(' ')}');

      final result = await Process.run(
        command.first,
        command.skip(1).toList(),
        workingDirectory: await _getProjectRoot(),
      );

      buildLog.writeln('Exit code: ${result.exitCode}');
      buildLog.writeln('Output: ${result.stdout}');

      if (result.exitCode != 0) {
        buildLog.writeln('Error: ${result.stderr}');
        throw Exception('Build failed: ${result.stderr}');
      }
    }

    final apkPath = await _findGeneratedApk(config);

    return _BuildProcessResult(
      apkPath: apkPath,
      buildLog: buildLog.toString(),
    );
  }

  /// Generate build commands based on configuration
  List<List<String>> _generateBuildCommands(ApkBuildConfig config) {
    final commands = <List<String>>[];

    // Clean previous builds
    commands.add(['flutter', 'clean']);

    // Get dependencies
    commands.add(['flutter', 'pub', 'get']);

    // Generate code if needed
    commands.add([
      'flutter',
      'packages',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs'
    ]);

    // Build APK
    final buildCommand = ['flutter', 'build', 'apk', '--release'];

    if (config.splitPerAbi) {
      buildCommand.addAll(['--split-per-abi']);
    }

    if (config.obfuscate) {
      buildCommand.addAll([
        '--obfuscate',
        '--split-debug-info=build/app/outputs/symbols',
      ]);
    }

    if (config.shrinkResources) {
      buildCommand.addAll(['--shrink']);
    }

    // Add target platforms
    buildCommand.addAll([
      '--target-platform',
      'android-arm,android-arm64,android-x64',
    ]);

    commands.add(buildCommand);

    return commands;
  }

  /// Find the generated APK file
  Future<String> _findGeneratedApk(ApkBuildConfig config) async {
    final projectRoot = await _getProjectRoot();
    final apkDir = Directory('$projectRoot/build/app/outputs/flutter-apk');

    if (!await apkDir.exists()) {
      throw Exception('APK output directory not found');
    }

    final apkFiles = await apkDir
        .list()
        .where((file) => file.path.endsWith('.apk'))
        .toList();

    if (apkFiles.isEmpty) {
      throw Exception('No APK files found');
    }

    // Prefer arm64 APK if split per ABI
    if (config.splitPerAbi) {
      final arm64Apk = apkFiles.firstWhere(
        (file) => file.path.contains('arm64-v8a'),
        orElse: () => apkFiles.first,
      );
      return arm64Apk.path;
    }

    return apkFiles.first.path;
  }

  /// Copy APK to downloads folder
  Future<String> _copyApkToDownloads(
      String sourcePath, ApkBuildConfig config) async {
    // Request storage permission
    final permission = await Permission.storage.request();
    if (!permission.isGranted) {
      throw Exception('Storage permission required to save APK');
    }

    // Get downloads directory
    final downloadsDir = await _getDownloadsDirectory();

    // Generate APK filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename =
        'GST_Invoice_v${config.version}_build${config.buildNumber}_$timestamp.apk';
    final destinationPath = '${downloadsDir.path}/$filename';

    // Copy file
    final sourceFile = File(sourcePath);
    await sourceFile.copy(destinationPath);

    return destinationPath;
  }

  /// Get downloads directory
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else {
      return await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }
  }

  /// Get project root directory
  Future<String> _getProjectRoot() async {
    // This is a simplified implementation
    // In a real app, you'd need to determine the actual project root
    return Directory.current.path;
  }

  /// Get file size in bytes
  Future<int> _getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Share APK file
  Future<void> shareApk(String apkPath) async {
    final file = File(apkPath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(apkPath)],
        text: 'GST Invoice App APK',
        subject: 'Install GST Invoice App',
      );
    } else {
      throw Exception('APK file not found');
    }
  }

  /// Install APK (requires user interaction)
  Future<void> installApk(String apkPath) async {
    if (Platform.isAndroid) {
      // Open APK file for installation
      await Process.run('am', [
        'start',
        '-a',
        'android.intent.action.VIEW',
        '-d',
        'file://$apkPath',
        '-t',
        'application/vnd.android.package-archive',
      ]);
    }
  }

  /// Get build information
  Future<BuildInfo> getBuildInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    return BuildInfo(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      deviceModel: androidInfo.model,
      androidVersion: androidInfo.version.release,
      sdkVersion: androidInfo.version.sdkInt,
    );
  }
}

// Data classes
class ApkBuildConfig {
  ApkBuildConfig({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.splitPerAbi,
    required this.obfuscate,
    required this.shrinkResources,
    required this.targetSdk,
  });
  final String appName;
  final String version;
  final String buildNumber;
  final bool splitPerAbi;
  final bool obfuscate;
  final bool shrinkResources;
  final int targetSdk;
}

class ApkBuildResult {
  ApkBuildResult({
    required this.success,
    this.apkPath,
    this.buildConfig,
    this.buildDuration,
    this.fileSize,
    this.buildLog,
    this.error,
    this.stackTrace,
  });
  final bool success;
  final String? apkPath;
  final ApkBuildConfig? buildConfig;
  final Duration? buildDuration;
  final int? fileSize;
  final String? buildLog;
  final String? error;
  final String? stackTrace;
}

class _BuildProcessResult {
  _BuildProcessResult({
    required this.apkPath,
    required this.buildLog,
  });
  final String apkPath;
  final String buildLog;
}

class BuildInfo {
  BuildInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.deviceModel,
    required this.androidVersion,
    required this.sdkVersion,
  });
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String deviceModel;
  final String androidVersion;
  final int sdkVersion;
}
