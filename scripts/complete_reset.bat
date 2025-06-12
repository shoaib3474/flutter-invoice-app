@echo off
echo Starting complete project reset...

echo Cleaning Flutter project...
flutter clean

echo Removing generated files...
if exist .dart_tool rmdir /s /q .dart_tool
if exist build rmdir /s /q build
if exist .idea rmdir /s /q .idea
if exist .vscode rmdir /s /q .vscode
if exist pubspec.lock del pubspec.lock
if exist .flutter-plugins del .flutter-plugins
if exist .flutter-plugins-dependencies del .flutter-plugins-dependencies
if exist .packages del .packages

echo Creating minimal pubspec.yaml...
echo name: flutter_invoice_app > pubspec.yaml
echo description: A comprehensive GST invoice management application >> pubspec.yaml
echo publish_to: 'none' >> pubspec.yaml
echo version: 1.0.0+1 >> pubspec.yaml
echo. >> pubspec.yaml
echo environment: >> pubspec.yaml
echo   sdk: '>=2.19.0 ^<4.0.0' >> pubspec.yaml
echo. >> pubspec.yaml
echo dependencies: >> pubspec.yaml
echo   flutter: >> pubspec.yaml
echo     sdk: flutter >> pubspec.yaml
echo   cupertino_icons: ^1.0.5 >> pubspec.yaml
echo. >> pubspec.yaml
echo dev_dependencies: >> pubspec.yaml
echo   flutter_test: >> pubspec.yaml
echo     sdk: flutter >> pubspec.yaml
echo   flutter_lints: ^2.0.3 >> pubspec.yaml
echo. >> pubspec.yaml
echo flutter: >> pubspec.yaml
echo   uses-material-design: true >> pubspec.yaml

echo Getting dependencies...
flutter pub get

echo Creating minimal main.dart...
if not exist lib mkdir lib
echo import 'package:flutter/material.dart'; > lib\main.dart
echo. >> lib\main.dart
echo void main() { >> lib\main.dart
echo   runApp(const MyApp()); >> lib\main.dart
echo } >> lib\main.dart
echo. >> lib\main.dart
echo class MyApp extends StatelessWidget { >> lib\main.dart
echo   const MyApp({Key? key}) : super(key: key); >> lib\main.dart
echo. >> lib\main.dart
echo   @override >> lib\main.dart
echo   Widget build(BuildContext context) { >> lib\main.dart
echo     return MaterialApp( >> lib\main.dart
echo       title: 'Flutter Invoice App', >> lib\main.dart
echo       theme: ThemeData( >> lib\main.dart
echo         primarySwatch: Colors.blue, >> lib\main.dart
echo       ), >> lib\main.dart
echo       home: const MyHomePage(title: 'Flutter Invoice App Home'), >> lib\main.dart
echo     ); >> lib\main.dart
echo   } >> lib\main.dart
echo } >> lib\main.dart
echo. >> lib\main.dart
echo class MyHomePage extends StatelessWidget { >> lib\main.dart
echo   final String title; >> lib\main.dart
echo   const MyHomePage({Key? key, required this.title}) : super(key: key); >> lib\main.dart
echo. >> lib\main.dart
echo   @override >> lib\main.dart
echo   Widget build(BuildContext context) { >> lib\main.dart
echo     return Scaffold( >> lib\main.dart
echo       appBar: AppBar( >> lib\main.dart
echo         title: Text(title), >> lib\main.dart
echo       ), >> lib\main.dart
echo       body: Center( >> lib\main.dart
echo         child: Text('Flutter Invoice App'), >> lib\main.dart
echo       ), >> lib\main.dart
echo     ); >> lib\main.dart
echo   } >> lib\main.dart
echo } >> lib\main.dart

echo Creating minimal analysis_options.yaml...
echo include: package:flutter_lints/flutter.yaml > analysis_options.yaml
echo. >> analysis_options.yaml
echo linter: >> analysis_options.yaml
echo   rules: >> analysis_options.yaml
echo     prefer_final_fields: false >> analysis_options.yaml

echo Creating asset directories...
if not exist assets mkdir assets
if not exist assets\images mkdir assets\images
if not exist assets\icons mkdir assets\icons
if not exist assets\sample_data mkdir assets\sample_data
if not exist assets\config mkdir assets\config
if not exist fonts mkdir fonts

echo Creating placeholder files...
echo // Placeholder > assets\images\.gitkeep
echo // Placeholder > assets\icons\.gitkeep
echo // Placeholder > assets\sample_data\.gitkeep
echo // Placeholder > assets\config\.gitkeep

echo Running flutter doctor...
flutter doctor -v

echo Complete reset finished!
echo You can now rebuild your project from scratch.
