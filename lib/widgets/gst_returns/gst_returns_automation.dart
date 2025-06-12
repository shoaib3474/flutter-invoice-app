// ignore_for_file: library_private_types_in_public_api, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gst_returns_provider.dart';
import '../../utils/api_exception.dart';

class GstReturnsAutomation extends StatefulWidget {
  const GstReturnsAutomation({
    required this.returnType,
    Key? key,
  }) : super(key: key);
  final String returnType;

  @override
  _GstReturnsAutomationState createState() => _GstReturnsAutomationState();
}

class _GstReturnsAutomationState extends State<GstReturnsAutomation> {
  bool _isLoading = false;
  String _period = '';
  String _financialYear = '';
  String _status = '';
  String _errorMessage = '';

  final _formKey = GlobalKey<FormState>();
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final List<String> _financialYears = [
    '2023-24',
    '2022-23',
    '2021-22',
    '2020-21',
    '2019-20'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automate ${widget.returnType} Filing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Period dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                    ),
                    items: _months.map((month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _period = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a period';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Financial Year dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Financial Year',
                      border: OutlineInputBorder(),
                    ),
                    items: _financialYears.map((year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _financialYear = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a financial year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _fetchData,
                        icon: const Icon(Icons.download),
                        label: const Text('Fetch Data'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _prepareReturn,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Prepare Return'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _fileReturn,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('File Return'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status and error display
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),

            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _status,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '';
      _errorMessage = '';
    });

    try {
      final provider = Provider.of<GstReturnsProvider>(context, listen: false);
      final response = await provider.fetchReturnData(
        returnType: widget.returnType,
        period: _period,
        financialYear: _financialYear,
      );

      setState(() {
        _status =
            'Successfully fetched ${widget.returnType} data for $_period $_financialYear';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = 'API Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _prepareReturn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '';
      _errorMessage = '';
    });

    try {
      final provider = Provider.of<GstReturnsProvider>(context, listen: false);
      final response = await provider.prepareReturn(
        returnType: widget.returnType,
        period: _period,
        financialYear: _financialYear,
      );

      setState(() {
        _status =
            'Successfully prepared ${widget.returnType} for $_period $_financialYear';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = 'API Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fileReturn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '';
      _errorMessage = '';
    });

    try {
      final provider = Provider.of<GstReturnsProvider>(context, listen: false);
      final response = await provider.fileReturn(
        returnType: widget.returnType,
        period: _period,
        financialYear: _financialYear,
      );

      setState(() {
        _status =
            'Successfully filed ${widget.returnType} for $_period $_financialYear';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = 'API Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
