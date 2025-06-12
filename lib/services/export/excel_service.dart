import 'dart:io';
import 'dart:typed_data';

// import 'package:excel/excel.dart'; // Replaced with mock
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/gst_returns/gstr1_model.dart';
import '../../models/gst_returns/gstr3b_model.dart';
import '../../models/gst_returns/gstr9_model.dart';
import '../../models/reconciliation/reconciliation_result_model.dart';

// Mock Excel classes
class Excel {
  String? filename;

  Excel.createExcel();

  Sheet operator [](String sheetName) {
    return Sheet();
  }

  void delete(String sheetName) {}

  List<int>? encode() {
    return null;
  }
}

class Sheet {
  int maxRows = 0;

  Cell cell(CellIndex cellIndex) {
    return Cell();
  }

  void appendRow(List<dynamic> row) {
    maxRows++;
  }
}

class CellIndex {
  final int columnIndex;
  final int rowIndex;

  CellIndex.indexByColumnRow({required this.columnIndex, required this.rowIndex});
}

class Cell {
  dynamic value;
  CellStyle? cellStyle;
}

class CellStyle {
  bool? bold;
  String? backgroundColorHex;
  HorizontalAlign? horizontalAlign;

  CellStyle({this.bold, this.backgroundColorHex, this.horizontalAlign});
}

enum HorizontalAlign {
  Left,
  Center,
  Right,
}

class TextCellValue {
  final String text;
  TextCellValue(this.text);
}

class ExcelService {
  static final ExcelService _instance = ExcelService._internal();

  factory ExcelService() {
    return _instance;
  }

  ExcelService._internal();

  // Generate Excel for GSTR1
  Future<Uint8List> generateGstr1Excel(GSTR1 gstr1) async {
    final excel = Excel.createExcel();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Remove the default sheet
    excel.delete('Sheet1');

    // Create Summary sheet
    final summarySheet = excel['Summary'];
    _addHeaderRow(summarySheet, ['GSTR-1 Return Summary', '', '', '']);
    _addDataRow(summarySheet, ['GSTIN', gstr1.gstin, '', '']);
    _addDataRow(summarySheet, ['Return Period', gstr1.returnPeriod, '', '']);
    _addDataRow(summarySheet, ['Status', gstr1.status, '', '']);
    _addDataRow(summarySheet, ['Filing Date', dateFormat.format(gstr1.filingDate), '', '']);
    _addEmptyRow(summarySheet);

    _addHeaderRow(summarySheet, ['Description', 'Value', '', '']);
    _addDataRow(summarySheet, ['Total Taxable Value', currencyFormat.format(gstr1.totalTaxableValue), '', '']);
    _addDataRow(summarySheet, ['Total IGST', currencyFormat.format(gstr1.totalIgst), '', '']);
    _addDataRow(summarySheet, ['Total CGST', currencyFormat.format(gstr1.totalCgst), '', '']);
    _addDataRow(summarySheet, ['Total SGST', currencyFormat.format(gstr1.totalSgst), '', '']);
    _addDataRow(summarySheet, ['B2B Invoice Count', gstr1.b2bInvoices.length.toString(), '', '']);
    _addDataRow(summarySheet, ['B2CL Invoice Count', gstr1.b2clInvoices.length.toString(), '', '']);
    _addDataRow(summarySheet, ['B2CS Invoice Count', gstr1.b2csInvoices.length.toString(), '', '']);
    _addDataRow(summarySheet, ['Export Invoice Count', gstr1.exportInvoices.length.toString(), '', '']);

    // Create B2B Invoices sheet
    final b2bSheet = excel['B2B Invoices'];
    _addHeaderRow(b2bSheet, [
      'Invoice No.',
      'Date',
      'GSTIN',
      'Customer Name',
      'Place of Supply',
      'Taxable Value',
      'IGST',
      'CGST',
      'SGST',
      'Cess',
      'Reverse Charge',
      'Invoice Type'
    ]);

    for (var invoice in gstr1.b2bInvoices) {
      _addDataRow(b2bSheet, [
        invoice.invoiceNumber,
        dateFormat.format(invoice.invoiceDate),
        invoice.counterpartyGstin,
        invoice.counterpartyName,
        invoice.placeOfSupply,
        invoice.taxableValue.toString(),
        invoice.igstAmount.toString(),
        invoice.cgstAmount.toString(),
        invoice.sgstAmount.toString(),
        invoice.cessAmount.toString(),
        invoice.reverseCharge ? 'Yes' : 'No',
        invoice.invoiceType
      ]);
    }

    // Create B2CL Invoices sheet
    final b2clSheet = excel['B2CL Invoices'];
    _addHeaderRow(b2clSheet, [
      'Invoice No.',
      'Date',
      'Place of Supply',
      'Taxable Value',
      'IGST',
      'CGST',
      'SGST',
      'Cess'
    ]);

    for (var invoice in gstr1.b2clInvoices) {
      _addDataRow(b2clSheet, [
        invoice.invoiceNumber,
        dateFormat.format(invoice.invoiceDate),
        invoice.placeOfSupply,
        invoice.taxableValue.toString(),
        invoice.igstAmount.toString(),
        invoice.sgstAmount.toString(),
        invoice.cessAmount.toString()
      ]);
    }

    // Create B2CS Invoices sheet
    final b2csSheet = excel['B2CS Invoices'];
    _addHeaderRow(b2csSheet, [
      'Type',
      'Place of Supply',
      'Taxable Value',
      'IGST',
      'CGST',
      'SGST',
      'Cess'
    ]);

    for (var invoice in gstr1.b2csInvoices) {
      _addDataRow(b2csSheet, [
        invoice.type,
        invoice.placeOfSupply,
        invoice.taxableValue.toString(),
        invoice.igstAmount.toString(),
        invoice.sgstAmount.toString(),
        invoice.cessAmount.toString()
      ]);
    }

    // Create Export Invoices sheet
    final exportSheet = excel['Export Invoices'];
    _addHeaderRow(exportSheet, [
      'Invoice No.',
      'Date',
      'Taxable Value',
      'IGST',
      'Shipping Bill No.',
      'Shipping Bill Date',
      'Port Code',
      'Export Type'
    ]);

    for (var invoice in gstr1.exportInvoices) {
      _addDataRow(exportSheet, [
        invoice.invoiceNumber,
        dateFormat.format(invoice.invoiceDate),
        invoice.taxableValue.toString(),
        invoice.igstAmount.toString(),
        invoice.shippingBillNumber,
        dateFormat.format(invoice.shippingBillDate),
        invoice.portCode,
        invoice.exportType
      ]);
    }

    return excel.encode()!;
  }

