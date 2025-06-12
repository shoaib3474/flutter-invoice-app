import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:csv/csv.dart';

import '../../models/invoice_formats/bill_shill_invoice_model.dart';
import '../../models/invoice_formats/tally_invoice_model.dart';
import '../../models/invoice_formats/zoho_invoice_model.dart';
import '../../models/invoice_formats/quickbooks_invoice_model.dart';

enum InvoiceFormat {
  billShill,
  tally,
  zoho,
  quickbooks,
  json,
  xml,
  csv,
}

class InvoiceConverterService {
  static final InvoiceConverterService _instance = InvoiceConverterService._internal();

  factory InvoiceConverterService() {
    return _instance;
  }

  InvoiceConverterService._internal();

  // Convert from one format to another
  Future<dynamic> convertInvoice({
    required dynamic sourceInvoice,
    required InvoiceFormat sourceFormat,
    required InvoiceFormat targetFormat,
  }) async {
    // First convert to a common format (BillShill)
    BillShillInvoice commonFormat = await _convertToBillShillFormat(sourceInvoice, sourceFormat);
    
    // Then convert from common format to target format
    return await _convertFromBillShillFormat(commonFormat, targetFormat);
  }

  // Convert file from one format to another
  Future<String> convertInvoiceFile({
    required String sourceFilePath,
    required InvoiceFormat sourceFormat,
    required InvoiceFormat targetFormat,
  }) async {
    // Read the source file
    final File sourceFile = File(sourceFilePath);
    final String sourceContent = await sourceFile.readAsString();
    
    // Parse the source content based on format
    dynamic sourceInvoice;
    switch (sourceFormat) {
      case InvoiceFormat.billShill:
      case InvoiceFormat.json:
        sourceInvoice = BillShillInvoice.fromJson(json.decode(sourceContent));
        break;
      case InvoiceFormat.tally:
        sourceInvoice = _parseTallyXml(sourceContent);
        break;
      case InvoiceFormat.zoho:
        sourceInvoice = ZohoInvoice.fromJson(json.decode(sourceContent));
        break;
      case InvoiceFormat.quickbooks:
        sourceInvoice = QuickbooksInvoice.fromJson(json.decode(sourceContent));
        break;
      case InvoiceFormat.xml:
        sourceInvoice = _parseGenericXml(sourceContent);
        break;
      case InvoiceFormat.csv:
        sourceInvoice = _parseCsv(sourceContent);
        break;
    }
    
    // Convert to target format
    dynamic targetInvoice = await convertInvoice(
      sourceInvoice: sourceInvoice,
      sourceFormat: sourceFormat,
      targetFormat: targetFormat,
    );
    
    // Generate target file content
    String targetContent;
    String fileExtension;
    
    switch (targetFormat) {
      case InvoiceFormat.billShill:
      case InvoiceFormat.json:
        targetContent = json.encode(targetInvoice.toJson());
        fileExtension = '.json';
        break;
      case InvoiceFormat.tally:
        targetContent = _generateTallyXml(targetInvoice);
        fileExtension = '.xml';
        break;
      case InvoiceFormat.zoho:
        targetContent = json.encode(targetInvoice.toJson());
        fileExtension = '.json';
        break;
      case InvoiceFormat.quickbooks:
        targetContent = json.encode(targetInvoice.toJson());
        fileExtension = '.json';
        break;
      case InvoiceFormat.xml:
        targetContent = _generateGenericXml(targetInvoice);
        fileExtension = '.xml';
        break;
      case InvoiceFormat.csv:
        targetContent = _generateCsv(targetInvoice);
        fileExtension = '.csv';
        break;
    }
    
    // Save to a new file
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = 'converted_invoice_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    final String targetFilePath = '${directory.path}/$fileName';
    
    final File targetFile = File(targetFilePath);
    await targetFile.writeAsString(targetContent);
    
    return targetFilePath;
  }

  // Convert to BillShill format (common format)
  Future<BillShillInvoice> _convertToBillShillFormat(dynamic sourceInvoice, InvoiceFormat sourceFormat) async {
    switch (sourceFormat) {
      case InvoiceFormat.billShill:
      case InvoiceFormat.json:
        return sourceInvoice as BillShillInvoice;
      
      case InvoiceFormat.tally:
        final TallyInvoice tallyInvoice = sourceInvoice as TallyInvoice;
        return _tallyToBillShill(tallyInvoice);
      
      case InvoiceFormat.zoho:
        final ZohoInvoice zohoInvoice = sourceInvoice as ZohoInvoice;
        return _zohoToBillShill(zohoInvoice);
      
      case InvoiceFormat.quickbooks:
        final QuickbooksInvoice quickbooksInvoice = sourceInvoice as QuickbooksInvoice;
        return _quickbooksToBillShill(quickbooksInvoice);
      
      case InvoiceFormat.xml:
        // Parse XML to BillShill
        return _xmlToBillShill(sourceInvoice);
      
      case InvoiceFormat.csv:
        // Parse CSV to BillShill
        return _csvToBillShill(sourceInvoice);
      
      default:
        throw Exception('Unsupported source format: $sourceFormat');
    }
  }

