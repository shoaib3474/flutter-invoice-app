import 'package:flutter_invoice_app/models/customer/customer_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/settings/app_setting.dart';

abstract class MigrationSource {
  /// Initialize the migration source
  Future<void> initialize();

  /// Get all invoices from the source
  Future<List<InvoiceModel>> getInvoices();

  /// Get all customers from the source
  Future<List<Customer>> getCustomers();

  /// Get all GSTR1 returns from the source
  Future<List<GSTR1>> getGSTR1Returns();

  /// Get all GSTR3B returns from the source
  Future<List<GSTR3B>> getGSTR3BReturns();

  /// Get all GSTR9 returns from the source
  Future<List<GSTR9>> getGSTR9Returns();

  /// Get all GSTR9C returns from the source
  Future<List<GSTR9C>> getGSTR9CReturns();

  /// Get all settings from the source
  Future<List<AppSetting>> getSettings();

  /// Get the source name for display purposes
  String getSourceName();

  /// Get source information
  Map<String, dynamic> getSourceInfo();

  /// Dispose resources
  Future<void> dispose();
}
