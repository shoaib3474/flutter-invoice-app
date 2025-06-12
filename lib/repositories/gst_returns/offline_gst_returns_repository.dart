import 'dart:convert';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/repositories/base/offline_repository.dart';

class OfflineGSTR1Repository extends OfflineRepository<GSTR1> {
  @override
  String get tableName => 'gstr1';
  
  @override
  String get entityType => 'gstr1';
  
  @override
  Map<String, dynamic> entityToMap(GSTR1 entity) {
    final map = {
      'gstin': entity.gstin,
      'return_period': entity.returnPeriod,
      'data': jsonEncode({
        'b2bInvoices': entity.b2bInvoices.map((e) => e.toJson()).toList(),
        'b2clInvoices': entity.b2clInvoices.map((e) => e.toJson()).toList(),
        'b2csInvoices': entity.b2csInvoices.map((e) => e.toJson()).toList(),
        'exportInvoices': entity.exportInvoices.map((e) => e.toJson()).toList(),
        'totalTaxableValue': entity.totalTaxableValue,
        'totalIgst': entity.totalIgst,
        'totalCgst': entity.totalCgst,
        'totalSgst': entity.totalSgst,
      }),
      'status': entity.status,
      'filing_date': entity.filingDate.toIso8601String(),
    };
    
    return map;
  }
  
  @override
  GSTR1 mapToEntity(Map<String, dynamic> map) {
    final dataMap = jsonDecode(map['data']);
    
    return GSTR1(
      gstin: map['gstin'],
      returnPeriod: map['return_period'],
      b2bInvoices: (dataMap['b2bInvoices'] as List)
          .map((e) => B2BInvoice.fromJson(e))
          .toList(),
      b2clInvoices: (dataMap['b2clInvoices'] as List)
          .map((e) => B2CLInvoice.fromJson(e))
          .toList(),
      b2csInvoices: (dataMap['b2csInvoices'] as List)
          .map((e) => B2CSInvoice.fromJson(e))
          .toList(),
      exportInvoices: (dataMap['exportInvoices'] as List)
          .map((e) => ExportInvoice.fromJson(e))
          .toList(),
      totalTaxableValue: dataMap['totalTaxableValue'],
      totalIgst: dataMap['totalIgst'],
      totalCgst: dataMap['totalCgst'],
      totalSgst: dataMap['totalSgst'],
      status: map['status'],
      filingDate: DateTime.parse(map['filing_date']),
    );
  }
  
  @override
  String getEntityId(GSTR1 entity) {
    // Use a combination of GSTIN and return period as the ID
    return '${entity.gstin}_${entity.returnPeriod}';
  }
  
  // Get GSTR1 by GSTIN and return period
  Future<GSTR1?> getByGstinAndPeriod(String gstin, String returnPeriod) async {
    final id = '${gstin}_${returnPeriod}';
    return await getById(id);
  }
  
  // Get all GSTR1 for a GSTIN
  Future<List<GSTR1>> getAllForGstin(String gstin) async {
    return await query(
      where: 'gstin = ?',
      whereArgs: [gstin],
      orderBy: 'return_period DESC',
    );
  }
}
