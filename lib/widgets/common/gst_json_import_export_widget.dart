import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/services/gst_json_import_service.dart';
import 'package:flutter_invoice_app/widgets/common/custom_button.dart';
import 'package:flutter_invoice_app/widgets/common/loading_indicator.dart';

class GstJsonImportExportWidget extends StatefulWidget {
  const GstJsonImportExportWidget({
    required this.returnType,
    required this.onImportSuccess,
    Key? key,
    this.currentData,
  }) : super(key: key);
  final GstReturnType returnType;
  final dynamic currentData;
  final Function(dynamic) onImportSuccess;

  @override
  // ignore: library_private_types_in_public_api
  _GstJsonImportExportWidgetState createState() =>
      _GstJsonImportExportWidgetState();
}

class _GstJsonImportExportWidgetState extends State<GstJsonImportExportWidget> {
  final GstJsonImportService _importService = GstJsonImportService();

  bool _isLoading = false;
  String _statusMessage = '';
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import/Export ${_getReturnTypeLabel()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: LoadingIndicator())
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Import JSON',
                          onPressed: _importJson,
                          icon: Icons.upload_file,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          label: 'Export JSON',
                          onPressed:
                              widget.currentData != null ? _exportJson : () {},
                          icon: Icons.download,
                        ),
                      ),
                    ],
                  ),
                  if (_statusMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildStatusMessage(),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isError ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isError ? Icons.error : Icons.check_circle,
            color: _isError ? Colors.red.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isError ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReturnTypeLabel() {
    switch (widget.returnType) {
      case GstReturnType.gstr1:
        return 'GSTR-1';
      case GstReturnType.gstr3b:
        return 'GSTR-3B';
      case GstReturnType.gstr9:
        return 'GSTR-9';
      case GstReturnType.gstr9c:
        return 'GSTR-9C';
    }
  }

  Future<void> _importJson() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });

    try {
      final data = await _importService.importFromJsonFile(widget.returnType);

      widget.onImportSuccess(data);

      setState(() {
        _statusMessage = '${_getReturnTypeLabel()} data imported successfully';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error importing data: ${e.toString()}';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportJson() async {
    if (widget.currentData == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });

    try {
      final filePath = await _importService.exportToJsonFile(
        widget.returnType,
        widget.currentData,
      );

      setState(() {
        _statusMessage = 'Exported to $filePath';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting data: ${e.toString()}';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
