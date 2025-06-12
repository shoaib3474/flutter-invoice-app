#!/bin/bash

echo "🔧 Fixing all critical errors in Flutter Invoice App..."

# Add missing dependencies to pubspec.yaml
echo "📦 Adding missing dependencies..."
if ! grep -q "share_plus:" pubspec.yaml; then
    sed -i '/dependencies:/a\  share_plus: ^7.0.2' pubspec.yaml
fi

# Fix reconciliation_history_screen.dart
echo "🔧 Fixing reconciliation_history_screen.dart..."
cat > lib/screens/reconciliation_history_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/reconciliation/reconciliation_result_model.dart';
import '../services/reconciliation/reconciliation_service.dart';
import '../widgets/common/loading_indicator.dart';

class ReconciliationHistoryScreen extends StatefulWidget {
  const ReconciliationHistoryScreen({super.key});

  @override
  State<ReconciliationHistoryScreen> createState() => _ReconciliationHistoryScreenState();
}

class _ReconciliationHistoryScreenState extends State<ReconciliationHistoryScreen> {
  final ReconciliationService _reconciliationService = ReconciliationService();
  List<ReconciliationResult> _reconciliations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReconciliations();
  }

  Future<void> _loadReconciliations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final reconciliations = await _reconciliationService.getReconciliationHistory();
      
      if (mounted) {
        setState(() {
          _reconciliations = reconciliations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReconciliation(String id) async {
    try {
      await _reconciliationService.deleteReconciliation(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reconciliation deleted successfully')),
        );
        await _loadReconciliations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting reconciliation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReconciliations,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReconciliations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reconciliations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No reconciliation history found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _reconciliations.length,
      itemBuilder: (context, index) {
        final reconciliation = _reconciliations[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('Reconciliation ${reconciliation.id}'),
            subtitle: Text('Date: ${reconciliation.createdAt.toString().split(' ')[0]}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteReconciliation(reconciliation.id);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
EOF

# Create missing enum files
echo "📝 Creating missing enum files..."
mkdir -p lib/models/reconciliation
cat > lib/models/reconciliation/reconciliation_type.dart << 'EOF'
enum ReconciliationType {
  gstr1,
  gstr2a,
  gstr2b,
  gstr3b,
  purchase,
}

extension ReconciliationTypeExtension on ReconciliationType {
  String get displayName {
    switch (this) {
      case ReconciliationType.gstr1:
        return 'GSTR-1';
      case ReconciliationType.gstr2a:
        return 'GSTR-2A';
      case ReconciliationType.gstr2b:
        return 'GSTR-2B';
      case ReconciliationType.gstr3b:
        return 'GSTR-3B';
      case ReconciliationType.purchase:
        return 'Purchase';
    }
  }
}
EOF

# Fix reconciliation_screen.dart
echo "🔧 Fixing reconciliation_screen.dart..."
cat > lib/screens/reconciliation_screen.dart << 'EOF'
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/reconciliation/reconciliation_result_model.dart';
import '../models/reconciliation/reconciliation_type.dart';
import '../services/reconciliation/reconciliation_service.dart';
import '../widgets/common/loading_indicator.dart';

class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  final ReconciliationService _reconciliationService = ReconciliationService();
  ReconciliationType _selectedType = ReconciliationType.gstr1;
  List<ReconciliationResult> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _performReconciliation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _reconciliationService.performReconciliation(_selectedType);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Reconciliation Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReconciliationType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Reconciliation Type',
                border: OutlineInputBorder(),
              ),
              items: ReconciliationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _performReconciliation,
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Start Reconciliation'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _results.isEmpty ? null : _exportResults,
          icon: const Icon(Icons.download),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performReconciliation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No reconciliation performed yet'),
            SizedBox(height: 8),
            Text('Select a type and click "Start Reconciliation"'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('Result ${index + 1}'),
            subtitle: Text('Status: ${result.status}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'view':
                    _viewDetails(result);
                    break;
                  case 'export':
                    await _exportSingleResult(result);
                    break;
                  case 'delete':
                    _deleteResult(result);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  String _getTypeDisplayName(ReconciliationType type) {
    switch (type) {
      case ReconciliationType.gstr1:
        return 'GSTR-1';
      case ReconciliationType.gstr2a:
        return 'GSTR-2A';
      case ReconciliationType.gstr2b:
        return 'GSTR-2B';
      case ReconciliationType.gstr3b:
        return 'GSTR-3B';
      case ReconciliationType.purchase:
        return 'Purchase';
    }
  }

  Future<void> _exportResults() async {
    try {
      final file = await _reconciliationService.exportResults(_results);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Results exported successfully')),
        );
        
        // Share the file
        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportSingleResult(ReconciliationResult result) async {
    try {
      final file = await _reconciliationService.exportResults([result]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result exported successfully')),
        );
        
        // Share the file
        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _viewDetails(ReconciliationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reconciliation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${result.id}'),
            Text('Status: ${result.status}'),
            Text('Created: ${result.createdAt}'),
            if (result.discrepancies?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              const Text('Discrepancies:'),
              ...result.discrepancies!.map((d) => Text('• $d')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteResult(ReconciliationResult result) {
    setState(() {
      _results.remove(result);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result deleted')),
      );
    }
  }
}
EOF

# Create missing template enum files
echo "📝 Creating template enum files..."
mkdir -p lib/models/template
cat > lib/models/template/template_enums.dart << 'EOF'
enum TemplateStyle {
  modern,
  classic,
  minimal,
  professional,
  creative,
}

enum TemplateLayout {
  standard,
  compact,
  detailed,
  summary,
}

extension TemplateStyleExtension on TemplateStyle {
  String get displayName {
    switch (this) {
      case TemplateStyle.modern:
        return 'Modern';
      case TemplateStyle.classic:
        return 'Classic';
      case TemplateStyle.minimal:
        return 'Minimal';
      case TemplateStyle.professional:
        return 'Professional';
      case TemplateStyle.creative:
        return 'Creative';
    }
  }
}

extension TemplateLayoutExtension on TemplateLayout {
  String get displayName {
    switch (this) {
      case TemplateLayout.standard:
        return 'Standard';
      case TemplateLayout.compact:
        return 'Compact';
      case TemplateLayout.detailed:
        return 'Detailed';
      case TemplateLayout.summary:
        return 'Summary';
    }
  }
}
EOF

# Create missing template model classes
cat > lib/models/template/template_models.dart << 'EOF'
import 'package:flutter/material.dart';
import 'template_enums.dart';

class TemplateColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color text;

  const TemplateColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.text,
  });

  factory TemplateColors.defaultColors() {
    return const TemplateColors(
      primary: Colors.blue,
      secondary: Colors.blueGrey,
      accent: Colors.orange,
      background: Colors.white,
      text: Colors.black,
    );
  }

  TemplateColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? text,
  }) {
    return TemplateColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      text: text ?? this.text,
    );
  }
}

class TemplateTypography {
  final String fontFamily;
  final double headerSize;
  final double bodySize;
  final double captionSize;
  final FontWeight headerWeight;
  final FontWeight bodyWeight;

  const TemplateTypography({
    required this.fontFamily,
    required this.headerSize,
    required this.bodySize,
    required this.captionSize,
    required this.headerWeight,
    required this.bodyWeight,
  });

  factory TemplateTypography.defaultTypography() {
    return const TemplateTypography(
      fontFamily: 'Roboto',
      headerSize: 24,
      bodySize: 14,
      captionSize: 12,
      headerWeight: FontWeight.bold,
      bodyWeight: FontWeight.normal,
    );
  }

  TemplateTypography copyWith({
    String? fontFamily,
    double? headerSize,
    double? bodySize,
    double? captionSize,
    FontWeight? headerWeight,
    FontWeight? bodyWeight,
  }) {
    return TemplateTypography(
      fontFamily: fontFamily ?? this.fontFamily,
      headerSize: headerSize ?? this.headerSize,
      bodySize: bodySize ?? this.bodySize,
      captionSize: captionSize ?? this.captionSize,
      headerWeight: headerWeight ?? this.headerWeight,
      bodyWeight: bodyWeight ?? this.bodyWeight,
    );
  }
}

class CompanyBranding {
  final String? logoPath;
  final String companyName;
  final String? tagline;
  final Color brandColor;

  const CompanyBranding({
    this.logoPath,
    required this.companyName,
    this.tagline,
    required this.brandColor,
  });

  factory CompanyBranding.defaultBranding() {
    return const CompanyBranding(
      companyName: 'Your Company',
      brandColor: Colors.blue,
    );
  }

  CompanyBranding copyWith({
    String? logoPath,
    String? companyName,
    String? tagline,
    Color? brandColor,
  }) {
    return CompanyBranding(
      logoPath: logoPath ?? this.logoPath,
      companyName: companyName ?? this.companyName,
      tagline: tagline ?? this.tagline,
      brandColor: brandColor ?? this.brandColor,
    );
  }
}

class TemplateSettings {
  final bool showLogo;
  final bool showWatermark;
  final bool showPageNumbers;
  final bool showTermsAndConditions;
  final String? customFooter;

  const TemplateSettings({
    this.showLogo = true,
    this.showWatermark = false,
    this.showPageNumbers = true,
    this.showTermsAndConditions = true,
    this.customFooter,
  });

  TemplateSettings copyWith({
    bool? showLogo,
    bool? showWatermark,
    bool? showPageNumbers,
    bool? showTermsAndConditions,
    String? customFooter,
  }) {
    return TemplateSettings(
      showLogo: showLogo ?? this.showLogo,
      showWatermark: showWatermark ?? this.showWatermark,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      showTermsAndConditions: showTermsAndConditions ?? this.showTermsAndConditions,
      customFooter: customFooter ?? this.customFooter,
    );
  }
}
EOF

# Fix logo_settings_screen.dart
echo "🔧 Fixing logo_settings_screen.dart..."
cat > lib/screens/settings/logo_settings_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../services/settings/logo_service.dart';

class LogoSettingsScreen extends StatefulWidget {
  const LogoSettingsScreen({super.key});

  @override
  State<LogoSettingsScreen> createState() => _LogoSettingsScreenState();
}

class _LogoSettingsScreenState extends State<LogoSettingsScreen> {
  final LogoService _logoService = LogoService();
  late String? _logoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLogo();
  }

  Future<void> _loadCurrentLogo() async {
    setState(() => _isLoading = true);
    try {
      _logoPath = await _logoService.getCurrentLogoPath();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading logo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectLogo() async {
    setState(() => _isLoading = true);
    try {
      final newLogoPath = await _logoService.selectLogo();
      if (newLogoPath != null) {
        setState(() => _logoPath = newLogoPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting logo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeLogo() async {
    setState(() => _isLoading = true);
    try {
      await _logoService.removeLogo();
      setState(() => _logoPath = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo removed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing logo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Logo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _logoPath != null
                                ? Image.asset(
                                    _logoPath!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error, size: 48, color: Colors.red),
                                            Text('Error loading logo'),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image, size: 48, color: Colors.grey),
                                        Text('No logo selected'),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _selectLogo,
                                  icon: const Icon(Icons.upload),
                                  label: Text(_logoPath != null ? 'Change Logo' : 'Select Logo'),
                                ),
                              ),
                              if (_logoPath != null) ...[
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _removeLogo,
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Remove'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Logo Guidelines',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Recommended size: 300x100 pixels'),
                          Text('• Supported formats: PNG, JPG, JPEG'),
                          Text('• Maximum file size: 5MB'),
                          Text('• Transparent background recommended for PNG'),
                          Text('• Logo will be automatically resized to fit'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
EOF

# Run flutter pub get to install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Fix remaining issues
echo "🔧 Fixing remaining critical issues..."
flutter analyze --no-fatal-infos 2>&1 | head -50

echo "✅ Critical error fixes completed!"
echo "🔍 Run 'flutter analyze' to check remaining issues"
echo "🚀 Run 'flutter build apk' to test the build"
EOF

```bat file="scripts/fix_all_critical_errors_final.bat"
@echo off
echo 🔧 Fixing all critical errors in Flutter Invoice App...

echo 📦 Adding missing dependencies...
findstr /C:"share_plus:" pubspec.yaml >nul || (
    powershell -Command "(Get-Content pubspec.yaml) -replace 'dependencies:', 'dependencies:^n  share_plus: ^7.0.2' | Set-Content pubspec.yaml"
)

echo 🔧 Fixing reconciliation_history_screen.dart...
(
echo import 'package:flutter/material.dart';
echo import '../models/reconciliation/reconciliation_result_model.dart';
echo import '../services/reconciliation/reconciliation_service.dart';
echo import '../widgets/common/loading_indicator.dart';
echo.
echo class ReconciliationHistoryScreen extends StatefulWidget {
echo   const ReconciliationHistoryScreen^({super.key}^);
echo.
echo   @override
echo   State^<ReconciliationHistoryScreen^> createState^(^) =^> _ReconciliationHistoryScreenState^(^);
echo }
echo.
echo class _ReconciliationHistoryScreenState extends State^<ReconciliationHistoryScreen^> {
echo   final ReconciliationService _reconciliationService = ReconciliationService^(^);
echo   List^<ReconciliationResult^> _reconciliations = [];
echo   bool _isLoading = true;
echo   String? _error;
echo.
echo   @override
echo   void initState^(^) {
echo     super.initState^(^);
echo     _loadReconciliations^(^);
echo   }
echo.
echo   Future^<void^> _loadReconciliations^(^) async {
echo     try {
echo       setState^(^(^) {
echo         _isLoading = true;
echo         _error = null;
echo       }^);
echo       
echo       final reconciliations = await _reconciliationService.getReconciliationHistory^(^);
echo       
echo       if ^(mounted^) {
echo         setState^(^(^) {
echo           _reconciliations = reconciliations;
echo           _isLoading = false;
echo         }^);
echo       }
echo     } catch ^(e^) {
echo       if ^(mounted^) {
echo         setState^(^(^) {
echo           _error = e.toString^(^);
echo           _isLoading = false;
echo         }^);
echo       }
echo     }
echo   }
echo.
echo   @override
echo   Widget build^(BuildContext context^) {
echo     return Scaffold^(
echo       appBar: AppBar^(
echo         title: const Text^('Reconciliation History'^),
echo       ^),
echo       body: _isLoading 
echo         ? const Center^(child: LoadingIndicator^(^)^)
echo         : ListView.builder^(
echo             itemCount: _reconciliations.length,
echo             itemBuilder: ^(context, index^) {
echo               final reconciliation = _reconciliations[index];
echo               return ListTile^(
echo                 title: Text^('Reconciliation ${reconciliation.id}'^),
echo                 subtitle: Text^('Date: ${reconciliation.createdAt}'^),
echo               ^);
echo             },
echo           ^),
echo     ^);
echo   }
echo }
) > lib\screens\reconciliation_history_screen.dart

echo 📦 Installing dependencies...
flutter pub get

echo ✅ Critical error fixes completed!
echo 🔍 Run 'flutter analyze' to check remaining issues
echo 🚀 Run 'flutter build apk' to test the build