  // Convert from BillShill format to target format
  Future<dynamic> _convertFromBillShillFormat(BillShillInvoice billShillInvoice, InvoiceFormat targetFormat) async {
    switch (targetFormat) {
      case InvoiceFormat.billShill:
      case InvoiceFormat.json:
        return billShillInvoice;
      
      case InvoiceFormat.tally:
        return _billShillToTally(billShillInvoice);
      
      case InvoiceFormat.zoho:
        return _billShillToZoho(billShillInvoice);
      
      case InvoiceFormat.quickbooks:
        return _billShillToQuickbooks(billShillInvoice);
      
      case InvoiceFormat.xml:
        // Convert BillShill to XML structure
        return _billShillToXml(billShillInvoice);
      
      case InvoiceFormat.csv:
        // Convert BillShill to CSV structure
        return _billShillToCsv(billShillInvoice);
      
      default:
        throw Exception('Unsupported target format: $targetFormat');
    }
  }

  // Conversion methods between different formats
  BillShillInvoice _tallyToBillShill(TallyInvoice tallyInvoice) {
    List<BillShillInvoiceItem> items = tallyInvoice.items.map((item) {
      return BillShillInvoiceItem(
        itemName: item.stockItemName,
        itemDescription: item.stockItemDescription,
        hsnCode: item.hsnCode,
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: item.rate,
        amount: item.amount,
        taxRate: item.cgstRate + item.sgstRate + item.igstRate,
        taxAmount: item.cgstAmount + item.sgstAmount + item.igstAmount,
        totalAmount: item.totalAmount,
      );
    }).toList();

    return BillShillInvoice(
      invoiceNumber: tallyInvoice.voucherNumber,
      invoiceDate: tallyInvoice.voucherDate,
      customerName: tallyInvoice.partyName,
      customerGstin: tallyInvoice.partyGstin,
      customerAddress: tallyInvoice.partyAddress,
      items: items,
      totalAmount: tallyInvoice.totalAmount,
      totalTaxAmount: tallyInvoice.cgstAmount + tallyInvoice.sgstAmount + tallyInvoice.igstAmount,
      totalAmountWithTax: tallyInvoice.totalAmountWithTax,
      notes: tallyInvoice.narration,
      termsAndConditions: '',
      paymentMethod: '',
      paymentStatus: 'Unpaid',
      dueDate: tallyInvoice.voucherDate.add(const Duration(days: 30)), // Assuming 30 days credit
    );
  }

  BillShillInvoice _zohoToBillShill(ZohoInvoice zohoInvoice) {
    List<BillShillInvoiceItem> items = zohoInvoice.items.map((item) {
      return BillShillInvoiceItem(
        itemName: item.itemName,
        itemDescription: item.itemDescription,
        hsnCode: item.hsnSacCode,
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: item.rate,
        amount: (item.rate * item.quantity) - item.discount,
        taxRate: item.taxPercentage,
        taxAmount: item.taxAmount,
        totalAmount: item.amount,
      );
    }).toList();

    return BillShillInvoice(
      invoiceNumber: zohoInvoice.invoiceNumber,
      invoiceDate: zohoInvoice.invoiceDate,
      customerName: zohoInvoice.customerName,
      customerGstin: zohoInvoice.customerGstin,
      customerAddress: zohoInvoice.customerBillingAddress,
      items: items,
      totalAmount: zohoInvoice.subtotal,
      totalTaxAmount: zohoInvoice.taxAmount,
      totalAmountWithTax: zohoInvoice.totalAmount,
      notes: zohoInvoice.notes,
      termsAndConditions: zohoInvoice.termsAndConditions,
      paymentMethod: '',
      paymentStatus: zohoInvoice.status == 'Paid' ? 'Paid' : 'Unpaid',
      dueDate: zohoInvoice.dueDate,
    );
  }

  BillShillInvoice _quickbooksToBillShill(QuickbooksInvoice quickbooksInvoice) {
    List<BillShillInvoiceItem> items = quickbooksInvoice.line.map((item) {
      double taxRate = 0;
      for (final tax in quickbooksInvoice.taxDetail) {
        if (tax.taxRateRef == item.taxCodeRef) {
          taxRate = tax.taxRate;
          break;
        }
      }

      return BillShillInvoiceItem(
        itemName: item.itemRef,
        itemDescription: item.description,
        hsnCode: item.hsnCode,
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: item.unitPrice,
        amount: item.amount,
        taxRate: taxRate,
        taxAmount: item.amount * (taxRate / 100),
        totalAmount: item.amount + (item.amount * (taxRate / 100)),
      );
    }).toList();

    return BillShillInvoice(
      invoiceNumber: quickbooksInvoice.docNumber,
      invoiceDate: quickbooksInvoice.txnDate,
      customerName: quickbooksInvoice.customerName,
      customerGstin: quickbooksInvoice.customerGstin,
      customerAddress: quickbooksInvoice.billingAddress,
      items: items,
      totalAmount: quickbooksInvoice.subtotal,
      totalTaxAmount: quickbooksInvoice.totalTax,
      totalAmountWithTax: quickbooksInvoice.totalAmount,
      notes: quickbooksInvoice.privateNote,
      termsAndConditions: quickbooksInvoice.customerMemo,
      paymentMethod: '',
      paymentStatus: quickbooksInvoice.txnStatus == 'Paid' ? 'Paid' : 'Unpaid',
      dueDate: quickbooksInvoice.dueDate,
    );
  }

