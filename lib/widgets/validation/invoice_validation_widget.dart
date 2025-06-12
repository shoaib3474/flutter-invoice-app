import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/validation/invoice_validation_result.dart';
import '../../services/validation/invoice_validation_service.dart';

class InvoiceValidationWidget extends StatefulWidget {
  const InvoiceValidationWidget({
    super.key,
    required this.invoiceId,
    this.onValidationComplete,
  });

  final String invoiceId;
  final void Function(InvoiceValidationResult)? onValidationComplete;

  @override
  State<InvoiceValidationWidget> createState() => _InvoiceValidationWidgetState();
}

class _InvoiceValidationWidgetState extends State<InvoiceValidationWidget> {
  final InvoiceValidationService _validationService = InvoiceValidationService();
  InvoiceValidationResult? _validationResult;
  bool _isValidating = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Validation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_isValidating)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_validationResult != null)
              _buildValidationResults()
            else
              _buildValidationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validateInvoice,
        child: const Text('Validate Invoice'),
      ),
    );
  }

  Widget _buildValidationResults() {
    final result = _validationResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              result.isValid ? Icons.check_circle : Icons.error,
              color: result.isValid ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              result.isValid ? 'Valid Invoice' : 'Invalid Invoice',
              style: TextStyle(
                color: result.isValid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Errors:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...result.errors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              )),
        ],
        if (result.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Warnings:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...result.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_outlined, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning)),
                  ],
                ),
              )),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validateInvoice,
            child: const Text('Validate Again'),
          ),
        ),
      ],
    );
  }

  Future<void> _validateInvoice() async {
    setState(() {
      _isValidating = true;
    });

    try {
      final result = await _validationService.validateInvoice(widget.invoiceId);
      setState(() {
        _validationResult = result;
        _isValidating = false;
      });
      
      widget.onValidationComplete?.call(result);
    } catch (e) {
      setState(() {
        _validationResult = InvoiceValidationResult(
          isValid: false,
          errors: ['Validation failed: ${e.toString()}'],
          warnings: [],
        );
        _isValidating = false;
      });
    }
  }
}
