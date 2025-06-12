import 'package:flutter/material.dart';
import '../../models/template/invoice_template_model.dart';
import '../../services/template/invoice_template_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/template/branding_editor_widget.dart';
import '../../widgets/template/colors_editor_widget.dart';
import '../../widgets/template/typography_editor_widget.dart';
import '../../widgets/template/settings_editor_widget.dart';
import 'template_preview_screen.dart';

class TemplateEditorScreen extends StatefulWidget {
  final InvoiceTemplate? template;

  const TemplateEditorScreen({
    Key? key,
    this.template,
  }) : super(key: key);

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen>
    with SingleTickerProviderStateMixin {
  final InvoiceTemplateService _templateService = InvoiceTemplateService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  late TabController _tabController;
  late InvoiceTemplate _currentTemplate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeTemplate();
  }

  void _initializeTemplate() {
    if (widget.template != null) {
      _currentTemplate = widget.template!;
      _nameController.text = _currentTemplate.name;
    } else {
      // Create new template with default values
      final now = DateTime.now();
      _currentTemplate = InvoiceTemplate(
        id: now.millisecondsSinceEpoch.toString(),
        name: 'New Template',
        style: TemplateStyle.modern,
        layout: TemplateLayout.standard,
        branding: _getDefaultBranding(),
        colors: TemplateColors.defaultColors,
        typography: TemplateTypography.defaultTypography,
        settings: const TemplateSettings(),
        createdAt: now,
        updatedAt: now,
      );
      _nameController.text = _currentTemplate.name;
    }
  }

  CompanyBranding _getDefaultBranding() {
    return const CompanyBranding(
      companyName: 'Your Company Name',
      address: '123 Business Street',
      city: 'Mumbai',
      state: 'Maharashtra',
      pinCode: '400001',
      country: 'India',
      gstin: '27AADCB2230M1ZP',
      pan: 'AADCB2230M',
      email: 'contact@yourcompany.com',
      phone: '+91 9876543210',
      website: 'www.yourcompany.com',
      tagline: 'Your Business Tagline',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTemplate = _currentTemplate.copyWith(
        name: _nameController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await _templateService.saveTemplate(updatedTemplate);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        _showErrorSnackbar('Failed to save template');
      }
    } catch (e) {
      _showErrorSnackbar('Error saving template: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updateTemplate(InvoiceTemplate template) {
    setState(() {
      _currentTemplate = template;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template != null ? 'Edit Template' : 'Create Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplatePreviewScreen(
                    template: _currentTemplate.copyWith(name: _nameController.text),
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveTemplate,
              child: const Text('Save'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.info_outline)),
            Tab(text: 'Branding', icon: Icon(Icons.business)),
            Tab(text: 'Colors', icon: Icon(Icons.palette)),
            Tab(text: 'Typography', icon: Icon(Icons.text_fields)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralTab(),
            BrandingEditorWidget(
              branding: _currentTemplate.branding,
              onBrandingChanged: (branding) {
                _updateTemplate(_currentTemplate.copyWith(branding: branding));
              },
            ),
            ColorsEditorWidget(
              colors: _currentTemplate.colors,
              onColorsChanged: (colors) {
                _updateTemplate(_currentTemplate.copyWith(colors: colors));
              },
            ),
            TypographyEditorWidget(
              typography: _currentTemplate.typography,
              onTypographyChanged: (typography) {
                _updateTemplate(_currentTemplate.copyWith(typography: typography));
              },
            ),
            SettingsEditorWidget(
              settings: _currentTemplate.settings,
              onSettingsChanged: (settings) {
                _updateTemplate(_currentTemplate.copyWith(settings: settings));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Template Name',
            hint: 'Enter template name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Template name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Template Style',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStyleSelector(),
          const SizedBox(height: 24),
          Text(
            'Template Layout',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLayoutSelector(),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TemplateStyle.values.map((style) {
        final isSelected = _currentTemplate.style == style;
        return FilterChip(
          label: Text(_getStyleText(style)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              _updateTemplate(_currentTemplate.copyWith(style: style));
            }
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildLayoutSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TemplateLayout.values.map((layout) {
        final isSelected = _currentTemplate.layout == layout;
        return FilterChip(
          label: Text(_getLayoutText(layout)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              _updateTemplate(_currentTemplate.copyWith(layout: layout));
            }
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  String _getStyleText(TemplateStyle style) {
    switch (style) {
      case TemplateStyle.classic:
        return 'Classic';
      case TemplateStyle.modern:
        return 'Modern';
      case TemplateStyle.minimal:
        return 'Minimal';
      case TemplateStyle.professional:
        return 'Professional';
      case TemplateStyle.creative:
        return 'Creative';
    }
  }

  String _getLayoutText(TemplateLayout layout) {
    switch (layout) {
      case TemplateLayout.standard:
        return 'Standard';
      case TemplateLayout.compact:
        return 'Compact';
      case TemplateLayout.detailed:
        return 'Detailed';
      case TemplateLayout.itemFocused:
        return 'Item Focused';
    }
  }
}
