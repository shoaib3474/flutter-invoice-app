// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gstr1_model.dart';

import '../../models/gst_returns/gstr1_model.dart';
import '../../services/gstr1_service.dart';
import '../import/data_import_widget.dart';

class GSTR1FormWidget extends StatefulWidget {
  const GSTR1FormWidget({
    required this.gstin,
    required this.returnPeriod,
    Key? key,
    required GSTR1Model gstr1Data,
    required Future<void> Function(GSTR1Model data) onSave,
  }) : super(key: key);
  final String gstin;
  final String returnPeriod;

  @override
  _GSTR1FormWidgetState createState() => _GSTR1FormWidgetState();
}

class _GSTR1FormWidgetState extends State<GSTR1FormWidget> {
  final GSTR1Service _gstr1Service = GSTR1Service();

  GSTR1Model? _gstr1Model;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGSTR1Data();
  }

  Future<void> _loadGSTR1Data() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gstr1Model = await _gstr1Service.getGSTR1(
        gstin: widget.gstin,
        returnPeriod: widget.returnPeriod,
      );

      setState(() {
        _gstr1Model = gstr1Model;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load GSTR1 data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleImportComplete(GSTR1Model importedModel) {
    setState(() {
      _gstr1Model = importedModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DataImportWidget(
          onImportComplete: _handleImportComplete,
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
            ),
          )
        else if (_gstr1Model != null)
          // Display GSTR1 form fields
          const Text('GSTR1 form fields will be displayed here')
        else
          const Text('No GSTR1 data available'),
      ],
    );
  }
}
