// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/alerts/alert_configuration_model.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/providers/alert_provider.dart';
import 'package:provider/provider.dart';

class AlertConfigurationFormWidget extends StatefulWidget {
  const AlertConfigurationFormWidget({
    required this.onSaved,
    Key? key,
    this.initialConfig,
  }) : super(key: key);
  final AlertConfiguration? initialConfig;
  final Function() onSaved;

  @override
  State<AlertConfigurationFormWidget> createState() =>
      _AlertConfigurationFormWidgetState();
}

class _AlertConfigurationFormWidgetState
    extends State<AlertConfigurationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late AlertMetricType _metricType;
  late AlertOperator _operator;
  late double _threshold;
  late AlertSeverity _severity;
  String? _reconciliationType;
  String? _description;

  @override
  void initState() {
    super.initState();
    _initializeFormValues();
  }

  void _initializeFormValues() {
    final config = widget.initialConfig;
    if (config != null) {
      _name = config.name;
      _metricType = config.metricType;
      _operator = config.operator;
      _threshold = config.threshold;
      _severity = config.severity;
      _reconciliationType = config.reconciliationType;
      _description = config.description;
    } else {
      _name = '';
      _metricType = AlertMetricType.complianceScore;
      _operator = AlertOperator.lessThan;
      _threshold = 90.0;
      _severity = AlertSeverity.warning;
      _reconciliationType = null;
      _description = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(
              labelText: 'Alert Name',
              hintText: 'Enter a name for this alert',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onSaved: (value) {
              _name = value!;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AlertMetricType>(
            value: _metricType,
            decoration: const InputDecoration(
              labelText: 'Metric Type',
            ),
            items: AlertMetricType.values.map((type) {
              return DropdownMenuItem<AlertMetricType>(
                value: type,
                child: Text(_getMetricTypeDisplayName(type)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _metricType = value!;
                // Set default threshold based on metric type
                _threshold = _getDefaultThreshold(value);
              });
            },
            onSaved: (value) {
              _metricType = value!;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AlertOperator>(
            value: _operator,
            decoration: const InputDecoration(
              labelText: 'Operator',
            ),
            items: AlertOperator.values.map((op) {
              return DropdownMenuItem<AlertOperator>(
                value: op,
                child: Text(_getOperatorDisplayName(op)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _operator = value!;
              });
            },
            onSaved: (value) {
              _operator = value!;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _threshold.toString(),
            decoration: InputDecoration(
              labelText: 'Threshold Value',
              hintText: 'Enter threshold value',
              suffixText: _getMetricSuffix(_metricType),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a threshold value';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) {
              _threshold = double.parse(value!);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AlertSeverity>(
            value: _severity,
            decoration: const InputDecoration(
              labelText: 'Alert Severity',
            ),
            items: AlertSeverity.values.map((severity) {
              return DropdownMenuItem<AlertSeverity>(
                value: severity,
                child: Row(
                  children: [
                    Icon(
                      severity == AlertSeverity.info
                          ? Icons.info_outline
                          : severity == AlertSeverity.warning
                              ? Icons.warning_amber_outlined
                              : Icons.error_outline,
                      color: severity == AlertSeverity.info
                          ? Colors.blue
                          : severity == AlertSeverity.warning
                              ? Colors.orange
                              : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(_getSeverityDisplayName(severity)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _severity = value!;
              });
            },
            onSaved: (value) {
              _severity = value!;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: _reconciliationType,
            decoration: const InputDecoration(
              labelText: 'Reconciliation Type (Optional)',
              hintText: 'Apply to specific reconciliation type',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Types'),
              ),
              ...ReconciliationType.values.map((type) {
                return DropdownMenuItem<String?>(
                  value: type.toString(),
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _reconciliationType = value;
              });
            },
            onSaved: (value) {
              _reconciliationType = value;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _description,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter a description for this alert',
            ),
            maxLines: 3,
            onSaved: (value) {
              _description = value;
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(widget.initialConfig == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<AlertProvider>(context, listen: false);

      if (widget.initialConfig == null) {
        // Create new alert configuration
        final newConfig = AlertConfiguration.create(
          name: _name,
          metricType: _metricType,
          operator: _operator,
          threshold: _threshold,
          severity: _severity,
          reconciliationType: _reconciliationType,
          description: _description,
        );

        provider.createAlertConfiguration(newConfig);
      } else {
        // Update existing alert configuration
        final updatedConfig = widget.initialConfig!.copyWith(
          name: _name,
          metricType: _metricType,
          operator: _operator,
          threshold: _threshold,
          severity: _severity,
          reconciliationType: _reconciliationType,
          description: _description,
        );

        provider.updateAlertConfiguration(updatedConfig);
      }

      widget.onSaved();
      Navigator.of(context).pop();
    }
  }

  String _getMetricTypeDisplayName(AlertMetricType type) {
    switch (type) {
      case AlertMetricType.complianceScore:
        return 'Compliance Score';
      case AlertMetricType.matchPercentage:
        return 'Match Percentage';
      case AlertMetricType.taxDifference:
        return 'Tax Difference';
      case AlertMetricType.issueCount:
        return 'Issue Count';
      case AlertMetricType.reconciliationCount:
        return 'Reconciliation Count';
    }
  }

  String _getOperatorDisplayName(AlertOperator operator) {
    switch (operator) {
      case AlertOperator.lessThan:
        return 'Less Than';
      case AlertOperator.greaterThan:
        return 'Greater Than';
      case AlertOperator.equalTo:
        return 'Equal To';
      case AlertOperator.notEqualTo:
        return 'Not Equal To';
      case AlertOperator.lessThanOrEqual:
        return 'Less Than or Equal To';
      case AlertOperator.greaterThanOrEqual:
        return 'Greater Than or Equal To';
    }
  }

  String _getSeverityDisplayName(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  String _getMetricSuffix(AlertMetricType type) {
    switch (type) {
      case AlertMetricType.complianceScore:
      case AlertMetricType.matchPercentage:
        return '%';
      case AlertMetricType.taxDifference:
        return '₹';
      case AlertMetricType.issueCount:
      case AlertMetricType.reconciliationCount:
        return '';
    }
  }

  double _getDefaultThreshold(AlertMetricType type) {
    switch (type) {
      case AlertMetricType.complianceScore:
      case AlertMetricType.matchPercentage:
        return 90.0;
      case AlertMetricType.taxDifference:
        return 1000.0;
      case AlertMetricType.issueCount:
        return 5.0;
      case AlertMetricType.reconciliationCount:
        return 0.0;
    }
  }
}
