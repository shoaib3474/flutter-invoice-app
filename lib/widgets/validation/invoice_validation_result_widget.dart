import 'package:flutter/material.dart';
import '../../models/validation/invoice_validation_result.dart';

class InvoiceValidationResultWidget extends StatelessWidget {
  final InvoiceValidationResult validationResult;
  final VoidCallback? onDismiss;
  final VoidCallback? onFixAll;
  
  const InvoiceValidationResultWidget({
    Key? key,
    required this.validationResult,
    this.onDismiss,
    this.onFixAll,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (validationResult.isValid && validationResult.warnings.isEmpty) {
      return _buildSuccessMessage(context);
    }
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (validationResult.errors.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              _buildErrorsList(context),
            ],
            if (validationResult.warnings.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              _buildWarningsList(context),
            ],
            const SizedBox(height: 16.0),
            _buildActions(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuccessMessage(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700]),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                'All validations passed successfully!',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              color: Colors.green[700],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    final errorCount = validationResult.errors.length;
    final warningCount = validationResult.warnings.length;
    
    return Row(
      children: [
        Icon(
          errorCount > 0 ? Icons.error : Icons.warning,
          color: errorCount > 0 ? Colors.red : Colors.orange,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorCount > 0
                    ? 'Validation Failed'
                    : 'Validation Completed with Warnings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: errorCount > 0 ? Colors.red : Colors.orange,
                ),
              ),
              Text(
                'Found $errorCount errors and $warningCount warnings',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onDismiss,
        ),
      ],
    );
  }
  
  Widget _buildErrorsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Errors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8.0),
        ...validationResult.errors.map((error) => _buildIssueItem(context, error, true)),
      ],
    );
  }
  
  Widget _buildWarningsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warnings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8.0),
        ...validationResult.warnings.map((warning) => _buildIssueItem(context, warning, false)),
      ],
    );
  }
  
  Widget _buildIssueItem(BuildContext context, ValidationIssue issue, bool isError) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.warning_amber_outlined,
            color: isError ? Colors.red : Colors.orange,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.message,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red[700] : Colors.orange[700],
                  ),
                ),
                if (issue.invoiceNumber != null || issue.customerName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _buildIssueContext(issue),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Field: ${issue.fieldName} (Code: ${issue.code})',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _buildIssueContext(ValidationIssue issue) {
    List<String> contextParts = [];
    
    if (issue.invoiceNumber != null) {
      contextParts.add('Invoice: ${issue.invoiceNumber}');
    }
    
    if (issue.invoiceDate != null) {
      contextParts.add('Date: ${issue.invoiceDate}');
    }
    
    if (issue.customerName != null) {
      contextParts.add('Customer: ${issue.customerName}');
    }
    
    if (issue.customerGstin != null) {
      contextParts.add('GSTIN: ${issue.customerGstin}');
    }
    
    return contextParts.join(' | ');
  }
  
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (validationResult.errors.isNotEmpty)
          ElevatedButton(
            onPressed: onFixAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Fix All Issues'),
          ),
        const SizedBox(width: 8.0),
        OutlinedButton(
          onPressed: onDismiss,
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}
