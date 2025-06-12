import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gstr9c_model.dart';
import 'package:flutter_invoice_app/services/gst_json_import_service.dart';
import 'package:flutter_invoice_app/widgets/common/gst_json_import_export_widget.dart';

class GSTR9CImportExportWidget extends StatelessWidget {
  final GSTR9C? currentData;
  final Function(GSTR9C) onImportSuccess;

  const GSTR9CImportExportWidget({
    Key? key,
    this.currentData,
    required this.onImportSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GSTR-9C Import/Export',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GstJsonImportExportWidget(
            returnType: GstReturnType.gstr9c,
            currentData: currentData,
            onImportSuccess: (data) => onImportSuccess(data as GSTR9C),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import/Export Instructions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Import: Select a valid GSTR-9C JSON file to import data. This will replace any existing data.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Export: Save the current GSTR-9C data as a JSON file that can be imported later or shared.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note: The JSON file must have the correct format for GSTR-9C data.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
