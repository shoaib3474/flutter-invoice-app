import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class JsonService {
  static final JsonService _instance = JsonService._internal();

  factory JsonService() {
    return _instance;
  }

  JsonService._internal();

  // Convert any object to JSON
  String toJson(dynamic object) {
    return JsonEncoder.withIndent('  ').convert(object);
  }

  // Parse JSON string to Map
  Map<String, dynamic> fromJson(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // Save JSON to file and return the file path
  Future<String> saveJson(dynamic object, String fileName) async {
    final jsonString = toJson(object);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsString(jsonString);
    return file.path;
  }

  // Share JSON file
  Future<void> shareJson(dynamic object, String fileName) async {
    final jsonString = toJson(object);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], text: 'Sharing $fileName');
  }

  // Open JSON file
  Future<void> openJson(dynamic object, String fileName) async {
    final jsonString = toJson(object);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsString(jsonString);
    await OpenFile.open(file.path);
  }

  // Read JSON from file
  Future<Map<String, dynamic>> readJsonFromFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return fromJson(jsonString);
    } else {
      throw Exception('File does not exist: $filePath');
    }
  }
}
