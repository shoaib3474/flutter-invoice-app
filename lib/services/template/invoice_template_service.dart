import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/template/invoice_template_model.dart';

class InvoiceTemplateService {
  static const String _templatesKey = 'itax_invoice_templates';
  static const String _defaultTemplateKey = 'itax_default_template';

  // Get all templates
  Future<List<InvoiceTemplate>> getTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_templatesKey);
      
      if (templatesJson == null) {
        // Return default templates if none exist
        final defaultTemplates = _getDefaultTemplates();
        await saveTemplates(defaultTemplates);
        return defaultTemplates;
      }

      final List<dynamic> templatesList = json.decode(templatesJson);
      return templatesList
          .map((json) => InvoiceTemplate.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading templates: $e');
      return _getDefaultTemplates();
    }
  }

  // Save templates
  Future<void> saveTemplates(List<InvoiceTemplate> templates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = json.encode(
        templates.map((template) => template.toJson()).toList(),
      );
      await prefs.setString(_templatesKey, templatesJson);
    } catch (e) {
      print('Error saving templates: $e');
      throw Exception('Failed to save templates');
    }
  }

  // Save single template
  Future<void> saveTemplate(InvoiceTemplate template) async {
    final templates = await getTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    
    if (index >= 0) {
      templates[index] = template.copyWith(updatedAt: DateTime.now());
    } else {
      templates.add(template);
    }
    
    await saveTemplates(templates);
  }

  // Delete template
  Future<void> deleteTemplate(String templateId) async {
    final templates = await getTemplates();
    templates.removeWhere((template) => template.id == templateId);
    await saveTemplates(templates);
  }

  // Get template by ID
  Future<InvoiceTemplate?> getTemplate(String templateId) async {
    final templates = await getTemplates();
    try {
      return templates.firstWhere((template) => template.id == templateId);
    } catch (e) {
      return null;
    }
  }

  // Get default template
  Future<InvoiceTemplate> getDefaultTemplate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultTemplateId = prefs.getString(_defaultTemplateKey);
      
      if (defaultTemplateId != null) {
        final template = await getTemplate(defaultTemplateId);
        if (template != null) return template;
      }
      
      // Return first template if no default set
      final templates = await getTemplates();
      return templates.isNotEmpty ? templates.first : _getDefaultTemplates().first;
    } catch (e) {
      return _getDefaultTemplates().first;
    }
  }

  // Set default template
  Future<void> setDefaultTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultTemplateKey, templateId);
  }

  // Duplicate template
  Future<InvoiceTemplate> duplicateTemplate(InvoiceTemplate template) async {
    final newTemplate = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${template.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDefault: false,
    );
    
    await saveTemplate(newTemplate);
    return newTemplate;
  }

  // Export template to file
  Future<String> exportTemplate(InvoiceTemplate template) async {
    try {
      final templateJson = json.encode(template.toJson());
      return templateJson;
    } catch (e) {
      throw Exception('Failed to export template: $e');
    }
  }

  // Import template from JSON
  Future<InvoiceTemplate> importTemplate(String templateJson) async {
    try {
      final templateData = json.decode(templateJson);
      final template = InvoiceTemplate.fromJson(templateData).copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: false,
      );
      
      await saveTemplate(template);
      return template;
    } catch (e) {
      throw Exception('Failed to import template: $e');
    }
  }

  // Get default templates
  List<InvoiceTemplate> _getDefaultTemplates() {
    final now = DateTime.now();
    final defaultBranding = CompanyBranding(
      companyName: 'Itax Easy Pvt Ltd',
      tagline: 'Simplifying Tax Compliance',
      address: 'Business Address',
      city: 'City',
      state: 'State',
      pincode: '000000',
      country: 'India',
      email: 'info@itaxeasy.com',
      phone: '+91 9999999999',
      website: 'www.itaxeasy.com',
    );

    return [
      InvoiceTemplate(
        id: 'itax_classic_template',
        name: 'iTaxInvoice Classic',
        description: 'Traditional professional invoice template',
        style: TemplateStyle.classic,
        layout: TemplateLayout.standard,
        branding: defaultBranding,
        colors: const TemplateColors(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF757575),
          accent: Color(0xFF4CAF50),
        ),
        typography: const TemplateTypography(
          fontFamily: 'Roboto',
          headerFontSize: 24.0,
          titleFontSize: 18.0,
          bodyFontSize: 14.0,
        ),
        settings: const TemplateSettings(),
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      InvoiceTemplate(
        id: 'itax_modern_template',
        name: 'iTaxInvoice Modern',
        description: 'Clean and modern invoice design',
        style: TemplateStyle.modern,
        layout: TemplateLayout.standard,
        branding: defaultBranding,
        colors: const TemplateColors(
          primary: Color(0xFF2196F3),
          secondary: Color(0xFF607D8B),
          accent: Color(0xFFFF9800),
        ),
        typography: const TemplateTypography(
          fontFamily: 'Roboto',
          headerFontSize: 26.0,
          titleFontSize: 20.0,
          bodyFontSize: 14.0,
        ),
        settings: const TemplateSettings(),
        createdAt: now,
        updatedAt: now,
      ),
      InvoiceTemplate(
        id: 'itax_minimal_template',
        name: 'iTaxInvoice Minimal',
        description: 'Simple and clean minimal design',
        style: TemplateStyle.minimal,
        layout: TemplateLayout.compact,
        branding: defaultBranding,
        colors: const TemplateColors(
          primary: Color(0xFF424242),
          secondary: Color(0xFF9E9E9E),
          accent: Color(0xFF4CAF50),
        ),
        typography: const TemplateTypography(
          fontFamily: 'Roboto',
          headerFontSize: 22.0,
          titleFontSize: 16.0,
          bodyFontSize: 13.0,
        ),
        settings: const TemplateSettings(),
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Create new template
  InvoiceTemplate createNewTemplate({
    required String name,
    String? description,
    TemplateStyle style = TemplateStyle.modern,
    TemplateLayout layout = TemplateLayout.standard,
  }) {
    final now = DateTime.now();
    return InvoiceTemplate(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description ?? 'Custom iTaxInvoice template',
      style: style,
      layout: layout,
      branding: CompanyBranding(
        companyName: 'Itax Easy Pvt Ltd',
        tagline: 'Simplifying Tax Compliance',
      ),
      colors: const TemplateColors(),
      typography: const TemplateTypography(),
      settings: const TemplateSettings(),
      createdAt: now,
      updatedAt: now,
    );
  }

  // Validate template
  bool validateTemplate(InvoiceTemplate template) {
    if (template.name.isEmpty) return false;
    if (template.branding.companyName.isEmpty) return false;
    return true;
  }

  // Get template preview data
  Map<String, dynamic> getTemplatePreviewData() {
    return {
      'invoiceNumber': 'INV-2024-001',
      'invoiceDate': DateTime.now(),
      'dueDate': DateTime.now().add(const Duration(days: 30)),
      'customerName': 'Sample Customer',
      'customerAddress': 'Customer Address\nCity, State - 123456',
      'customerGSTIN': '29ABCDE1234F1Z5',
      'items': [
        {
          'description': 'Software Development Services',
          'hsnSac': '998314',
          'quantity': 1,
          'unit': 'Nos',
          'rate': 10000.0,
          'gstRate': 18.0,
        },
        {
          'description': 'Technical Consultation',
          'hsnSac': '998314',
          'quantity': 2,
          'unit': 'Hrs',
          'rate': 2500.0,
          'gstRate': 18.0,
        },
      ],
      'subtotal': 15000.0,
      'totalGST': 2700.0,
      'grandTotal': 17700.0,
      'amountInWords': 'Seventeen Thousand Seven Hundred Rupees Only',
    };
  }
}
