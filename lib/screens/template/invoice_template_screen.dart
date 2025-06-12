import 'package:flutter/material.dart';
import '../../models/template/invoice_template_model.dart';
import '../../services/template/invoice_template_service.dart';
import '../../widgets/template/template_card.dart';
import 'template_editor_screen.dart';
import 'template_preview_screen.dart';

class InvoiceTemplateScreen extends StatefulWidget {
  const InvoiceTemplateScreen({super.key});

  @override
  State<InvoiceTemplateScreen> createState() => _InvoiceTemplateScreenState();
}

class _InvoiceTemplateScreenState extends State<InvoiceTemplateScreen> {
  final InvoiceTemplateService _templateService = InvoiceTemplateService();
  List<InvoiceTemplate> _templates = [];
  InvoiceTemplate? _selectedTemplate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final templates = await _templateService.getTemplates();
      final defaultTemplate = await _templateService.getDefaultTemplate();
      
      setState(() {
        _templates = templates;
        _selectedTemplate = defaultTemplate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: $e')),
        );
      }
    }
  }

  Future<void> _createNewTemplate() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _NewTemplateDialog(),
    );

    if (result != null) {
      final newTemplate = _templateService.createNewTemplate(
        name: result['name'],
        description: result['description'],
        style: result['style'],
        layout: result['layout'],
      );

      await _templateService.saveTemplate(newTemplate);
      await _loadTemplates();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TemplateEditorScreen(template: newTemplate),
          ),
        ).then((_) => _loadTemplates());
      }
    }
  }

  Future<void> _editTemplate(InvoiceTemplate template) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditorScreen(template: template),
      ),
    ).then((_) => _loadTemplates());
  }

  Future<void> _duplicateTemplate(InvoiceTemplate template) async {
    try {
      await _templateService.duplicateTemplate(template);
      await _loadTemplates();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template duplicated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating template: $e')),
        );
      }
    }
  }

  Future<void> _deleteTemplate(InvoiceTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _templateService.deleteTemplate(template.id);
        await _loadTemplates();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting template: $e')),
          );
        }
      }
    }
  }

  Future<void> _setDefaultTemplate(InvoiceTemplate template) async {
    try {
      await _templateService.setDefaultTemplate(template.id);
      await _loadTemplates();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${template.name} set as default template')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting default template: $e')),
        );
      }
    }
  }

  void _previewTemplate(InvoiceTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplatePreviewScreen(template: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iTaxInvoice Templates'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTemplates,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'import':
                  // TODO: Implement import functionality
                  break;
                case 'export':
                  // TODO: Implement export functionality
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import Template'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export Template'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? _buildEmptyState()
              : _buildTemplateGrid(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewTemplate,
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Templates Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first iTaxInvoice template',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewTemplate,
            icon: const Icon(Icons.add),
            label: const Text('Create Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return TemplateCard(
          template: template,
          isSelected: _selectedTemplate?.id == template.id,
          onTap: () => _previewTemplate(template),
          onEdit: () => _editTemplate(template),
          onDuplicate: () => _duplicateTemplate(template),
          onDelete: template.isDefault ? null : () => _deleteTemplate(template),
          onSetDefault: template.isDefault ? null : () => _setDefaultTemplate(template),
        );
      },
    );
  }
}

class _NewTemplateDialog extends StatefulWidget {
  @override
  State<_NewTemplateDialog> createState() => _NewTemplateDialogState();
}

class _NewTemplateDialogState extends State<_NewTemplateDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TemplateStyle _selectedStyle = TemplateStyle.modern;
  TemplateLayout _selectedLayout = TemplateLayout.standard;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Template'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'Enter template name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter template description',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TemplateStyle>(
              value: _selectedStyle,
              decoration: const InputDecoration(labelText: 'Style'),
              items: TemplateStyle.values.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(style.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedStyle = value!);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TemplateLayout>(
              value: _selectedLayout,
              decoration: const InputDecoration(labelText: 'Layout'),
              items: TemplateLayout.values.map((layout) {
                return DropdownMenuItem(
                  value: layout,
                  child: Text(layout.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLayout = value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'description': _descriptionController.text.trim(),
                'style': _selectedStyle,
                'layout': _selectedLayout,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