  TallyInvoice _billShillToTally(BillShillInvoice billShillInvoice) {
    List<TallyInvoiceItem> items = billShillInvoice.items.map((item) {
      // Assuming equal distribution between CGST and SGST if within state
      double cgstRate = 0;
      double sgstRate = 0;
      double igstRate = 0;
      
      // Simple logic to determine tax type
      if (billShillInvoice.customerGstin.substring(0, 2) == '27') { // Assuming seller is in Maharashtra
        cgstRate = item.taxRate / 2;
        sgstRate = item.taxRate / 2;
      } else {
        igstRate = item.taxRate;
      }
      
      double cgstAmount = (cgstRate / 100) * item.amount;
      double sgstAmount = (sgstRate / 100) * item.amount;
      double igstAmount = (igstRate / 100) * item.amount;

      return TallyInvoiceItem(
        stockItemName: item.itemName,
        stockItemDescription: item.itemDescription,
        hsnCode: item.hsnCode,
        quantity: item.quantity,
        unit: item.unit,
        rate: item.unitPrice,
        amount: item.amount,
        cgstRate: cgstRate,
        sgstRate: sgstRate,
        igstRate: igstRate,
        cgstAmount: cgstAmount,
        sgstAmount: sgstAmount,
        igstAmount: igstAmount,
        totalAmount: item.totalAmount,
      );
    }).toList();

    // Calculate total tax amounts
    double totalCgst = items.fold(0, (sum, item) => sum + item.cgstAmount);
    double totalSgst = items.fold(0, (sum, item) => sum + item.sgstAmount);
    double totalIgst = items.fold(0, (sum, item) => sum + item.igstAmount);

    return TallyInvoice(
      voucherType: 'Sales',
      voucherNumber: billShillInvoice.invoiceNumber,
      voucherDate: billShillInvoice.invoiceDate,
      partyName: billShillInvoice.customerName,
      partyGstin: billShillInvoice.customerGstin,
      partyAddress: billShillInvoice.customerAddress,
      items: items,
      totalAmount: billShillInvoice.totalAmount,
      cgstAmount: totalCgst,
      sgstAmount: totalSgst,
      igstAmount: totalIgst,
      totalAmountWithTax: billShillInvoice.totalAmountWithTax,
      narration: billShillInvoice.notes,
      ledgerName: 'Sales',
      costCenter: '',
    );
  }

  ZohoInvoice _billShillToZoho(BillShillInvoice billShillInvoice) {
    List<ZohoInvoiceItem> items = billShillInvoice.items.map((item) {
      return ZohoInvoiceItem(
        itemName: item.itemName,
        itemDescription: item.itemDescription,
        hsnSacCode: item.hsnCode,
        quantity: item.quantity,
        unit: item.unit,
        rate: item.unitPrice,
        discount: 0, // Assuming no discount in BillShill
        taxPercentage: item.taxRate,
        taxAmount: item.taxAmount,
        amount: item.totalAmount,
      );
    }).toList();

    return ZohoInvoice(
      invoiceNumber: billShillInvoice.invoiceNumber,
      invoiceDate: billShillInvoice.invoiceDate,
      customerName: billShillInvoice.customerName,
      customerEmail: '', // Not available in BillShill
      customerPhone: '', // Not available in BillShill
      customerBillingAddress: billShillInvoice.customerAddress,
      customerShippingAddress: billShillInvoice.customerAddress, // Assuming same as billing
      customerGstin: billShillInvoice.customerGstin,
      items: items,
      subtotal: billShillInvoice.totalAmount,
      discountAmount: 0, // Assuming no discount in BillShill
      taxAmount: billShillInvoice.totalTaxAmount,
      totalAmount: billShillInvoice.totalAmountWithTax,
      notes: billShillInvoice.notes,
      termsAndConditions: billShillInvoice.termsAndConditions,
      paymentTerms: '',
      dueDate: billShillInvoice.dueDate,
      currency: 'INR',
      status: billShillInvoice.paymentStatus == 'Paid' ? 'Paid' : 'Unpaid',
    );
  }

