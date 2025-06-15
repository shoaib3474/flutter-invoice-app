import 'package:flutter_invoice_app/models/customer/customer_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';

abstract class MigrationTarget {
  /// Initialize the migration target
  Future<void> initialize();

  /// Save an invoice to the target
  Future<void> saveInvoice(InvoiceModel invoice);

  /// Save a customer to the target
  Future<void> saveCustomer(Customer customer);

  /// Save a GSTR1 return to the target
  Future<void> saveGSTR1(GSTR1 gstr1);

  /// Save a GSTR3B return to the target
  Future<void> saveGSTR3B(GSTR3B gstr3b);

  /// Save a GSTR9 return to the target
  Future<void> saveGSTR9(GSTR9 gstr9);

  /// Save a GSTR9C return to the target
  Future<void> saveGSTR9C(GSTR9C gstr9c);

  /// Save a setting to the target
  Future<void> saveSetting(String key, String value);

  /// Get all invoices from the target (for validation)
  Future<List<InvoiceModel>> getInvoices();

  /// Get all customers from the target (for validation)
  Future<List<Customer>> getCustomers();

  /// Get all GSTR1 returns from the target (for validation)
  Future<List<GSTR1>> getGSTR1Returns();

  /// Get all GSTR3B returns from the target (for validation)
  Future<List<GSTR3B>> getGSTR3BReturns();

  /// Get all GSTR9 returns from the target (for validation)
  Future<List<GSTR9>> getGSTR9Returns();

  /// Get all GSTR9C returns from the target (for validation)
  Future<List<GSTR9C>> getGSTR9CReturns();

  /// Get all settings from the target (for validation)
  Future<List<Map<String, String>>> getSettings();

  /// Clean the target database
  Future<void> cleanDatabase();

  /// Get the target name for display purposes
  String getTargetName();

  /// Get target information
  Map<String, dynamic> getTargetInfo();

  /// Dispose resources
  Future<void> dispose();
}
