import 'package:flutter/foundation.dart';
import '../../models/validation/invoice_validation_result.dart';
import '../../models/gst_returns/gstr1_model.dart';
import '../../utils/gstin_validator.dart';
import '../../utils/hsn_sac_validator.dart';
import '../../utils/tax_calculator.dart';

class InvoiceValidationService {
  // Validate GSTR1 data
  Future<InvoiceValidationResult> validateGSTR1(GSTR1Model gstr1) async {
    // Use compute to run validation in a separate isolate for better performance
    return compute(_validateGSTR1Isolate, gstr1);
  }
  
  // Validate imported data
  Future<InvoiceValidationResult> validateImportedData(dynamic data, String dataType) async {
    List<ValidationIssue> errors = [];
    List<ValidationIssue> warnings = [];
    
    // Basic validation based on data type
    if (dataType == 'tally') {
      // Validate Tally data
      _validateTallyData(data, errors, warnings);
    } else if (dataType == 'marg') {
      // Validate Marg data
      _validateMargData(data, errors, warnings);
    } else {
      errors.add(ValidationIssue(
        code: 'UNS001',
        message: 'Unsupported data type: $dataType',
        fieldName: 'dataType',
      ));
    }
    
    return InvoiceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  // Private methods for validation
  void _validateTallyData(dynamic data, List<ValidationIssue> errors, List<ValidationIssue> warnings) {
    // Implement Tally-specific validation
    // This is a simplified implementation
  }
  
  void _validateMargData(dynamic data, List<ValidationIssue> errors, List<ValidationIssue> warnings) {
    // Implement Marg-specific validation
    // This is a simplified implementation
  }
}

// Isolate function for GSTR1 validation
InvoiceValidationResult _validateGSTR1Isolate(GSTR1Model gstr1) {
  List<ValidationIssue> errors = [];
  List<ValidationIssue> warnings = [];
  
  // Validate GSTIN
  if (!GstinValidator.isValid(gstr1.gstin)) {
    errors.add(ValidationIssue(
      code: 'GST001',
      message: 'Invalid GSTIN format',
      fieldName: 'gstin',
    ));
  }
  
  // Validate return period
  if (gstr1.fp == null || gstr1.fp!.isEmpty) {
    errors.add(ValidationIssue(
      code: 'PER001',
      message: 'Return period is required',
      fieldName: 'fp',
    ));
  } else if (!_isValidReturnPeriod(gstr1.fp!)) {
    errors.add(ValidationIssue(
      code: 'PER002',
      message: 'Invalid return period format. Expected format: MM-YYYY',
      fieldName: 'fp',
    ));
  }
  
  // Validate B2B invoices
  if (gstr1.b2b != null) {
    for (var b2b in gstr1.b2b!) {
      // Validate receiver GSTIN
      if (!GstinValidator.isValid(b2b.ctin)) {
        errors.add(ValidationIssue(
          code: 'B2B001',
          message: 'Invalid receiver GSTIN',
          fieldName: 'ctin',
          customerGstin: b2b.ctin,
        ));
      }
      
      // Validate invoices
      if (b2b.inv != null) {
        for (var inv in b2b.inv!) {
          // Validate invoice number
          if (inv.inum == null || inv.inum!.isEmpty) {
            errors.add(ValidationIssue(
              code: 'INV001',
              message: 'Invoice number is required',
              fieldName: 'inum',
              customerGstin: b2b.ctin,
            ));
          }
          
          // Validate invoice date
          if (inv.idt == null || inv.idt!.isEmpty) {
            errors.add(ValidationIssue(
              code: 'INV002',
              message: 'Invoice date is required',
              fieldName: 'idt',
              invoiceNumber: inv.inum,
              customerGstin: b2b.ctin,
            ));
          } else if (!_isValidDate(inv.idt!)) {
            errors.add(ValidationIssue(
              code: 'INV003',
              message: 'Invalid invoice date format. Expected format: DD-MM-YYYY',
              fieldName: 'idt',
              invoiceNumber: inv.inum,
              customerGstin: b2b.ctin,
            ));
          }
          
          // Validate invoice value
          if (inv.val == null || inv.val! <= 0) {
            errors.add(ValidationIssue(
              code: 'INV004',
              message: 'Invoice value must be greater than zero',
              fieldName: 'val',
              invoiceNumber: inv.inum,
              customerGstin: b2b.ctin,
            ));
          }
          
          // Validate items
          if (inv.itms == null || inv.itms!.isEmpty) {
            errors.add(ValidationIssue(
              code: 'ITM001',
              message: 'Invoice must have at least one item',
              fieldName: 'itms',
              invoiceNumber: inv.inum,
              customerGstin: b2b.ctin,
            ));
          } else {
            for (var item in inv.itms!) {
              // Validate HSN/SAC code
              if (item.itm_det?.hsn_sc == null || item.itm_det!.hsn_sc!.isEmpty) {
                warnings.add(ValidationIssue(
                  code: 'HSN001',
                  message: 'HSN/SAC code is recommended',
                  fieldName: 'hsn_sc',
                  invoiceNumber: inv.inum,
                  customerGstin: b2b.ctin,
                ));
              } else if (!HsnSacValidator.isValid(item.itm_det!.hsn_sc!)) {
                warnings.add(ValidationIssue(
                  code: 'HSN002',
                  message: 'HSN/SAC code format may be invalid',
                  fieldName: 'hsn_sc',
                  invoiceNumber: inv.inum,
                  customerGstin: b2b.ctin,
                ));
              }
              
              // Validate taxable value
              if (item.itm_det?.txval == null || item.itm_det!.txval! < 0) {
                errors.add(ValidationIssue(
                  code: 'ITM002',
                  message: 'Taxable value cannot be negative',
                  fieldName: 'txval',
                  invoiceNumber: inv.inum,
                  customerGstin: b2b.ctin,
                ));
              }
              
              // Validate tax calculations
              if (item.itm_det != null) {
                double? calculatedTax = TaxCalculator.calculateTax(
                  item.itm_det!.txval ?? 0,
                  item.itm_det!.rt ?? 0,
                );
                
                double declaredTax = (item.itm_det!.iamt ?? 0) +
                    (item.itm_det!.camt ?? 0) +
                    (item.itm_det!.samt ?? 0);
                
                if (calculatedTax != null && (declaredTax - calculatedTax).abs() > 1) {
                  warnings.add(ValidationIssue(
                    code: 'TAX001',
                    message: 'Tax calculation may be incorrect',
                    fieldName: 'tax',
                    invoiceNumber: inv.inum,
                    customerGstin: b2b.ctin,
                  ));
                }
              }
            }
          }
        }
      }
    }
  }
  
  // More validations can be added for other sections like B2CL, B2CS, etc.
  
  return InvoiceValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: warnings,
  );
}

// Helper methods
bool _isValidReturnPeriod(String period) {
  // Expected format: MM-YYYY
  RegExp regex = RegExp(r'^(0[1-9]|1[0-2])-\d{4}$');
  return regex.hasMatch(period);
}

bool _isValidDate(String date) {
  // Expected format: DD-MM-YYYY
  RegExp regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-\d{4}$');
  return regex.hasMatch(date);
}