  QuickbooksInvoice _billShillToQuickbooks(BillShillInvoice billShillInvoice) {
    List<QuickbooksInvoiceItem> items = billShillInvoice.items.map((item) {
      return QuickbooksInvoiceItem(
        itemRef: item.itemName,
        description: item.itemDescription,
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: item.unitPrice,
        amount: item.amount,
        taxCodeRef: 'TAX', // Default tax code
        hsnCode: item.hsnCode,
      );
    }).toList();

    // Create tax details
    List<QuickbooksTaxDetail> taxDetails = [];
    
    // Group items by tax rate
    Map<double, double> taxRateToAmount = {};
    for (final item in billShillInvoice.items) {
      if (!taxRateToAmount.containsKey(item.taxRate)) {
        taxRateToAmount[item.taxRate] = 0;
      }
      taxRateToAmount[item.taxRate] = (taxRateToAmount[item.taxRate] ?? 0) + item.amount;
    }
    
    // Create tax details for each rate
    taxRateToAmount.forEach((rate, amount) {
      taxDetails.add(QuickbooksTaxDetail(
        taxRateRef: 'TAX_${rate.toStringAsFixed(0)}',
        taxRateName: 'GST ${rate.toStringAsFixed(0)}%',
        taxRate: rate,
        taxableAmount: amount,
        taxAmount: amount * (rate / 100),
      ));
    });

    return QuickbooksInvoice(
      docNumber: billShillInvoice.invoiceNumber,
      txnDate: billShillInvoice.invoiceDate,
      customerRef: billShillInvoice.customerName.replaceAll(' ', '_'),
      customerName: billShillInvoice.customerName,
      customerEmail: '', // Not available in BillShill
      billingAddress: billShillInvoice.customerAddress,
      shippingAddress: billShillInvoice.customerAddress, // Assuming same as billing
      customerGstin: billShillInvoice.customerGstin,
      line: items,
      subtotal: billShillInvoice.totalAmount,
      taxDetail: taxDetails,
      totalTax: billShillInvoice.totalTaxAmount,
      totalAmount: billShillInvoice.totalAmountWithTax,
      privateNote: billShillInvoice.notes,
      customerMemo: billShillInvoice.termsAndConditions,
      dueDate: billShillInvoice.dueDate,
      currencyRef: 'INR',
      txnStatus: billShillInvoice.paymentStatus == 'Paid' ? 'Paid' : 'Pending',
    );
  }

  // XML parsing and generation methods
  TallyInvoice _parseTallyXml(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final voucherNode = document.findAllElements('VOUCHER').first;
    
    final voucherType = voucherNode.findElements('VOUCHERTYPENAME').first.innerText;
    final voucherNumber = voucherNode.findElements('VOUCHERNUMBER').first.innerText;
    final voucherDate = DateTime.parse(voucherNode.findElements('DATE').first.innerText);
    
    final partyLedgerNode = voucherNode.findElements('LEDGER').firstWhere(
      (element) => element.getAttribute('ISDEEMEDPOSITIVE') == 'Yes'
    );
    final partyName = partyLedgerNode.innerText;
    
    // Extract GSTIN from LEDGER STATEVAT info
    String partyGstin = '';
    String partyAddress = '';
    
    // Extract items
    List<TallyInvoiceItem> items = [];
    final inventoryEntriesNode = voucherNode.findElements('ALLINVENTORYENTRIES').first;
    for (final entryNode in inventoryEntriesNode.findElements('INVENTORYENTRY')) {
      final stockItemName = entryNode.findElements('STOCKITEMNAME').first.innerText;
      final quantity = double.parse(entryNode.findElements('ACTUALQTY').first.innerText);
      final rate = double.parse(entryNode.findElements('RATE').first.innerText);
      final amount = double.parse(entryNode.findElements('AMOUNT').first.innerText);
      
      // Extract tax details
      double cgstRate = 0;
      double sgstRate = 0;
      double igstRate = 0;
      double cgstAmount = 0;
      double sgstAmount = 0;
      double igstAmount = 0;
      
      // Add to items list
      items.add(TallyInvoiceItem(
        stockItemName: stockItemName,
        stockItemDescription: '',
        hsnCode: '',
        quantity: quantity,
        unit: 'Nos',
        rate: rate,
        amount: amount,
        cgstRate: cgstRate,
        sgstRate: sgstRate,
        igstRate: igstRate,
        cgstAmount: cgstAmount,
        sgstAmount: sgstAmount,
        igstAmount: igstAmount,
        totalAmount: amount + cgstAmount + sgstAmount + igstAmount,
      ));
    }
    
    // Calculate totals
    double totalAmount = items.fold(0, (sum, item) => sum + item.amount);
    double totalCgst = items.fold(0, (sum, item) => sum + item.cgstAmount);
    double totalSgst = items.fold(0, (sum, item) => sum + item.sgstAmount);
    double totalIgst = items.fold(0, (sum, item) => sum + item.igstAmount);
    double totalAmountWithTax = totalAmount + totalCgst + totalSgst + totalIgst;
    
    return TallyInvoice(
      voucherType: voucherType,
      voucherNumber: voucherNumber,
      voucherDate: voucherDate,
      partyName: partyName,
      partyGstin: partyGstin,
      partyAddress: partyAddress,
      items: items,
      totalAmount: totalAmount,
      cgstAmount: totalCgst,
      sgstAmount: totalSgst,
      igstAmount: totalIgst,
      totalAmountWithTax: totalAmountWithTax,
      narration: voucherNode.findElements('NARRATION').firstOrNull?.innerText ?? '',
      ledgerName: partyName,
      costCenter: '',
    );
  }