  // Generate Excel for GSTR3B
  Future<Uint8List> generateGstr3bExcel(GSTR3B gstr3b) async {
    final excel = Excel.createExcel();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Remove the default sheet
    excel.delete('Sheet1');

    // Create Summary sheet
    final summarySheet = excel['Summary'];
    _addHeaderRow(summarySheet, ['GSTR-3B Return Summary', '', '', '']);
    _addDataRow(summarySheet, ['GSTIN', gstr3b.gstin, '', '']);
    _addDataRow(summarySheet, ['Return Period', gstr3b.returnPeriod, '', '']);
    _addDataRow(summarySheet, ['Status', gstr3b.status, '', '']);
    _addDataRow(summarySheet, ['Filing Date', dateFormat.format(gstr3b.filingDate), '', '']);
    _addEmptyRow(summarySheet);

    // Outward Supplies
    _addHeaderRow(summarySheet, ['Outward Supplies', '', '', '']);
    _addDataRow(summarySheet, ['Taxable Outward Supplies', currencyFormat.format(gstr3b.outwardSupplies.taxableOutwardSupplies), '', '']);
    _addDataRow(summarySheet, ['Zero Rated Supplies', currencyFormat.format(gstr3b.outwardSupplies.taxableOutwardSuppliesZeroRated), '', '']);
    _addDataRow(summarySheet, ['Nil Rated Supplies', currencyFormat.format(gstr3b.outwardSupplies.taxableOutwardSuppliesNilRated), '', '']);
    _addDataRow(summarySheet, ['Non-GST Outward Supplies', currencyFormat.format(gstr3b.outwardSupplies.nonGstOutwardSupplies), '', '']);
    _addDataRow(summarySheet, ['Intra-State Supplies', currencyFormat.format(gstr3b.outwardSupplies.intraStateSupplies), '', '']);
    _addDataRow(summarySheet, ['Inter-State Supplies', currencyFormat.format(gstr3b.outwardSupplies.interStateSupplies), '', '']);
    _addEmptyRow(summarySheet);

    // Tax Details
    _addHeaderRow(summarySheet, ['Tax Details (Outward)', '', '', '']);
    _addDataRow(summarySheet, ['IGST', currencyFormat.format(gstr3b.outwardSupplies.igstAmount), '', '']);
    _addDataRow(summarySheet, ['CGST', currencyFormat.format(gstr3b.outwardSupplies.cgstAmount), '', '']);
    _addDataRow(summarySheet, ['SGST', currencyFormat.format(gstr3b.outwardSupplies.sgstAmount), '', '']);
    _addDataRow(summarySheet, ['Cess', currencyFormat.format(gstr3b.outwardSupplies.cessAmount), '', '']);
    _addEmptyRow(summarySheet);

    // Inward Supplies
    _addHeaderRow(summarySheet, ['Inward Supplies', '', '', '']);
    _addDataRow(summarySheet, ['Reverse Charge Supplies', currencyFormat.format(gstr3b.inwardSupplies.reverseChargeSupplies), '', '']);
    _addDataRow(summarySheet, ['Import of Goods', currencyFormat.format(gstr3b.inwardSupplies.importOfGoods), '', '']);
    _addDataRow(summarySheet, ['Import of Services', currencyFormat.format(gstr3b.inwardSupplies.importOfServices), '', '']);
    _addDataRow(summarySheet, ['Ineligible ITC', currencyFormat.format(gstr3b.inwardSupplies.ineligibleITC), '', '']);
    _addDataRow(summarySheet, ['Eligible ITC', currencyFormat.format(gstr3b.inwardSupplies.eligibleITC), '', '']);
    _addEmptyRow(summarySheet);

    // Tax Details (Inward)
    _addHeaderRow(summarySheet, ['Tax Details (Inward)', '', '', '']);
    _addDataRow(summarySheet, ['IGST', currencyFormat.format(gstr3b.inwardSupplies.igstAmount), '', '']);
    _addDataRow(summarySheet, ['CGST', currencyFormat.format(gstr3b.inwardSupplies.cgstAmount), '', '']);
    _addDataRow(summarySheet, ['SGST', currencyFormat.format(gstr3b.inwardSupplies.sgstAmount), '', '']);
    _addDataRow(summarySheet, ['Cess', currencyFormat.format(gstr3b.inwardSupplies.cessAmount), '', '']);
    _addEmptyRow(summarySheet);

    // ITC Details
    _addHeaderRow(summarySheet, ['ITC Details', '', '', '']);
    _addDataRow(summarySheet, ['ITC Availed', currencyFormat.format(gstr3b.itcDetails.itcAvailed), '', '']);
    _addDataRow(summarySheet, ['ITC Reversed', currencyFormat.format(gstr3b.itcDetails.itcReversed), '', '']);
    _addDataRow(summarySheet, ['Net ITC', currencyFormat.format(gstr3b.itcDetails.itcNet), '', '']);
    _addDataRow(summarySheet, ['Ineligible ITC', currencyFormat.format(gstr3b.itcDetails.ineligibleITC), '', '']);
    _addEmptyRow(summarySheet);

    // Tax Payment
    _addHeaderRow(summarySheet, ['Tax Payment', '', '', '']);
    _addDataRow(summarySheet, ['IGST Amount', currencyFormat.format(gstr3b.taxPayment.igstAmount), '', '']);
    _addDataRow(summarySheet, ['CGST Amount', currencyFormat.format(gstr3b.taxPayment.cgstAmount), '', '']);
    _addDataRow(summarySheet, ['SGST Amount', currencyFormat.format(gstr3b.taxPayment.sgstAmount), '', '']);
    _addDataRow(summarySheet, ['Cess Amount', currencyFormat.format(gstr3b.taxPayment.cessAmount), '', '']);
    _addDataRow(summarySheet, ['Interest Amount', currencyFormat.format(gstr3b.taxPayment.interestAmount), '', '']);
    _addDataRow(summarySheet, ['Late Fees Amount', currencyFormat.format(gstr3b.taxPayment.lateFeesAmount), '', '']);
    _addDataRow(summarySheet, ['Penalty Amount', currencyFormat.format(gstr3b.taxPayment.penaltyAmount), '', '']);
    _addDataRow(summarySheet, ['Total Amount', currencyFormat.format(gstr3b.taxPayment.totalAmount), '', '']);

    return excel.encode()!;
  }

