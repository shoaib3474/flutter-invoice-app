import 'dart:convert';
import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:flutter_invoice_app/models/sync/sync_operation.dart';
import 'package:flutter_invoice_app/models/sync/sync_status.dart';
import 'package:flutter_invoice_app/services/sync/sync_service.dart';
import 'package:uuid/uuid.dart';

abstract class OfflineRepository<T> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = Uuid();
  
  // Table name in the database
  String get tableName;
  
  // Entity type for sync
  String get entityType;
  
  // Convert entity to map
  Map<String, dynamic> entityToMap(T entity);
  
  // Convert map to entity
  T mapToEntity(Map<String, dynamic> map);
  
  // Get entity ID
  String getEntityId(T entity);
  
  // Create entity
  Future<T> create(T entity) async {
    // Generate ID if needed
    String id = getEntityId(entity);
    if (id.isEmpty) {
      id = _uuid.v4();
    }
    
    // Convert entity to map
    Map<String, dynamic> map = entityToMap(entity);
    
    // Add metadata
    map['id'] = id;
    map['sync_status'] = SyncStatus.pending.toString();
    map['last_modified'] = DateTime.now().millisecondsSinceEpoch;
    map['is_deleted'] = 0;
    
    // Insert into database
    await _dbHelper.insert(tableName, map);
    
    // Add to sync queue
    await _syncService.addToSyncQueue(
      entityType,
      id,
      SyncOperation.create,
      map,
    );
    
    // Return updated entity
    return mapToEntity(map);
  }
  
  // Get entity by ID
  Future<T?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      tableName,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return mapToEntity(maps.first);
  }
  
  // Get all entities
  Future<List<T>> getAll() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      tableName,
      where: 'is_deleted = 0',
    );
    
    return maps.map((map) => mapToEntity(map)).toList();
  }
  
  // Update entity
  Future<T> update(T entity) async {
    // Get entity ID
    String id = getEntityId(entity);
    
    // Convert entity to map
    Map<String, dynamic> map = entityToMap(entity);
    
    // Add metadata
    map['id'] = id;
    map['sync_status'] = SyncStatus.pending.toString();
    map['last_modified'] = DateTime.now().millisecondsSinceEpoch;
    
    // Update in database
    await _dbHelper.update(
      tableName,
      map,
      'id = ?',
      [id],
    );
    
    // Add to sync queue
    await _syncService.addToSyncQueue(
      entityType,
      id,
      SyncOperation.update,
      map,
    );
    
    // Return updated entity
    return mapToEntity(map);
  }
  
  // Delete entity
  Future<bool> delete(String id) async {
    // Mark as deleted
    await _dbHelper.update(
      tableName,
      {
        'is_deleted': 1,
        'sync_status': SyncStatus.pending.toString(),
        'last_modified': DateTime.now().millisecondsSinceEpoch,
      },
      'id = ?',
      [id],
    );
    
    // Add to sync queue
    await _syncService.addToSyncQueue(
      entityType,
      id,
      SyncOperation.delete,
      null,
    );
    
    return true;
  }
  
  // Get entities by query
  Future<List<T>> query({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    // Add is_deleted = 0 to where clause
    String finalWhere = 'is_deleted = 0';
    List<dynamic> finalWhereArgs = [];
    
    if (where != null && where.isNotEmpty) {
      finalWhere = '$finalWhere AND $where';
      if (whereArgs != null) {
        finalWhereArgs.addAll(whereArgs);
      }
    }
    
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      tableName,
      where: finalWhere,
      whereArgs: finalWhereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    
    return maps.map((map) => mapToEntity(map)).toList();
  }
  
  // Get sync status
  Future<SyncStatus> getSyncStatus(String id) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      tableName,
      columns: ['sync_status'],
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return SyncStatus.error;
    }
    
    return SyncStatusExtension.fromString(maps.first['sync_status']);
  }
  
  // Get entities with pending sync
  Future<List<T>> getPendingSync() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      tableName,
      where: 'sync_status = ? AND is_deleted = 0',
      whereArgs: [SyncStatus.pending.toString()],
    );
    
    return maps.map((map) => mapToEntity(map)).toList();
  }
  
  // Import data from JSON
  Future<List<T>> importFromJson(String json) async {
    final List<dynamic> data = jsonDecode(json);
    final List<T> entities = [];
    
    for (var item in data) {
      final entity = mapToEntity(item);
      entities.add(await create(entity));
    }
    
    return entities;
  }
  
  // Export data to JSON
  Future<String> exportToJson() async {
    final List<T> entities = await getAll();
    final List<Map<String, dynamic>> data = entities.map(entityToMap).toList();
    return jsonEncode(data);
  }
}
