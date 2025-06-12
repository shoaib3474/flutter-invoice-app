#!/bin/bash
echo "Starting complete project reset..."

echo "Cleaning Flutter project..."
flutter clean

echo "Removing generated files..."
rm -rf .dart_tool build .idea .vscode pubspec.lock .flutter-plugins .flutter-plugins-dependencies .packages

echo "Creating minimal pubspec.yaml..."
cat > pubspec.yaml << EOL
name: flutter_invoice_app
description: A comprehensive GST invoice management application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=2.19.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.3

flutter:
  uses-material-design: true
EOL

echo "Getting dependencies..."
flutter pub get

echo "Creating minimal main.dart..."
mkdir -p lib
cat > lib/main.dart << EOL
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Invoice App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Invoice App Home'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Flutter Invoice App'),
      ),
    );
  }
}
EOL

echo "Creating minimal analysis_options.yaml..."
cat > analysis_options.yaml << EOL
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_final_fields: false
EOL

echo "Creating asset directories..."
mkdir -p assets/images assets/icons assets/sample_data assets/config fonts

echo "Creating placeholder files..."
touch assets/images/.gitkeep
touch assets/icons/.gitkeep
touch assets/sample_data/.gitkeep
touch assets/config/.gitkeep

echo "Running flutter doctor..."
flutter doctor -v

echo "Complete reset finished!"
echo "You can now rebuild your project from scratch."
