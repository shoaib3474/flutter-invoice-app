import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/template/invoice_template_model.dart';

class ColorsEditorWidget extends StatefulWidget {
  final TemplateColors colors;
  final Function(TemplateColors) onColorsChanged;

  const ColorsEditorWidget({
    Key? key,
    required this.colors,
    required this.onColorsChanged,
  }) : super(key: key);

  @override
  State<ColorsEditorWidget> createState() => _ColorsEditorWidgetState();
}

class _ColorsEditorWidgetState extends State<ColorsEditorWidget> {
  void _showColorPicker(String colorName, Color currentColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $colorName'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              _updateColor(colorName, color);
            },
            enableAlpha: false,
            displayThumbColor: true,
            showLabel: true,
            paletteType: PaletteType.hsl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _updateColor(String colorName, Color color) {
    TemplateColors updatedColors;
    
    switch (colorName) {
      case 'Primary Color':
        updatedColors = widget.colors.copyWith(primaryColor: color);
        break;
      case 'Secondary Color':
        updatedColors = widget.colors.copyWith(secondaryColor: color);
        break;
      case 'Accent Color':
        updatedColors = widget.colors.copyWith(accentColor: color);
        break;
      case 'Text Color':
        updatedColors = widget.colors.copyWith(textColor: color);
        break;
      case 'Background Color':
        updatedColors = widget.colors.copyWith(backgroundColor: color);
        break;
      case 'Header Color':
        updatedColors = widget.colors.copyWith(headerColor: color);
        break;
      case 'Border Color':
        updatedColors = widget.colors.copyWith(borderColor: color);
        break;
      default:
        return;
    }
    
    widget.onColorsChanged(updatedColors);
  }

  void _resetToDefaults() {
    widget.onColorsChanged(TemplateColors.defaultColors);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Template Colors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetToDefaults,
                child: const Text('Reset to Defaults'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildColorPreview(),
          const SizedBox(height: 24),
          _buildColorOptions(),
        ],
      ),
    );
  }

  Widget _buildColorPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.colors.backgroundColor,
        border: Border.all(color: widget.colors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.colors.headerColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Invoice Preview',
              style: TextStyle(
                color: widget.colors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Company Name',
            style: TextStyle(
              color: widget.colors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your invoice will look with the selected colors.',
            style: TextStyle(
              color: widget.colors.textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.colors.accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Accent Element',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOptions() {
    return Column(
      children: [
        _buildColorOption(
          'Primary Color',
          widget.colors.primaryColor,
          'Main brand color used for headers and important elements',
        ),
        _buildColorOption(
          'Secondary Color',
          widget.colors.secondaryColor,
          'Supporting color for secondary elements',
        ),
        _buildColorOption(
          'Accent Color',
          widget.colors.accentColor,
          'Highlight color for buttons and call-to-action elements',
        ),
        _buildColorOption(
          'Text Color',
          widget.colors.textColor,
          'Main text color for content',
        ),
        _buildColorOption(
          'Background Color',
          widget.colors.backgroundColor,
          'Background color of the invoice',
        ),
        _buildColorOption(
          'Header Color',
          widget.colors.headerColor,
          'Background color for header sections',
        ),
        _buildColorOption(
          'Border Color',
          widget.colors.borderColor,
          'Color for borders and dividers',
        ),
      ],
    );
  }

  Widget _buildColorOption(String name, Color color, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.edit),
        onTap: () => _showColorPicker(name, color),
      ),
    );
  }
}
