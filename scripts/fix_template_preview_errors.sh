#!/bin/bash

echo "Fixing template preview screen errors..."

# Fix import ordering and constructor issues
echo "Fixing import ordering and constructor issues..."

# Add missing imports to template files
echo "Adding missing Flutter imports..."
find lib/models/template/ -name "*.dart" -exec sed -i '1i import '\''package:flutter/material.dart'\'';' {} \;

# Fix withOpacity deprecation
echo "Fixing withOpacity deprecation..."
find lib/screens/template/ -name "*.dart" -exec sed -i 's/\.withOpacity($$[^)]*$$)/\.withValues(alpha: \1)/g' {} \;

# Fix constructor parameter ordering
echo "Fixing constructor parameter ordering..."
sed -i 's/const TemplatePreviewScreen({$/const TemplatePreviewScreen({/' lib/screens/template/template_preview_screen.dart
sed -i 's/super.key,$/super.key,/' lib/screens/template/template_preview_screen.dart
sed -i 's/required this.template,$/required this.template,/' lib/screens/template/template_preview_screen.dart

echo "Template preview errors fixed!"