  // Generate Excel for reconciliation results
  Future<Uint8List> generateReconciliationExcel(ReconciliationResult result) async {
    final excel = Excel.createExcel();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    // Remove the default sheet
    excel.delete('Sheet1');

    // Create Summary sheet
    final summarySheet = excel['Summary'];
    _addHeaderRow(summarySheet, ['Reconciliation Report Summary', '', '', '']);
    _addDataRow(summarySheet, ['Total Invoices', result.summary.totalInvoices.toString(), '', '']);
    _addDataRow(summarySheet, ['Matched Invoices', result.summary.matchedInvoices.toString(), '', '']);
    _addDataRow(summarySheet, ['Partially Matched Invoices', result.summary.partiallyMatchedInvoices.toString(), '', '']);
    _addDataRow(summarySheet, ['Unmatched Invoices', result.summary.unmatchedInvoices.toString(), '', '']);
    _addDataRow(summarySheet, ['Only in Source 1', result.summary.onlyInSource1Invoices.toString(), '', '']);
    _addDataRow(summarySheet, ['Only in Source 2', result.summary.onlyInSource2Invoices.toString(), '', '']);
    _addEmptyRow(summarySheet);

    // Financial Summary
    _addHeaderRow(summarySheet, ['Financial Summary', '', '', '']);
    _addDataRow(summarySheet, [
      'Description',
      'Source 1',
      'Source 2',
      'Difference'
    ]);
    _addDataRow(summarySheet, [
      'Taxable Value',
      currencyFormat.format(result.summary.totalTaxableValueInSource1),
      currencyFormat.format(result.summary.totalTaxableValueInSource2),
      currencyFormat.format(result.summary.totalTaxableValueInSource1 - result.summary.totalTaxableValueInSource2)
    ]);
    _addDataRow(summarySheet, [
      'Total Tax',
      currencyFormat.format(result.summary.totalTaxInSource1),
      currencyFormat.format(result.summary.totalTaxInSource2),
      currencyFormat.format(result.summary.taxDifference)
    ]);

    // Create Details sheet
    final detailsSheet = excel['Details'];
    _addHeaderRow(detailsSheet, [
      'Invoice No.',
      'Invoice Date',
      'GSTIN',
      'Name',
      'Match Status',
      'Taxable Value (Source 1)',
      'Taxable Value (Source 2)',
      'IGST (Source 1)',
      'IGST (Source 2)',
      'CGST (Source 1)',
      'CGST (Source 2)',
      'SGST (Source 1)',
      'SGST (Source 2)',
      'Remarks'
    ]);

    for (var item in result.items) {
      _addDataRow(detailsSheet, [
        item.invoiceNumber,
        item.invoiceDate,
        item.counterpartyGstin,
        item.counterpartyName,
        item.matchStatus,
        item.taxableValueInSource1.toString(),
        item.taxableValueInSource2.toString(),
        item.igstInSource1.toString(),
        item.igstInSource2.toString(),
        item.cgstInSource1.toString(),
        item.cgstInSource2.toString(),
        item.sgstInSource1.toString(),
        item.sgstInSource2.toString(),
        item.remarks
      ]);
    }

    // Create Discrepancies sheet
    final discrepanciesSheet = excel['Discrepancies'];
    _addHeaderRow(discrepanciesSheet, [
      'Invoice No.',
      'Invoice Date',
      'GSTIN',
      'Name',
      'Match Status',
      'Taxable Value (Source 1)',
      'Taxable Value (Source 2)',
      'Difference',
      'Remarks'
    ]);

    // Filter to show only discrepancies
    final discrepancies = result.items.where((item) => item.matchStatus != 'Matched').toList();
    
    for (var item in discrepancies) {
      _addDataRow(discrepanciesSheet, [
        item.invoiceNumber,
        item.invoiceDate,
        item.counterpartyGstin,
        item.counterpartyName,
        item.matchStatus,
        item.taxableValueInSource1.toString(),
        item.taxableValueInSource2.toString(),
        (item.taxableValueInSource1 - item.taxableValueInSource2).toString(),
        item.remarks
      ]);
    }

    return excel.encode()!;
  }

  // Save Excel to file and return the file path
  Future<String> saveExcel(Uint8List excelData, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(excelData);
    return file.path;
  }

  // Share Excel file
  Future<void> shareExcel(Uint8List excelData, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(excelData);
    await Share.shareXFiles([XFile(file.path)], text: 'Sharing $fileName');
  }

  // Open Excel file
  Future<void> openExcel(Uint8List excelData, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(excelData);
    await OpenFile.open(file.path);
  }

  // Helper methods for building Excel components
  void _addHeaderRow(Sheet sheet, List<String> values) {
    final rowIndex = sheet.maxRows;
    for (var i = 0; i < values.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
      cell.value = TextCellValue(values[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#DDDDDD',
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }

  void _addDataRow(Sheet sheet, List<String> values) {
    final rowIndex = sheet.maxRows;
    for (var i = 0; i < values.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
      cell.value = TextCellValue(values[i]);
    }
  }

  void _addEmptyRow(Sheet sheet) {
    sheet.appendRow([]);
  }
}
