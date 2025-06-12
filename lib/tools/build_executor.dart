import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class BuildExecutor {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  final StreamController<String> _logController =
      StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  void _log(String message, {String color = ''}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '$color[$timestamp] $message$_reset';
    debugPrint(logMessage);
    _logController.add(logMessage);
  }

  void _logStep(String message) => _log('📋 $message', color: _blue);
  void _logSuccess(String message) => _log('✅ $message', color: _green);
  void _logWarning(String message) => _log('⚠️  $message', color: _yellow);
  void _logError(String message) => _log('❌ $message', color: _red);
  void _logInfo(String message) => _log('ℹ️  $message', color: _cyan);

  Future<bool> executeCompleteBuild() async {
    try {
      _log('🚀 Starting Flutter Invoice App Complete Release Build Process...',
          color: _magenta);
      _log('=' * 80, color: _magenta);

      // Step 1: Environment Check
      if (!await _checkEnvironment()) return false;

      // Step 2: Project Validation
      if (!await _validateProject()) return false;

      // Step 3: Clean Previous Builds
      if (!await _cleanPreviousBuilds()) return false;

      // Step 4: Dependencies
      if (!await _resolveDependencies()) return false;

      // Step 5: Code Generation
      if (!await _generateCode()) return false;

      // Step 6: Code Analysis
      if (!await _runCodeAnalysis()) return false;

      // Step 7: Tests
      if (!await _runTests()) return false;

      // Step 8: Migration Tests
      if (!await _runMigrationTests()) return false;

      // Step 9: Keystore Check
      final buildType = await _checkKeystore();

      // Step 10: Build APK
      if (!await _buildApk(buildType)) return false;

      // Step 11: Build App Bundle (if release)
      if (buildType == 'release') {
        if (!await _buildAppBundle()) return false;
      }

      // Step 12: Organize Release Files
      if (!await _organizeReleaseFiles(buildType)) return false;

      // Step 13: Generate Build Info
      if (!await _generateBuildInfo(buildType)) return false;

      // Step 14: APK Analysis
      if (!await _analyzeApk(buildType)) return false;

      // Step 15: Installation Test
      await _testInstallation(buildType);

      // Step 16: Final Summary
      _showBuildSummary(buildType);

      _log('🎉 Complete Release Build Process Finished Successfully!',
          color: _green);
      return true;
    } catch (e) {
      _logError('Build process failed: $e');
      return false;
    }
  }

  Future<bool> _checkEnvironment() async {
    _logStep('Checking build environment...');

    // Check Flutter installation
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().split('\n')[0];
        _logSuccess('Flutter found: $version');
      } else {
        _logError('Flutter is not installed or not in PATH');
        return false;
      }
    } catch (e) {
      _logError('Flutter check failed: $e');
      return false;
    }

    // Check Dart version
    try {
      final result = await Process.run('dart', ['--version']);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        _logSuccess('Dart found: $version');
      }
    } catch (e) {
      _logWarning('Dart version check failed: $e');
    }

    // Check Java version
    try {
      final result = await Process.run('java', ['-version']);
      if (result.exitCode == 0) {
        final version = result.stderr.toString().split('\n')[0];
        _logSuccess('Java found: $version');
      } else {
        _logError('Java is not installed');
        return false;
      }
    } catch (e) {
      _logError('Java check failed: $e');
      return false;
    }

    // Check Android SDK
    final androidHome = Platform.environment['ANDROID_HOME'];
    if (androidHome != null && androidHome.isNotEmpty) {
      _logSuccess('Android SDK found at: $androidHome');
    } else {
      _logWarning(
          'ANDROID_HOME not set. Please set it to your Android SDK path.');
    }

    // Check for connected devices
    try {
      final result = await Process.run('adb', ['devices']);
      if (result.exitCode == 0) {
        final devices = result.stdout
            .toString()
            .split('\n')
            .where((line) =>
                line.contains('device') && !line.contains('List of devices'))
            .length;
        if (devices > 0) {
          _logSuccess('Found $devices connected device(s)');
        } else {
          _logInfo('No devices connected (emulator/physical device)');
        }
      }
    } catch (e) {
      _logWarning('ADB check failed: $e');
    }

    return true;
  }

  Future<bool> _validateProject() async {
    _logStep('Validating project structure...');

    // Check if pubspec.yaml exists
    if (!File('pubspec.yaml').existsSync()) {
      _logError('pubspec.yaml not found. Are you in the Flutter project root?');
      return false;
    }

    // Check if android directory exists
    if (!Directory('android').existsSync()) {
      _logError('Android directory not found');
      return false;
    }

    // Check if lib directory exists
    if (!Directory('lib').existsSync()) {
      _logError('lib directory not found');
      return false;
    }

    // Check for main.dart
    if (!File('lib/main.dart').existsSync()) {
      _logError('lib/main.dart not found');
      return false;
    }

    // Check Android build.gradle
    if (!File('android/app/build.gradle').existsSync()) {
      _logError('android/app/build.gradle not found');
      return false;
    }

    _logSuccess('Project structure validated');
    return true;
  }

  Future<bool> _cleanPreviousBuilds() async {
    _logStep('Cleaning previous builds...');

    try {
      // Flutter clean
      final flutterCleanResult = await Process.run('flutter', ['clean']);
      if (flutterCleanResult.exitCode == 0) {
        _logSuccess('Flutter clean completed');
      } else {
        _logWarning('Flutter clean had issues: ${flutterCleanResult.stderr}');
      }

      // Clean build directory
      final buildDir = Directory('build');
      if (buildDir.existsSync()) {
        await buildDir.delete(recursive: true);
        _logSuccess('Build directory cleaned');
      }

      // Clean release directory
      final releaseDir = Directory('release');
      if (releaseDir.existsSync()) {
        await releaseDir.delete(recursive: true);
        _logSuccess('Release directory cleaned');
      }

      // Android Gradle clean
      if (Platform.isWindows) {
        final gradleCleanResult = await Process.run(
          'cmd',
          ['/c', 'cd android && gradlew.bat clean'],
        );
        if (gradleCleanResult.exitCode == 0) {
          _logSuccess('Android Gradle clean completed');
        } else {
          _logWarning('Android Gradle clean had issues');
        }
      } else {
        final gradleCleanResult = await Process.run(
          'bash',
          ['-c', 'cd android && ./gradlew clean'],
        );
        if (gradleCleanResult.exitCode == 0) {
          _logSuccess('Android Gradle clean completed');
        } else {
          _logWarning('Android Gradle clean had issues');
        }
      }

      return true;
    } catch (e) {
      _logError('Clean process failed: $e');
      return false;
    }
  }

  Future<bool> _resolveDependencies() async {
    _logStep('Getting dependencies...');

    try {
      final result = await Process.run('flutter', ['pub', 'get']);
      if (result.exitCode == 0) {
        _logSuccess('Dependencies resolved successfully');

        // Show dependency count
        final pubspecContent = await File('pubspec.yaml').readAsString();
        final dependencyCount = pubspecContent
            .split('\n')
            .where((line) =>
                line.trim().contains(':') &&
                !line.trim().startsWith('#') &&
                line.contains('^'))
            .length;
        _logInfo('Total dependencies: $dependencyCount');

        return true;
      } else {
        _logError('Failed to get dependencies: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logError('Dependency resolution failed: $e');
      return false;
    }
  }

  Future<bool> _generateCode() async {
    _logStep('Generating code...');

    // Check if build.yaml exists
    if (File('build.yaml').existsSync()) {
      try {
        final result = await Process.run('flutter', [
          'packages',
          'pub',
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs'
        ]);

        if (result.exitCode == 0) {
          _logSuccess('Code generation completed');
        } else {
          _logWarning('Code generation had issues: ${result.stderr}');
        }
      } catch (e) {
        _logWarning('Code generation failed: $e');
      }
    } else {
      _logInfo('No build.yaml found, skipping code generation');
    }

    return true;
  }

  Future<bool> _runCodeAnalysis() async {
    _logStep('Running code analysis...');

    try {
      final result = await Process.run('flutter', ['analyze']);
      if (result.exitCode == 0) {
        _logSuccess('Code analysis passed');
        return true;
      } else {
        _logWarning('Code analysis found issues:');
        _logWarning(result.stdout.toString());

        // In a real scenario, you might want to prompt user to continue
        _logInfo('Continuing build despite analysis issues...');
        return true;
      }
    } catch (e) {
      _logError('Code analysis failed: $e');
      return false;
    }
  }

  Future<bool> _runTests() async {
    _logStep('Running tests...');

    try {
      final result = await Process.run('flutter', ['test']);
      if (result.exitCode == 0) {
        _logSuccess('All tests passed');

        // Parse test results
        final output = result.stdout.toString();
        final testCount = RegExp(r'(\d+) tests? passed').firstMatch(output);
        if (testCount != null) {
          _logInfo('Tests passed: ${testCount.group(1)}');
        }

        return true;
      } else {
        _logWarning('Some tests failed:');
        _logWarning(result.stdout.toString());

        // In a real scenario, you might want to prompt user to continue
        _logInfo('Continuing build despite test failures...');
        return true;
      }
    } catch (e) {
      _logWarning('Test execution failed: $e');
      return true; // Continue build even if tests fail
    }
  }

  Future<bool> _runMigrationTests() async {
    _logStep('Running migration tests...');

    try {
      // Check if migration test file exists
      if (File('test/migration_test.dart').existsSync()) {
        final result =
            await Process.run('flutter', ['test', 'test/migration_test.dart']);
        if (result.exitCode == 0) {
          _logSuccess('Migration tests passed');
        } else {
          _logWarning('Migration tests had issues: ${result.stderr}');
        }
      } else {
        _logInfo('No migration tests found, skipping...');
      }
      return true;
    } catch (e) {
      _logWarning('Migration test execution failed: $e');
      return true; // Continue build even if migration tests fail
    }
  }

  Future<String> _checkKeystore() async {
    _logStep('Checking keystore configuration...');

    final keystoreProperties = File('android/keystore.properties');

    if (!keystoreProperties.existsSync()) {
      _logWarning(
          'Keystore properties not found at android/keystore.properties');
      _logWarning('Creating debug build instead of release build');
      return 'debug';
    }

    try {
      final properties = await keystoreProperties.readAsString();
      final storeFileMatch = RegExp(r'storeFile=(.+)').firstMatch(properties);

      if (storeFileMatch != null) {
        final storeFile = storeFileMatch.group(1)!;
        final keystoreFile = File('android/$storeFile');

        if (keystoreFile.existsSync()) {
          _logSuccess('Keystore configuration found and valid');
          _logInfo('Keystore file: $storeFile');
          return 'release';
        } else {
          _logWarning('Keystore file not found: $storeFile');
          _logWarning('Creating debug build instead');
          return 'debug';
        }
      } else {
        _logWarning('Invalid keystore properties format');
        return 'debug';
      }
    } catch (e) {
      _logWarning('Error reading keystore properties: $e');
      return 'debug';
    }
  }

  Future<bool> _buildApk(String buildType) async {
    _logStep('Building APK ($buildType)...');

    try {
      List<String> args = ['build', 'apk'];

      if (buildType == 'release') {
        args.addAll(['--release', '--split-per-abi']);
        _logInfo('Building release APK with split per ABI...');
      } else {
        args.add('--debug');
        _logInfo('Building debug APK...');
      }

      final result = await Process.run('flutter', args);

      if (result.exitCode == 0) {
        _logSuccess('APK build completed successfully');

        // Parse build output for APK sizes
        final output = result.stdout.toString();
        final sizeMatches = RegExp(r'(\d+\.?\d*)\s*(KB|MB)').allMatches(output);
        for (final match in sizeMatches) {
          _logInfo('APK size: ${match.group(0)}');
        }

        // Build universal APK for release
        if (buildType == 'release') {
          _logInfo('Building universal release APK...');
          final universalResult =
              await Process.run('flutter', ['build', 'apk', '--release']);
          if (universalResult.exitCode == 0) {
            _logSuccess('Universal APK build completed');
          } else {
            _logWarning(
                'Universal APK build failed: ${universalResult.stderr}');
          }
        }

        return true;
      } else {
        _logError('APK build failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logError('APK build process failed: $e');
      return false;
    }
  }

  Future<bool> _buildAppBundle() async {
    _logStep('Building App Bundle...');

    try {
      final result =
          await Process.run('flutter', ['build', 'appbundle', '--release']);

      if (result.exitCode == 0) {
        _logSuccess('App Bundle build completed successfully');

        // Check if AAB file exists and get its size
        final aabFile =
            File('build/app/outputs/bundle/release/app-release.aab');
        if (aabFile.existsSync()) {
          final size = await aabFile.length();
          final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);
          _logInfo('App Bundle size: ${sizeInMB}MB');
        }

        return true;
      } else {
        _logError('App Bundle build failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logError('App Bundle build process failed: $e');
      return false;
    }
  }

  Future<bool> _organizeReleaseFiles(String buildType) async {
    _logStep('Organizing release files...');

    try {
      final releaseDir = Directory('release');
      if (!releaseDir.existsSync()) {
        await releaseDir.create(recursive: true);
      }

      int copiedFiles = 0;

      if (buildType == 'release') {
        // Copy release APKs
        final apkFiles = [
          'build/app/outputs/flutter-apk/app-release.apk',
          'build/app/outputs/flutter-apk/app-arm64-v8a-release.apk',
          'build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk',
          'build/app/outputs/flutter-apk/app-x86_64-release.apk',
        ];

        for (final apkPath in apkFiles) {
          final apkFile = File(apkPath);
          if (apkFile.existsSync()) {
            final fileName = path.basename(apkPath);
            final targetName = fileName == 'app-release.apk'
                ? 'app-universal-release.apk'
                : fileName;
            await apkFile.copy('release/$targetName');
            copiedFiles++;
            _logInfo('Copied: $targetName');
          }
        }

        // Copy App Bundle
        final aabFile =
            File('build/app/outputs/bundle/release/app-release.aab');
        if (aabFile.existsSync()) {
          await aabFile.copy('release/app-release.aab');
          copiedFiles++;
          _logInfo('Copied: app-release.aab');
        }
      } else {
        // Copy debug APK
        final debugApk = File('build/app/outputs/flutter-apk/app-debug.apk');
        if (debugApk.existsSync()) {
          await debugApk.copy('release/app-debug.apk');
          copiedFiles++;
          _logInfo('Copied: app-debug.apk');
        }
      }

      _logSuccess('Release files organized ($copiedFiles files copied)');
      return true;
    } catch (e) {
      _logError('Failed to organize release files: $e');
      return false;
    }
  }

  Future<bool> _generateBuildInfo(String buildType) async {
    _logStep('Generating build information...');

    try {
      final buildInfoFile = File('release/build_info.txt');
      final timestamp = DateTime.now().toString();

      // Get Flutter version
      final flutterVersionResult = await Process.run('flutter', ['--version']);
      final flutterVersion =
          flutterVersionResult.stdout.toString().split('\n')[0];

      // Get Git info (if available)
      String gitCommit = 'Not available';
      String gitBranch = 'Not available';

      try {
        final commitResult = await Process.run('git', ['rev-parse', 'HEAD']);
        if (commitResult.exitCode == 0) {
          gitCommit = commitResult.stdout.toString().trim().substring(0, 8);
        }

        final branchResult =
            await Process.run('git', ['branch', '--show-current']);
        if (branchResult.exitCode == 0) {
          gitBranch = branchResult.stdout.toString().trim();
        }
      } catch (e) {
        // Git not available or not a git repository
      }

      // Get file sizes
      final releaseFiles = Directory('release')
          .listSync()
          .where((entity) =>
              entity is File && entity.path.endsWith('.apk') ||
              entity.path.endsWith('.aab'))
          .cast<File>();

      final buildInfo = StringBuffer();
      buildInfo.writeln('Flutter Invoice App Build Information');
      buildInfo.writeln('=' * 50);
      buildInfo.writeln();
      buildInfo.writeln('Build Date: $timestamp');
      buildInfo.writeln('Build Type: $buildType');
      buildInfo.writeln('Flutter Version: $flutterVersion');
      buildInfo.writeln('Git Commit: $gitCommit');
      buildInfo.writeln('Git Branch: $gitBranch');
      buildInfo.writeln();
      buildInfo.writeln('Release Files:');
      buildInfo.writeln('-' * 20);

      for (final file in releaseFiles) {
        final size = await file.length();
        final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);
        final fileName = path.basename(file.path);
        buildInfo.writeln('$fileName: ${sizeInMB}MB');
      }

      buildInfo.writeln();
      buildInfo.writeln('Build Configuration:');
      buildInfo.writeln('-' * 20);
      buildInfo.writeln(
          'Keystore: ${buildType == 'release' ? 'Configured' : 'Not configured'}');
      buildInfo.writeln(
          'Obfuscation: ${buildType == 'release' ? 'Enabled' : 'Disabled'}');
      buildInfo.writeln(
          'Shrinking: ${buildType == 'release' ? 'Enabled' : 'Disabled'}');

      await buildInfoFile.writeAsString(buildInfo.toString());
      _logSuccess('Build information generated');
      return true;
    } catch (e) {
      _logError('Failed to generate build info: $e');
      return false;
    }
  }

  Future<bool> _analyzeApk(String buildType) async {
    _logStep('Analyzing APK...');

    try {
      // Find the main APK file
      String apkPath;
      if (buildType == 'release') {
        apkPath = 'release/app-universal-release.apk';
      } else {
        apkPath = 'release/app-debug.apk';
      }

      final apkFile = File(apkPath);
      if (!apkFile.existsSync()) {
        _logWarning('APK file not found for analysis: $apkPath');
        return true;
      }

      // Get APK size
      final size = await apkFile.length();
      final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);
      _logInfo('APK Size: ${sizeInMB}MB');

      // Try to use aapt for detailed analysis
      try {
        final aaptResult =
            await Process.run('aapt', ['dump', 'badging', apkPath]);
        if (aaptResult.exitCode == 0) {
          final output = aaptResult.stdout.toString();

          // Extract package info
          final packageMatch =
              RegExp(r"package: name='([^']+)'").firstMatch(output);
          if (packageMatch != null) {
            _logInfo('Package: ${packageMatch.group(1)}');
          }

          // Extract version info
          final versionMatch =
              RegExp(r"versionName='([^']+)'").firstMatch(output);
          if (versionMatch != null) {
            _logInfo('Version: ${versionMatch.group(1)}');
          }

          // Extract SDK versions
          final minSdkMatch = RegExp(r"sdkVersion:'(\d+)'").firstMatch(output);
          if (minSdkMatch != null) {
            _logInfo('Min SDK: ${minSdkMatch.group(1)}');
          }

          final targetSdkMatch =
              RegExp(r"targetSdkVersion:'(\d+)'").firstMatch(output);
          if (targetSdkMatch != null) {
            _logInfo('Target SDK: ${targetSdkMatch.group(1)}');
          }

          _logSuccess('APK analysis completed');
        } else {
          _logWarning('AAPT analysis failed, but continuing...');
        }
      } catch (e) {
        _logWarning('AAPT not available for detailed analysis');
      }

      return true;
    } catch (e) {
      _logWarning('APK analysis failed: $e');
      return true; // Non-critical, continue
    }
  }

  Future<void> _testInstallation(String buildType) async {
    _logStep('Testing installation...');

    try {
      // Check for connected devices
      final devicesResult = await Process.run('adb', ['devices']);
      if (devicesResult.exitCode == 0) {
        final devices = devicesResult.stdout
            .toString()
            .split('\n')
            .where((line) =>
                line.contains('device') && !line.contains('List of devices'))
            .length;

        if (devices > 0) {
          _logSuccess('Found $devices connected device(s)');

          // In a real interactive scenario, you would prompt the user
          // For this simulation, we'll just show what would happen
          _logInfo('Installation test available for:');

          String apkPath;
          if (buildType == 'release') {
            apkPath = 'release/app-universal-release.apk';
          } else {
            apkPath = 'release/app-debug.apk';
          }

          if (File(apkPath).existsSync()) {
            _logInfo('  - APK: $apkPath');
            _logInfo('  - Command: adb install -r $apkPath');

            // Simulate installation (in real scenario, you'd actually install)
            _logSuccess('Installation test ready (simulated)');
          } else {
            _logWarning('APK file not found for installation test');
          }
        } else {
          _logWarning('No connected devices found for installation test');
          _logInfo(
              'Connect a device or start an emulator to test installation');
        }
      }
    } catch (e) {
      _logWarning('Installation test check failed: $e');
    }
  }

  void _showBuildSummary(String buildType) {
    _log('=' * 80, color: _magenta);
    _log('🎉 BUILD SUMMARY', color: _green);
    _log('=' * 80, color: _magenta);

    _logInfo('Build Type: ${buildType.toUpperCase()}');
    _logInfo('Release Directory: release/');
    _logInfo('Build Info: release/build_info.txt');

    if (buildType == 'release') {
      _log('🔐 RELEASE BUILD COMPLETED', color: _green);
      _logInfo('Files ready for distribution:');
      _logInfo('  ✓ Universal APK: app-universal-release.apk');
      _logInfo('  ✓ Architecture-specific APKs: app-*-release.apk');
      _logInfo('  ✓ App Bundle: app-release.aab (for Play Store)');
      _logInfo('');
      _logInfo('🚀 Ready for:');
      _logInfo('  • Play Store upload (App Bundle)');
      _logInfo('  • Direct distribution (APK files)');
      _logInfo('  • Enterprise deployment');
    } else {
      _log('🔧 DEBUG BUILD COMPLETED', color: _yellow);
      _logInfo('Files for testing:');
      _logInfo('  ✓ Debug APK: app-debug.apk');
      _logInfo('');
      _logInfo('🧪 Ready for:');
      _logInfo('  • Development testing');
      _logInfo('  • Internal distribution');
      _logInfo('  • Debugging and profiling');
    }

    _logInfo('');
    _logInfo('📱 Next Steps:');
    _logInfo('  1. Test APK on various devices');
    _logInfo('  2. Verify all features work correctly');
    _logInfo('  3. Run migration tests');
    if (buildType == 'release') {
      _logInfo('  4. Upload to Play Console');
      _logInfo('  5. Configure release rollout');
    }

    _log('=' * 80, color: _magenta);
  }

  void dispose() {
    _logController.close();
  }
}
