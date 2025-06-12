class InvoiceValidationResult {
  final bool isValid;
  final List<ValidationIssue> errors;
  final List<ValidationIssue> warnings;
  
  InvoiceValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  
  factory InvoiceValidationResult.valid() {
    return InvoiceValidationResult(
      isValid: true,
      errors: [],
      warnings: [],
    );
  }
  
  factory InvoiceValidationResult.withIssues({
    required List<ValidationIssue> errors,
    required List<ValidationIssue> warnings,
  }) {
    return InvoiceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  InvoiceValidationResult merge(InvoiceValidationResult other) {
    return InvoiceValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      warnings: [...warnings, ...other.warnings],
    );
  }
}

class ValidationIssue {
  final String code;
  final String message;
  final String fieldName;
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? customerName;
  final String? customerGstin;
  
  ValidationIssue({
    required this.code,
    required this.message,
    required this.fieldName,
    this.invoiceNumber,
    this.invoiceDate,
    this.customerName,
    this.customerGstin,
  });
  
  @override
  String toString() {
    String result = '$code: $message';
    if (invoiceNumber != null) {
      result += ' [Invoice: $invoiceNumber]';
    }
    if (customerName != null) {
      result += ' [Customer: $customerName]';
    }
    return result;
  }
}

enum ValidationSeverity {
  error,
  warning,
  info,
}

class ValidationRuleSet {
  final String name;
  final String description;
  final List<ValidationRule> rules;
  
  ValidationRuleSet({
    required this.name,
    required this.description,
    required this.rules,
  });
}

abstract class ValidationRule {
  final String code;
  final String description;
  final ValidationSeverity severity;
  
  ValidationRule({
    required this.code,
    required this.description,
    required this.severity,
  });
  
  ValidationIssue? validate(dynamic data);
}