  String _generateTallyXml(TallyInvoice tallyInvoice) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('ENVELOPE', nest: () {
      builder.element('HEADER', nest: () {
        builder.element('TALLYREQUEST', nest: 'Import Data');
      });
      builder.element('BODY', nest: () {
        builder.element('IMPORTDATA', nest: () {
          builder.element('REQUESTDESC', nest: () {
            builder.element('REPORTNAME', nest: 'Vouchers');
            builder.element('STATICVARIABLES', nest: () {
              builder.element('SVCURRENTCOMPANY', nest: 'Company Name');
            });
          });
          builder.element('REQUESTDATA', nest: () {
            builder.element('TALLYMESSAGE', nest: () {
              builder.element('VOUCHER', nest: () {
                builder.element('DATE', nest: tallyInvoice.voucherDate.toIso8601String().split('T')[0]);
                builder.element('VOUCHERTYPENAME', nest: tallyInvoice.voucherType);
                builder.element('VOUCHERNUMBER', nest: tallyInvoice.voucherNumber);
                builder.element('REFERENCE', nest: tallyInvoice.voucherNumber);
                builder.element('NARRATION', nest: tallyInvoice.narration);
                
                // Add ledger entries
                builder.element('ALLLEDGERENTRIES.LIST', nest: () {
                  builder.attribute('TYPE', 'Ledger');
                  builder.element('LEDGERNAME', nest: tallyInvoice.partyName);
                  builder.element('ISDEEMEDPOSITIVE', nest: 'Yes');
                  builder.element('AMOUNT', nest: (-tallyInvoice.totalAmountWithTax).toString());
                });
                
                builder.element('ALLLEDGERENTRIES.LIST', nest: () {
                  builder.attribute('TYPE', 'Ledger');
                  builder.element('LEDGERNAME', nest: 'Sales Account');
                  builder.element('ISDEEMEDPOSITIVE', nest: 'No');
                  builder.element('AMOUNT', nest: tallyInvoice.totalAmount.toString());
                });
                
                if (tallyInvoice.cgstAmount > 0) {
                  builder.element('ALLLEDGERENTRIES.LIST', nest: () {
                    builder.attribute('TYPE', 'Ledger');
                    builder.element('LEDGERNAME', nest: 'CGST');
                    builder.element('ISDEEMEDPOSITIVE', nest: 'No');
                    builder.element('AMOUNT', nest: tallyInvoice.cgstAmount.toString());
                  });
                }
                
                if (tallyInvoice.sgstAmount > 0) {
                  builder.element('ALLLEDGERENTRIES.LIST', nest: () {
                    builder.attribute('TYPE', 'Ledger');
                    builder.element('LEDGERNAME', nest: 'SGST');
                    builder.element('ISDEEMEDPOSITIVE', nest: 'No');
                    builder.element('AMOUNT', nest: tallyInvoice.sgstAmount.toString());
                  });
                }
                
                if (tallyInvoice.igstAmount > 0) {
                  builder.element('ALLLEDGERENTRIES.LIST', nest: () {
                    builder.attribute('TYPE', 'Ledger');
                    builder.element('LEDGERNAME', nest: 'IGST');
                    builder.element('ISDEEMEDPOSITIVE', nest: 'No');
                    builder.element('AMOUNT', nest: tallyInvoice.igstAmount.toString());
                  });
                }
                
                // Add inventory entries
                builder.element('ALLINVENTORYENTRIES.LIST', nest: () {
                  for (final item in tallyInvoice.items) {
                    builder.element('INVENTORYENTRY.LIST', nest: () {
                      builder.element('STOCKITEMNAME', nest: item.stockItemName);
                      builder.element('ISDEEMEDPOSITIVE', nest: 'No');
                      builder.element('RATE', nest: item.rate.toString());
                      builder.element('AMOUNT', nest: item.amount.toString());
                      builder.element('ACTUALQTY', nest: item.quantity.toString());
                      builder.element('BILLEDQTY', nest: item.quantity.toString());
                      builder.element('BATCHALLOCATIONS.LIST', nest: () {
                        builder.element('GODOWNNAME', nest: 'Main Location');
                        builder.element('BATCHNAME', nest: 'Primary Batch');
                        builder.element('AMOUNT', nest: item.amount.toString());
                        builder.element('ACTUALQTY', nest: item.quantity.toString());
                        builder.element('BILLEDQTY', nest: item.quantity.toString());
                      });
                    });
                  }
                });
              });
            });
          });
        });
      });
    });
    
