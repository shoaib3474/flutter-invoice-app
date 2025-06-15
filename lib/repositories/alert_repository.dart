import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:flutter_invoice_app/models/alerts/alert_configuration_model.dart';
import 'package:flutter_invoice_app/models/alerts/alert_instance_model.dart';
import 'package:sqflite/sqflite.dart';

class AlertRepository {
  AlertRepository(this._databaseHelper);
  final DatabaseHelper _databaseHelper;

  // Alert Configurations
  Future<List<AlertConfiguration>> getAllAlertConfigurations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('alert_configurations');
    return List.generate(maps.length, (i) {
      return AlertConfiguration.fromMap(maps[i]);
    });
  }

  Future<List<AlertConfiguration>> getEnabledAlertConfigurations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alert_configurations',
      where: 'enabled = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return AlertConfiguration.fromMap(maps[i]);
    });
  }

  Future<AlertConfiguration?> getAlertConfigurationById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alert_configurations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AlertConfiguration.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertAlertConfiguration(AlertConfiguration config) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'alert_configurations',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAlertConfiguration(AlertConfiguration config) async {
    final db = await _databaseHelper.database;
    await db.update(
      'alert_configurations',
      config.toMap(),
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  Future<void> deleteAlertConfiguration(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'alert_configurations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Alert Instances
  Future<List<AlertInstance>> getAllAlertInstances() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alert_instances',
      orderBy: 'triggeredAt DESC',
    );
    return List.generate(maps.length, (i) {
      return AlertInstance.fromMap(maps[i]);
    });
  }

  Future<List<AlertInstance>> getUnacknowledgedAlertInstances() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alert_instances',
      where: 'acknowledged = ?',
      whereArgs: [0],
      orderBy: 'triggeredAt DESC',
    );
    return List.generate(maps.length, (i) {
      return AlertInstance.fromMap(maps[i]);
    });
  }

  Future<void> insertAlertInstance(AlertInstance alert) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'alert_instances',
      alert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAlertInstance(AlertInstance alert) async {
    final db = await _databaseHelper.database;
    await db.update(
      'alert_instances',
      alert.toMap(),
      where: 'id = ?',
      whereArgs: [alert.id],
    );
  }

  Future<void> acknowledgeAlert(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'alert_instances',
      {
        'acknowledged': 1,
        'acknowledgedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> acknowledgeAllAlerts() async {
    final db = await _databaseHelper.database;
    await db.update(
      'alert_instances',
      {
        'acknowledged': 1,
        'acknowledgedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'acknowledged = ?',
      whereArgs: [0],
    );
  }

  Future<void> deleteAlertInstance(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'alert_instances',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllAcknowledgedAlerts() async {
    final db = await _databaseHelper.database;
    await db.delete(
      'alert_instances',
      where: 'acknowledged = ?',
      whereArgs: [1],
    );
  }
}
