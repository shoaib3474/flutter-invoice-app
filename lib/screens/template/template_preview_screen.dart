import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/template/invoice_template_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../services/pdf/invoice_pdf_service.dart';
import '../../widgets/invoice/invoice_pdf_preview_widget.dart';

class TemplatePreviewScreen extends StatelessWidget {
  const TemplatePreviewScreen({
    super.key,
    required this.template,
  });

  final InvoiceTemplate template;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${template.name}'),
        backgroundColor: template.colors.primaryColor,
        foregroundColor: template.colors.textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveTemplate(context),
          ),
        ],
      ),
      body: Container(
        color: template.colors.backgroundColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            template.settings.marginTop,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: template.settings.showBorder
                  ? Border.all(color: template.colors.borderColor)
                  : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(template.settings.marginLeft),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (template.settings.showHeader) _buildHeader(),
                  const SizedBox(height: 20),
                  _buildInvoiceDetails(),
                  const SizedBox(height: 20),
                  _buildItemsTable(),
                  const SizedBox(height: 20),
                  _buildTotals(),
                  if (template.settings.showTermsAndConditions) ...[
                    const SizedBox(height: 20),
                    _buildTermsAndConditions(),
                  ],
                  if (template.settings.showFooter) ...[
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: template.colors.headerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (template.settings.showCompanyLogo && template.branding.logoPath != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(template.branding.logoPath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.branding.companyName,
                  style: TextStyle(
                    fontSize: template.typography.headerFontSize,
                    fontWeight: template.typography.headerFontWeight,
                    color: template.colors.textColor,
                    fontFamily: template.typography.fontFamily,
                  ),
                ),
                if (template.branding.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    template.branding.address!,
                    style: TextStyle(
                      fontSize: template.typography.bodyFontSize,
                      color: template.colors.textColor,
                      fontFamily: template.typography.fontFamily,
                    ),
                  ),
                ],
                if (template.branding.phone != null || template.branding.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${template.branding.phone ?? ''} ${template.branding.email ?? ''}',
                    style: TextStyle(
                      fontSize: template.typography.captionFontSize,
                      color: template.colors.textColor,
                      fontFamily: template.typography.fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: template.colors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE',
            style: TextStyle(
              fontSize: template.typography.headerFontSize,
              fontWeight: template.typography.headerFontWeight,
              color: template.colors.primaryColor,
              fontFamily: template.typography.fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Number: INV-001',
                      style: TextStyle(
                        fontSize: template.typography.bodyFontSize,
                        color: template.colors.textColor,
                        fontFamily: template.typography.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: template.typography.bodyFontSize,
                        color: template.colors.textColor,
                        fontFamily: template.typography.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill To:',
                      style: TextStyle(
                        fontSize: template.typography.bodyFontSize,
                        fontWeight: FontWeight.bold,
                        color: template.colors.textColor,
                        fontFamily: template.typography.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customer Name\nCustomer Address\nCity, State - PIN',
                      style: TextStyle(
                        fontSize: template.typography.bodyFontSize,
                        color: template.colors.textColor,
                        fontFamily: template.typography.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: template.colors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: template.colors.headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: template.typography.bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: template.colors.textColor,
                      fontFamily: template.typography.fontFamily,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: template.typography.bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: template.colors.textColor,
                      fontFamily: template.typography.fontFamily,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Rate',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: template.typography.bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: template.colors.textColor,
                      fontFamily: template.typography.fontFamily,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: template.typography.bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: template.colors.textColor,
                      fontFamily: template.typography.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(3, (index) => _buildItemRow(index + 1)),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: template.colors.borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Sample Item $index',
              style: TextStyle(
                fontSize: template.typography.bodyFontSize,
                color: template.colors.textColor,
                fontFamily: template.typography.fontFamily,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '1',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: template.typography.bodyFontSize,
                color: template.colors.textColor,
                fontFamily: template.typography.fontFamily,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '₹${(index * 100).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: template.typography.bodyFontSize,
                color: template.colors.textColor,
                fontFamily: template.typography.fontFamily,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '₹${(index * 100).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: template.typography.bodyFontSize,
                color: template.colors.textColor,
                fontFamily: template.typography.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: template.colors.backgroundColor,
        border: Border.all(color: template.colors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal:', '₹600.00'),
          _buildTotalRow('Tax (18%):', '₹108.00'),
          const Divider(),
          _buildTotalRow('Total:', '₹708.00', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: template.typography.bodyFontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: template.colors.textColor,
              fontFamily: template.typography.fontFamily,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: template.typography.bodyFontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? template.colors.primaryColor : template.colors.textColor,
              fontFamily: template.typography.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: template.colors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: template.typography.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: template.colors.textColor,
              fontFamily: template.typography.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            template.settings.termsAndConditions ?? 'Terms and conditions apply.',
            style: TextStyle(
              fontSize: template.typography.captionFontSize,
              color: template.colors.textColor,
              fontFamily: template.typography.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: template.colors.headerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          template.settings.footerText ?? 'Thank you for your business!',
          style: TextStyle(
            fontSize: template.typography.bodyFontSize,
            color: template.colors.textColor,
            fontFamily: template.typography.fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _saveTemplate(BuildContext context) {
    // TODO: Implement template saving logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template saved successfully!'),
      ),
    );
  }
}