    return builder.buildDocument().toString();
  }

  Map<String, dynamic> _parseGenericXml(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final invoiceNode = document.findAllElements('Invoice').first;
    
    // Extract basic invoice details
    final invoiceNumber = invoiceNode.findElements('InvoiceNumber').first.innerText;
    final invoiceDate = DateTime.parse(invoiceNode.findElements('InvoiceDate').first.innerText);
    
    // Extract customer details
    final customerNode = invoiceNode.findElements('Customer').first;
    final customerName = customerNode.findElements('Name').first.innerText;
    final customerGstin = customerNode.findElements('GSTIN').firstOrNull?.innerText ?? '';
    final customerAddress = customerNode.findElements('Address').firstOrNull?.innerText ?? '';
    
    // Extract items
    List<Map<String, dynamic>> items = [];
    for (final itemNode in invoiceNode.findElements('Items').first.findElements('Item')) {
      items.add({
        'name': itemNode.findElements('Name').first.innerText,
        'description': itemNode.findElements('Description').firstOrNull?.innerText ?? '',
        'hsn_code': itemNode.findElements('HSNCode').firstOrNull?.innerText ?? '',
        'quantity': double.parse(itemNode.findElements('Quantity').first.innerText),
        'unit': itemNode.findElements('Unit').firstOrNull?.innerText ?? 'Nos',
        'unit_price': double.parse(itemNode.findElements('UnitPrice').first.innerText),
        'amount': double.parse(itemNode.findElements('Amount').first.innerText),
        'tax_rate': double.parse(itemNode.findElements('TaxRate').firstOrNull?.innerText ?? '0'),
        'tax_amount': double.parse(itemNode.findElements('TaxAmount').firstOrNull?.innerText ?? '0'),
        'total_amount': double.parse(itemNode.findElements('TotalAmount').first.innerText),
      });
    }
    
    // Extract totals
    final totalsNode = invoiceNode.findElements('Totals').first;
    final totalAmount = double.parse(totalsNode.findElements('TotalAmount').first.innerText);
    final totalTaxAmount = double.parse(totalsNode.findElements('TotalTaxAmount').firstOrNull?.innerText ?? '0');
    final totalAmountWithTax = double.parse(totalsNode.findElements('TotalAmountWithTax').first.innerText);
    
    // Create a BillShill-like structure
    return {
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'customer_name': customerName,
      'customer_gstin': customerGstin,
      'customer_address': customerAddress,
      'items': items,
      'total_amount': totalAmount,
      'total_tax_amount': totalTaxAmount,
      'total_amount_with_tax': totalAmountWithTax,
      'notes': invoiceNode.findElements('Notes').firstOrNull?.innerText ?? '',
      'terms_and_conditions': invoiceNode.findElements('TermsAndConditions').firstOrNull?.innerText ?? '',
      'payment_method': invoiceNode.findElements('PaymentMethod').firstOrNull?.innerText ?? '',
      'payment_status': invoiceNode.findElements('PaymentStatus').firstOrNull?.innerText ?? 'Unpaid',
      'due_date': invoiceNode.findElements('DueDate').firstOrNull?.innerText ?? invoiceDate.toIso8601String(),
    };
  }

  String _generateGenericXml(BillShillInvoice invoice) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('Invoice', nest: () {
      builder.element('InvoiceNumber', nest: invoice.invoiceNumber);
      builder.element('InvoiceDate', nest: invoice.invoiceDate.toIso8601String().split('T')[0]);
      
      builder.element('Customer', nest: () {
        builder.element('Name', nest: invoice.customerName);
        builder.element('GSTIN', nest: invoice.customerGstin);
        builder.element('Address', nest: invoice.customerAddress);
      });
      
      builder.element('Items', nest: () {
        for (final item in invoice.items) {
          builder.element('Item', nest: () {
            builder.element('Name', nest: item.itemName);
            builder.element('Description', nest: item.itemDescription);
            builder.element('HSNCode', nest: item.hsnCode);
            builder.element('Quantity', nest: item.quantity.toString());
            builder.element('Unit', nest: item.unit);
            builder.element('UnitPrice', nest: item.unitPrice.toString());
            builder.element('Amount', nest: item.amount.toString());
            builder.element('TaxRate', nest: item.taxRate.toString());
            builder.element('TaxAmount', nest: item.taxAmount.toString());
            builder.element('TotalAmount', nest: item.totalAmount.toString());
          });
        }
      });
      
      builder.element('Totals', nest: () {
        builder.element('TotalAmount', nest: invoice.totalAmount.toString());
        builder.element('TotalTaxAmount', nest: invoice.totalTaxAmount.toString());
        builder.element('TotalAmountWithTax', nest: invoice.totalAmountWithTax.toString());
      });
      
      builder.element('Notes', nest: invoice.notes);
      builder.element('TermsAndConditions', nest: invoice.termsAndConditions);
      builder.element('PaymentMethod', nest: invoice.paymentMethod);
      builder.element('PaymentStatus', nest: invoice.paymentStatus);
      builder.element('DueDate', nest: invoice.dueDate.toIso8601String().split('T')[0]);
    });
    
    return builder.buildDocument().toString();
  }

  List<List<dynamic>> _parseCsv(String csvContent) {
    final rows = const CsvToListConverter().convert(csvContent);
    
    // Assuming the CSV has headers
    final headers = rows[0];
    final data = rows.sublist(1);
    
    // Extract invoice details from the first row
    // Extract invoice details from the first row
    String invoiceNumber = '';
    DateTime invoiceDate = DateTime.now();
    String customerName = '';
    String customerGstin = '';
    String customerAddress = '';

    if (headers.contains('Invoice Number') && data.isNotEmpty) {
      invoiceNumber = data[0][headers.indexOf('Invoice Number')].toString();
    }
    if (headers.contains('Invoice Date') && data.isNotEmpty) {
      invoiceDate = DateTime.parse(data[0][headers.indexOf('Invoice Date')].toString());
    }
    if (headers.contains('Customer Name') && data.isNotEmpty) {
      customerName = data[0][headers.indexOf('Customer Name')].toString();
    }
    if (headers.contains('Customer GSTIN') && data.isNotEmpty) {
      customerGstin = data[0][headers.indexOf('Customer GSTIN')].toString();
    }
    if (headers.contains('Customer Address') && data.isNotEmpty) {
      customerAddress = data[0][headers.indexOf('Customer Address')].toString();
    }
    
    // Extract items
    List<Map<String, dynamic>> items = [];
    for (final row in data) {
      final Map<String, dynamic> item = {};

      if (headers.contains('Item Name')) {
        item['item_name'] = row[headers.indexOf('Item Name')].toString();
      }
      if (headers.contains('Item Description')) {
        item['item_description'] = row[headers.indexOf('Item Description')].toString();
      }
      if (headers.contains('HSN Code')) {
        item['hsn_code'] = row[headers.indexOf('HSN Code')].toString();
      }
      if (headers.contains('Quantity')) {
        item['quantity'] = double.tryParse(row[headers.indexOf('Quantity')].toString()) ?? 0.0;
      }
      if (headers.contains('Unit')) {
        item['unit'] = row[headers.indexOf('Unit')].toString();
      }
      if (headers.contains('Unit Price')) {
        item['unit_price'] = double.tryParse(row[headers.indexOf('Unit Price')].toString()) ?? 0.0;
      }
      if (headers.contains('Amount')) {
        item['amount'] = double.tryParse(row[headers.indexOf('Amount')].toString()) ?? 0.0;
      }
      if (headers.contains('Tax Rate')) {
        item['tax_rate'] = double.tryParse(row[headers.indexOf('Tax Rate')].toString()) ?? 0.0;
      }
      if (headers.contains('Tax Amount')) {
        item['tax_amount'] = double.tryParse(row[headers.indexOf('Tax Amount')].toString()) ?? 0.0;
      }
      if (headers.contains('Total Amount')) {
        item['total_amount'] = double.tryParse(row[headers.indexOf('Total Amount')].toString()) ?? 0.0;
      }

      items.add(item);
    }
    
    // Calculate totals
    double totalAmount = 0.0;
    double totalTaxAmount = 0.0;
    double totalAmountWithTax = 0.0;

    for (final item in items) {
      totalAmount += item['amount'] as double;
      totalTaxAmount += item['tax_amount'] as double;
      totalAmountWithTax += item['total_amount'] as double;
    }
    
    // Create a BillShill-like structure
    return [
      headers,
      ...data,
      ['Total', '', '', '', '', '', totalAmount, '', totalTaxAmount, totalAmountWithTax],
    ];
  }

  String _generateCsv(BillShillInvoice invoice) {
    List<List<dynamic>> rows = [];
    
    // Add headers
    rows.add([
      'Invoice Number',
      'Invoice Date',
      'Customer Name',
      'Customer GSTIN',
      'Customer Address',
      'Item Name',
      'Item Description',
      'HSN Code',
      'Quantity',
      'Unit',
      'Unit Price',
      'Amount',
      'Tax Rate',
      'Tax Amount',
      'Total Amount',
    ]);
    
    // Add items
    for (final item in invoice.items) {
      rows.add([
        invoice.invoiceNumber,
        invoice.invoiceDate.toIso8601String().split('T')[0],
        invoice.customerName,
        invoice.customerGstin,
        invoice.customerAddress,
        item.itemName,
        item.itemDescription,
        item.hsnCode,
        item.quantity,
        item.unit,
        item.unitPrice,
        item.amount,
        item.taxRate,
        item.taxAmount,
        item.totalAmount,
      ]);
    }
    
    // Add totals
    rows.add([
      '',
      '',
      '',
      '',
      '',
      'Total',
      '',
      '',
      '',
      '',
      '',
      invoice.totalAmount,
      '',
      invoice.totalTaxAmount,
      invoice.totalAmountWithTax,
    ]);
    
    return const ListToCsvConverter().convert(rows);
  }

  BillShillInvoice _xmlToBillShill(Map<String, dynamic> xmlData) {
    List<BillShillInvoiceItem> items = [];
    for (final item in xmlData['items']) {
      items.add(BillShillInvoiceItem(
        itemName: item['name'],
        itemDescription: item['description'],
        hsnCode: item['hsn_code'],
        quantity: item['quantity'],
        unit: item['unit'],
        unitPrice: item['unit_price'],
        amount: item['amount'],
        taxRate: item['tax_rate'],
        taxAmount: item['tax_amount'],
        totalAmount: item['total_amount'],
      ));
    }

    return BillShillInvoice(
      invoiceNumber: xmlData['invoice_number'],
      invoiceDate: DateTime.parse(xmlData['invoice_date']),
      customerName: xmlData['customer_name'],
      customerGstin: xmlData['customer_gstin'],
      customerAddress: xmlData['customer_address'],
      items: items,
      totalAmount: xmlData['total_amount'],
      totalTaxAmount: xmlData['total_tax_amount'],
      totalAmountWithTax: xmlData['total_amount_with_tax'],
      notes: xmlData['notes'],
      termsAndConditions: xmlData['terms_and_conditions'],
      paymentMethod: xmlData['payment_method'],
      paymentStatus: xmlData['payment_status'],
      dueDate: DateTime.parse(xmlData['due_date']),
    );
  }

  BillShillInvoice _csvToBillShill(List<List<dynamic>> csvData) {
    // Assuming the CSV has headers
    final headers = csvData[0];
    final data = csvData.sublist(1, csvData.length - 1); // Exclude the total row
    
    // Extract invoice details from the first row
    final invoiceNumber = data[0][headers.indexOf('Invoice Number')];
    final invoiceDate = DateTime.parse(data[0][headers.indexOf('Invoice Date')]);
    final customerName = data[0][headers.indexOf('Customer Name')];
    final customerGstin = data[0][headers.indexOf('Customer GSTIN')];
    final customerAddress = data[0][headers.indexOf('Customer Address')];
    
    // Extract items
    List<BillShillInvoiceItem> items = [];
    for (final row in data) {
      items.add(BillShillInvoiceItem(
        itemName: row[headers.indexOf('Item Name')],
        itemDescription: row[headers.indexOf('Item Description')],
        hsnCode: row[headers.indexOf('HSN Code')],
        quantity: double.parse(row[headers.indexOf('Quantity')].toString()),
        unit: row[headers.indexOf('Unit')],
        unitPrice: double.parse(row[headers.indexOf('Unit Price')].toString()),
        amount: double.parse(row[headers.indexOf('Amount')].toString()),
        taxRate: double.parse(row[headers.indexOf('Tax Rate')].toString()),
        taxAmount: double.parse(row[headers.indexOf('Tax Amount')].toString()),
        totalAmount: double.parse(row[headers.indexOf('Total Amount')].toString()),
      ));
    }
    
    // Get totals from the last row
    final totalRow = csvData.last;
    final totalAmount = double.parse(totalRow[headers.indexOf('Amount')].toString());
    final totalTaxAmount = double.parse(totalRow[headers.indexOf('Tax Amount')].toString());
    final totalAmountWithTax = double.parse(totalRow[headers.indexOf('Total Amount')].toString());
    
    return BillShillInvoice(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      customerName: customerName,
      customerGstin: customerGstin,
      customerAddress: customerAddress,
      items: items,
      totalAmount: totalAmount,
      totalTaxAmount: totalTaxAmount,
      totalAmountWithTax: totalAmountWithTax,
      notes: '',
      termsAndConditions: '',
      paymentMethod: '',
      paymentStatus: 'Unpaid',
      dueDate: invoiceDate.add(const Duration(days: 30)), // Assuming 30 days credit
    );
  }

  dynamic _billShillToXml(BillShillInvoice invoice) {
    // Convert to XML structure
    return {
      'invoice_number': invoice.invoiceNumber,
      'invoice_date': invoice.invoiceDate.toIso8601String(),
      'customer_name': invoice.customerName,
      'customer_gstin': invoice.customerGstin,
      'customer_address': invoice.customerAddress,
      'items': invoice.items.map((item) => {
        'name': item.itemName,
        'description': item.itemDescription,
        'hsn_code': item.hsnCode,
        'quantity': item.quantity,
        'unit': item.unit,
        'unit_price': item.unitPrice,
        'amount': item.amount,
        'tax_rate': item.taxRate,
        'tax_amount': item.taxAmount,
        'total_amount': item.totalAmount,
      }).toList(),
      'total_amount': invoice.totalAmount,
      'total_tax_amount': invoice.totalTaxAmount,
      'total_amount_with_tax': invoice.totalAmountWithTax,
      'notes': invoice.notes,
      'terms_and_conditions': invoice.termsAndConditions,
      'payment_method': invoice.paymentMethod,
      'payment_status': invoice.paymentStatus,
      'due_date': invoice.dueDate.toIso8601String(),
    };
  }

  dynamic _billShillToCsv(BillShillInvoice invoice) {
    // Convert to CSV structure
    List<List<dynamic>> rows = [];
    
    // Add headers
    rows.add([
      'Invoice Number',
      'Invoice Date',
      'Customer Name',
      'Customer GSTIN',
      'Customer Address',
      'Item Name',
      'Item Description',
      'HSN Code',
      'Quantity',
      'Unit',
      'Unit Price',
      'Amount',
      'Tax Rate',
      'Tax Amount',
      'Total Amount',
    ]);
    
    // Add items
    for (final item in invoice.items) {
      rows.add([
        invoice.invoiceNumber,
        invoice.invoiceDate.toIso8601String().split('T')[0],
        invoice.customerName,
        invoice.customerGstin,
        invoice.customerAddress,
        item.itemName,
        item.itemDescription,
        item.hsnCode,
        item.quantity,
        item.unit,
        item.unitPrice,
        item.amount,
        item.taxRate,
        item.taxAmount,
        item.totalAmount,
      ]);
    }
    
    return rows;
  }
}
