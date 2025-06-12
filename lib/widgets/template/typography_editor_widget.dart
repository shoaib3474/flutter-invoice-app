import 'package:flutter/material.dart';
import '../../models/template/template_enums.dart';

class TypographyEditorWidget extends StatelessWidget {
  final TemplateTypography typography;
  final Function(TemplateTypography) onTypographyChanged;

  const TypographyEditorWidget({
    super.key,
    required this.typography,
    required this.onTypographyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Typography Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildFontSizeSlider(
            'Header Font Size',
            typography.headerFontSize,
            (value) => onTypographyChanged(
              TemplateTypography(
                headerFontSize: value,
                titleFontSize: typography.titleFontSize,
                bodyFontSize: typography.bodyFontSize,
                captionFontSize: typography.captionFontSize,
                headerFontWeight: typography.headerFontWeight,
                titleFontWeight: typography.titleFontWeight,
              ),
            ),
          ),
          _buildFontSizeSlider(
            'Title Font Size',
            typography.titleFontSize,
            (value) => onTypographyChanged(
              TemplateTypography(
                headerFontSize: typography.headerFontSize,
                titleFontSize: value,
                bodyFontSize: typography.bodyFontSize,
                captionFontSize: typography.captionFontSize,
                headerFontWeight: typography.headerFontWeight,
                titleFontWeight: typography.titleFontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: 8,
          max: 32,
          divisions: 24,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
